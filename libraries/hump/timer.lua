--[[
Copyright (c) 2010-2013 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local Timer = {}
Timer.__index = Timer

local function _nothing_() end

local function new()
	return setmetatable({functions = {}, tween = Timer.tween}, Timer)
end

function Timer:update(dt)
	local to_remove = {}
	for handle, delay in pairs(self.functions) do
		delay = delay - dt
		if delay <= 0 then
			to_remove[#to_remove+1] = handle
		end
		self.functions[handle] = delay
		handle.func(dt, delay)
	end
	for _,handle in ipairs(to_remove) do
		self.functions[handle] = nil
		handle.after(handle.after)
	end
end

function Timer:do_for(delay, func, after)
	local handle = {func = func, after = after or _nothing_}
	self.functions[handle] = delay
	return handle
end

function Timer:after(delay, func)
    local actual_delay = delay
    if type(delay) == 'table' then actual_delay = math.prandom(delay[1], delay[2]) end
	return self:do_for(actual_delay, _nothing_, func)
end

function Timer:every(delay, func, count)
	local count, handle = count or math.huge -- exploit below: math.huge - 1 = math.huge

    local actual_delay = delay
    if type(delay) == 'table' then actual_delay = math.prandom(delay[1], delay[2]) end

	handle = self:after(actual_delay, function(f)
		if func(func) == false then return end
		count = count - 1
		if count > 0 then
			self.functions[handle] = actual_delay
		end
	end)
	return handle
end

function Timer:cancel(handle)
	self.functions[handle] = nil
end

function Timer:clear()
	self.functions = {}
end

Timer.tween = setmetatable({
	-- helper functions
	out = function(f) -- 'rotates' a function
		return function(s, ...) return 1 - f(1-s, ...) end
	end,
	chain = function(f1, f2) -- concatenates two functions
		return function(s, ...) return (s < .5 and f1(2*s, ...) or 1 + f2(2*s-1, ...)) * .5 end
	end,

	-- useful tweening functions
	linear = function(s) return s end,
	quad   = function(s) return s*s end,
	cubic  = function(s) return s*s*s end,
	quart  = function(s) return s*s*s*s end,
	quint  = function(s) return s*s*s*s*s end,
	sine   = function(s) return 1-math.cos(s*math.pi/2) end,
	expo   = function(s) return 2^(10*(s-1)) end,
	circ   = function(s) return 1 - math.sqrt(1-s*s) end,

	back = function(s,bounciness)
		bounciness = bounciness or 1.70158
		return s*s*((bounciness+1)*s - bounciness)
	end,

	bounce = function(s) -- magic numbers ahead
		local a,b = 7.5625, 1/2.75
		return math.min(a*s^2, a*(s-1.5*b)^2 + .75, a*(s-2.25*b)^2 + .9375, a*(s-2.625*b)^2 + .984375)
	end,

	elastic = function(s, amp, period)
		amp, period = amp and math.max(1, amp) or 1, period or .3
		return (-amp * math.sin(2*math.pi/period * (s-1) - math.asin(1/amp))) * 2^(10*(s-1))
	end,
}, {

-- register new tween
__call = function(tween, self, len, subject, target, method, after, ...)
	-- recursively collects fields that are defined in both subject and target into a flat list
	local function tween_collect_payload(subject, target, out)
		for k,v in pairs(target) do
			local ref = subject[k]
			assert(type(v) == type(ref), 'Type mismatch in field "'..k..'".')
			if type(v) == 'table' then
				tween_collect_payload(ref, v, out)
			else
				local ok, delta = pcall(function() return (v-ref)*1 end)
				assert(ok, 'Field "'..k..'" does not support arithmetic operations')
				out[#out+1] = {subject, k, delta}
			end
		end
		return out
	end

	method = tween[method or 'linear'] -- see __index
	local payload, t, args = tween_collect_payload(subject, target, {}), 0, {...}

	local last_s = 0
	return self:do_for(len, function(dt)
		t = t + dt
		local s = method(math.min(1, t/len), unpack(args))
		local ds = s - last_s
		last_s = s
		for _, info in ipairs(payload) do
			local ref, key, delta = unpack(info)
			ref[key] = ref[key] + delta * ds
		end
	end, after)
end,

-- fetches function and generated compositions for method `key`
__index = function(tweens, key)
	if type(key) == 'function' then return key end

	assert(type(key) == 'string', 'Method must be function or string.')
	if rawget(tweens, key) then return rawget(tweens, key) end

	local function construct(pattern, f)
		local method = rawget(tweens, key:match(pattern))
		if method then return f(method) end
		return nil
	end

	local out, chain = rawget(tweens,'out'), rawget(tweens,'chain')
	return construct('^in%-([^-]+)$', function(...) return ... end)
	       or construct('^out%-([^-]+)$', out)
	       or construct('^in%-out%-([^-]+)$', function(f) return chain(f, out(f)) end)
	       or construct('^out%-in%-([^-]+)$', function(f) return chain(out(f), f) end)
	       or error('Unknown interpolation method: ' .. key)
end})

-- default timer
local default = new()

-- the module
return setmetatable({
	new         = new,
	update      = function(...) return default:update(...) end,
	do_for      = function(...) return default:do_for(...) end,
	after       = function(...) return default:after(...) end,
	every       = function(...) return default:every(...) end,
	cancel      = function(...) return default:cancel(...) end,
	clear       = function(...) return default:clear(...) end,
	tween       = setmetatable({}, {
		__index    = Timer.tween,
		__newindex = function(_,k,v) Timer.tween[k] = v end,
		__call     = function(t,...) return default:tween(...) end,
	})
}, {__call = new})
