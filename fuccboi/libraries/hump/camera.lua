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

local _PATH = (...):match('^(.*[%./])[^%.%/]+$') or ''
local cos, sin = math.cos, math.sin

local Camera = {}
Camera.__index = Camera

local utils = require (fuccboi_path .. '/libraries/fuccboi/utils')
local Vector = require (fuccboi_path .. '/libraries/hump/vector')
local fn = require (fuccboi_path .. '/libraries/moses/moses')

function Camera.new(settings)
    local settings = settings or {}
    local self = {}

    self.x, self.y = settings.x or love.graphics.getWidth()/2, settings.y or love.graphics.getHeight()/2
    self.rotation = settings.rotation or 0
    self.scale = settings.scale or 1
    self.lerp = settings.lerp or 0
    self.lead = settings.lead or {x = 0, y = 0}
    self.target = settings.target
    self.bounds = settings.bounds
    self.max_shake_intensity = settings.max_shake_intensity or 15
    self.follow_style = settings.follow_style or 'lockon'

    self.shakes = {}
    self.shake_v = {x = 0, y = 0}
    self.shake_uid = 0
    self.last_target_position = nil
    self.debug_draw = false
    self.scroll_target = {x = self.x, y = self.y}
    self.screen_width = love.graphics.getWidth()
    self.screen_height = love.graphics.getHeight()
    
    return setmetatable(self, Camera)
end

function Camera:moveTo(x, y)
	self.x, self.y = x, y
	return self
end

function Camera:move(x, y)
	self.x, self.y = self.x + x, self.y + y
	return self
end

function Camera:getPosition()
	return self.x, self.y
end

function Camera:rotate(phi)
	self.rotation = self.rotation + phi
	return self
end

function Camera:rotateTo(phi)
	self.rotation = phi
	return self
end

function Camera:zoom(mul)
	self.scale = self.scale * mul
	return self
end

function Camera:zoomTo(zoom)
	self.scale = zoom
	return self
end

function Camera:attach()
    local cx, cy = 0, 0
    -- if fg.world.render_mode == 'canvas' then 
    cx, cy = love.graphics.getWidth()/(2*fg.screen_scale), love.graphics.getHeight()/(2*fg.screen_scale)
    -- else cx, cy = love.graphics.getWidth()/(2*self.scale), love.graphics.getHeight()/(2*self.scale) end

	love.graphics.push()
	love.graphics.scale(self.scale)
	love.graphics.translate(cx, cy)
	love.graphics.rotate(self.rotation)
	love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
	love.graphics.pop()
end

function Camera:shake(intensity, duration, settings)
    settings = settings or {}
    self.shake_uid = self.shake_uid + 1
    table.insert(self.shakes, {creation_time = love.timer.getTime(), id = self.uid, intensity = intensity, duration = duration,
                               direction = string.lower(settings.direction or 'both')})
end

function Camera:shakeRemove(id)
    table.remove(self.shakes, fn.find(self.shakes, {id = id}))
end

function Camera:updateShake(dt)
    self.shake_intensity = Vector(0, 0)
    for _, shake in ipairs(self.shakes) do
        if love.timer.getTime() > shake.creation_time + shake.duration then
            self:shakeRemove(shake.id)
        else
            if shake.direction == 'both' or shake.direction == 'horizontal' then
                if self.shake_intensity.x + shake.intensity < self.max_shake_intensity then
                    self.shake_intensity.x = self.shake_intensity.x + shake.intensity
                end
            end
            if shake.direction == 'both' or shake.direction == 'vertical' then
                if self.shake_intensity.y + shake.intensity < self.max_shake_intensity then
                    self.shake_intensity.y = self.shake_intensity.y + shake.intensity
                end
            end
        end
    end

    self:move(utils.math.random(-self.shake_intensity.x, self.shake_intensity.x), utils.math.random(-self.shake_intensity.y, self.shake_intensity.y))
