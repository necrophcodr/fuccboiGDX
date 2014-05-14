local timer = {}
timer.__index = timer

local Timer = require (mogamett_path .. '/libraries/hump/timer')

local function new()
    return setmetatable({timer = Timer.new(), tags = {}}, timer)
end

function timer:update(dt)
    self.timer:update(dt)
end

function timer:tween(tag, duration, table, tween_table, tween_function, after, ...)
    if not self.tags[tag] then
        self.tags[tag] = self.timer:tween(duration, table, tween_table, tween_function, after, ...)
    end
end

function timer:after(tag, duration, func)
    if not self.tags[tag] then
        self.tags[tag] = self.timer:after(duration, func)
    end
end

function timer:every(tag, duration, func, count)
    if not self.tags[tag] then
        self.tags[tag] = self.timer:every(duration, func, count)
    end 
end

function timer:during(tag, duration, func, after)
    if not self.tags[tag] then
        self.tags[tag] = self.timer:during(duration, func, after)
    end
end

function timer:cancel(tag)
    if self.tags[tag] then
        self.timer:cancel(self.tags[tag])
        self.tags[tag] = nil
    end
end

function timer:clear()
    self.timer:clear()
    self.tags = {}
end

function timer:destroy()
    self.timer:clear()
    self.tags = {}
    self.timer = nil
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