end

function Camera:setBounds(left, top, right, down)
    self.bounds = {left = left, top = top, right = right, down = down} 
end

function Camera:removeBounds()
    self.bounds = nil    
end

function Camera:setGameSize()
    local left, top = self:getWorldCoords(0, 0)
    local right, bottom = self:getWorldCoords(love.graphics.getWidth(), love.graphics.getHeight())
    self.screen_width = right - left
    self.screen_height = bottom - top
end

function Camera:setDeadzone(left, top, right, down)
    self:setGameSize()
    self.follow_style = nil
    self.deadzone = {x = left, y = top, width = right, height = down}
end

function Camera:follow(target, settings)
    self:setGameSize()
    self.target = target 
    local settings = settings or {}
    self.follow_style = settings.follow_style or self.follow_style
    self.lead = settings.lead or self.lead
    self.lerp = settings.lerp or self.lerp
    local w, h = 0, 0
    local helper = 0

    if self.follow_style == 'lockon' then
        w = self.target.w or 16
        h = self.target.h or 16
        self.deadzone = {x = -w/2, y = -h/2, width = w, height = h}
    elseif self.follow_style == 'screen' then
        self.deadzone = {x = -self.screen_width/2, y = -self.screen_height/2, width = self.screen_width, height = self.screen_height}
    elseif self.follow_style == 'platformer' then
        w = self.screen_width/8
        h = self.screen_height/3
        self.deadzone = {x = -w/2, y = -h/2 - h/4, width = w, height = h}
    elseif self.follow_style == 'topdown' then
        helper = math.max(self.screen_width, self.screen_height)/4 
        self.deadzone = {x = -helper/2, y = -helper/2, width = helper, height = helper}
    elseif self.follow_style == 'topdown-tight' then
        helper = math.max(self.screen_width, self.screen_height)/8 
        self.deadzone = {x = -helper/2, y = -helper/2, width = helper, height = helper}
    end
end

function Camera:updateFollow(dt)
    if not self.deadzone then self:moveTo(self.target.x, self.target.y)
    else
        local edge = 0
        if self.follow_style == 'screen' then
            if self.target.x > (self.x + self.deadzone.width/2) then self.scroll_target.x = self.scroll_target.x + self.deadzone.width
            elseif self.target.x < (self.x  - self.deadzone.width/2) then self.scroll_target.x = self.scroll_target.x - self.deadzone.width
            elseif self.target.y > (self.y + self.deadzone.height/2) then self.scroll_target.y = self.scroll_target.y + self.deadzone.height
            elseif self.target.y < (self.y - self.deadzone.height/2) then self.scroll_target.y = self.scroll_target.y - self.deadzone.height end
        else
            edge = self.target.x - self.deadzone.x
            if self.scroll_target.x > edge then self.scroll_target.x = edge end
            edge = self.target.x - self.deadzone.x - self.deadzone.width
            if self.scroll_target.x < edge then self.scroll_target.x = edge end
            edge = self.target.y - self.deadzone.y
            if self.scroll_target.y > edge then self.scroll_target.y = edge end
            edge = self.target.y - self.deadzone.y - self.deadzone.height
            if self.scroll_target.y < edge then self.scroll_target.y = edge end
        end
        
        if not self.last_target_position then self.last_target_position = Vector(self.target.x, self.target.y) end
        self.scroll_target.x = self.scroll_target.x + (self.target.x - self.last_target_position.x)*self.lead.x
        self.scroll_target.y = self.scroll_target.y + (self.target.y - self.last_target_position.y)*self.lead.y
        self.last_target_position.x = self.target.x
        self.last_target_position.y = self.target.y

        if self.lerp == 0 then

        else
            self:move((self.scroll_target.x - self.x)*dt/(dt+self.lerp*dt),
                      (self.scroll_target.y - self.y)*dt/(dt+self.lerp*dt))
        end
    end
end

function Camera:resize(w, h)
    if self.target then
        self:moveTo(self.target.x, self.target.y)
    else self:moveTo(w/2, h/2) end
end

function Camera:update(dt)
    self:setGameSize()
    if self.target then self:updateFollow(dt) end
    if self.bounds then
        local left, top = self.x - self.screen_width/2, self.y - self.screen_height/2
        local right, down = self.x + self.screen_width/2, self.y + self.screen_height/2
        left = utils.math.clamp(left, self.bounds.left, self.bounds.right)
        right = utils.math.clamp(right, self.bounds.left, self.bounds.right)
        top = utils.math.clamp(top, self.bounds.top, self.bounds.down)
        down = utils.math.clamp(down, self.bounds.top, self.bounds.down)
        self.x = utils.math.clamp(self.x, left + self.screen_width/2, right - self.screen_width/2)
        self.y = utils.math.clamp(self.y, top + self.screen_height/2, down - self.screen_height/2)
    end
    self:updateShake(dt)
end

function Camera:draw(func)
	self:attach()
	func()
	self:detach()
end

function Camera:debugDraw()
    if self.debug_draw then
        love.graphics.setLineWidth(2)
        local x, y = self:getCameraCoords(self.x, self.y)
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle('fill', x, y, 5)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle('line', x, y, 5)
        love.graphics.setColor(255, 255, 255)
        local tx, ty = 0, 0
        if self.target then
            tx, ty = self:getCameraCoords(self.target.x, self.target.y)
            love.graphics.setColor(222, 64, 64)
            love.graphics.circle('fill', tx, ty, 5)
            love.graphics.setColor(0, 0, 0)
            love.graphics.circle('line', tx, ty, 5)
            love.graphics.setColor(255, 255, 255)
        end
        if self.deadzone then
            local left, top = fg.screen_scale*self.deadzone.x, fg.screen_scale*self.deadzone.y
            local right, bottom = fg.screen_scale*self.deadzone.width, fg.screen_scale*self.deadzone.height
            self:attach()
            love.graphics.setLineWidth(3)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle('line', self.x - 3*left, self.y, right, bottom)
            love.graphics.setLineWidth(1.5)
            love.graphics.setColor(255, 255, 255)
            love.graphics.rectangle('line', self.x - 3*left, self.y, right, bottom)
            love.graphics.print('style: ' .. tostring(self.follow_style), self.x + 70 - 4*left, self.y)
            love.graphics.print('lerp: ' .. tostring(self.lerp), self.x + 70 - 4*left, self.y + 15)
            love.graphics.print('lead: ' .. tostring(self.lead.x), self.x + 70 - 4*left, self.y + 30)
            self:detach()
        end
        love.graphics.setLineWidth(1)
    end
end

function Camera:getCameraCoords(x, y)
	-- x,y = ((x,y) - (self.x, self.y)):rotated(self.rot) * self.scale + center
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	local c, s = cos(self.rotation), sin(self.rotation)
	x, y = x - self.x, y - self.y
	x, y = c*x - s*y, s*x + c*y
	-- return x*self.scale + w/2, y*self.scale + h/2
	return x*fg.screen_scale + w/2, y*fg.screen_scale + h/2
end

function Camera:getWorldCoords(x, y)
	-- x,y = (((x,y) - center) / self.scale):rotated(-self.rot) + (self.x,self.y)
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	local c, s = cos(-self.rotation), sin(-self.rotation)
	-- x, y = (x - w/2)/self.scale, (y - h/2)/self.scale
	x, y = (x - w/2)/fg.screen_scale, (y - h/2)/fg.screen_scale
	x, y = c*x - s*y, s*x + c*y
	return x+self.x, y+self.y
end

function Camera:getMousePosition()
	return self:worldCoords(love.mouse.getPosition())
end

return setmetatable({new = new}, {__call = function(_, ...) return Camera.new(...) end})
