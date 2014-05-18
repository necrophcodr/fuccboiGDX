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

local camera = {}
camera.__index = camera

local utils = require (mogamett_path .. '/libraries/mogamett/utils')
local Vector = require (mogamett_path .. '/libraries/hump/vector')

local function new(settings)
    local settings = settings or {}
	local x, y  = settings.x or love.graphics.getWidth()/2, settings.y or love.graphics.getHeight()/2
	local zoom = settings.zoom or 1
	local rotation = settings.rotation or 0
    local lerp = settings.lerp or 0
    local lead = settings.lead or {x = 0, y = 0}
    local target = settings.target
    local bounds = settings.bounds
    local max_shake_intensity = settings.max_shake_intensity or 15
    local follow_style = settings.follow_style or 'lockon'
    local v = {x = 0, y = 0}
	return setmetatable({x = x, y = y, scale = zoom, rotation = rotation, follow_lerp = lerp, follow_lead = lead, target = target, v = v,
                         max_shake_intensity = max_shake_intensity, shake_intensity = {x = 0, y = 0}, shakes = {}, follow_style = follow_style,
                         shake_v = {x = 0, y = 0}, shake_uid = 0, bounds = bounds, last_target_position = nil, debug_draw = false,
                         scroll_target = {x = x, y = y}, game_width = love.graphics.getWidth(), game_height = love.graphics.getHeight()}, camera)
end

function camera:moveTo(x, y)
	self.x, self.y = x,y
	return self
end

function camera:move(x, y)
	self.x, self.y = self.x + x, self.y + y
	return self
end

function camera:getPosition()
	return self.x, self.y
end

function camera:rotate(phi)
	self.rotation = self.rotation + phi
	return self
end

function camera:rotateTo(phi)
	self.rotation = phi
	return self
end

function camera:zoom(mul)
	self.scale = self.scale * mul
	return self
end

function camera:zoomTo(zoom)
	self.scale = zoom
	return self
end

function camera:attach()
	local cx,cy = love.graphics.getWidth()/(2*self.scale), love.graphics.getHeight()/(2*self.scale)
	love.graphics.push()
	love.graphics.scale(self.scale)
	love.graphics.translate(cx, cy)
	love.graphics.rotate(self.rotation)
	love.graphics.translate(-self.x, -self.y)
end

function camera:detach()
	love.graphics.pop()
end

function camera:shake(intensity, duration, settings)
    settings = settings or {}
    self.shake_uid = self.shake_uid + 1
    table.insert(self.shakes, {creation_time = love.timer.getTime(), id = self.uid, intensity = intensity, duration = duration,
                               direction = string.lower(settings.direction) or 'both'})
end

function camera:shakeRemove(id)
    table.remove(self.shakes, utils.findIndexById(self.shakes, id))
end

function camera:updateShake(dt)
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

function camera:setBounds(left, top, right, down)
    self.bounds = {left = left, top = top, right = right, down = down} 
end

function camera:removeBounds()
    self.bounds = nil    
end

function camera:setGameSize()
    local left, top = self:getWorldCoords(0, 0)
    local right, bottom = self:getWorldCoords(love.graphics.getWidth(), love.graphics.getHeight())
    self.game_width = right - left
    self.game_height = bottom - top
end

function camera:setDeadzone(left, top, right, down)
    self:setGameSize()
    self.follow_style = nil
    self.deadzone = {x = left, y = top, width = right, height = down}
end

function camera:follow(target, settings)
    self:setGameSize()
    self.target = target 
    local settings = settings or {}
    self.follow_style = settings.follow_style or self.follow_style
    self.follow_lead = settings.lead or self.follow_lead
    self.follow_lerp = settings.lerp or self.follow_lerp
    local w, h = 0, 0
    local helper = 0

    if self.follow_style == 'lockon' then
        w = self.target.w or 16
        h = self.target.h or 16
        self.deadzone = {x = -w/2, y = -h/2, width = w, height = h}
    elseif self.follow_style == 'screen' then
        self.deadzone = {x = -self.game_width/2, y = -self.game_height/2, width = self.game_width, height = self.game_height}
    elseif self.follow_style == 'platformer' then
        w = self.game_width/8
        h = self.game_height/3
        self.deadzone = {x = -w/2, y = -h/2 - h/4, width = w, height = h}
    elseif self.follow_style == 'topdown' then
        helper = math.max(self.game_width, self.game_height)/4 
        self.deadzone = {x = -helper/2, y = -helper/2, width = helper, height = helper}
    elseif self.follow_style == 'topdown-tight' then
        helper = math.max(self.game_width, self.game_height)/8 
        self.deadzone = {x = -helper/2, y = -helper/2, width = helper, height = helper}
    end
end

function camera:updateFollow(dt)
    if not self.deadzone then self:moveTo(self.target.x, self.target.y)
    else
        local edge = 0
        if self.follow_style == 'screen' then
            if self.target.x > (self.x + self.game_width/2) then self.scroll_target.x = self.scroll_target.x + self.game_width
            elseif self.target.x < (self.x  - self.game_width/2) then self.scroll_target.x = self.scroll_target.x - self.game_width
            elseif self.target.y > (self.y + self.game_height/2) then self.scroll_target.y = self.scroll_target.y + self.game_height
            elseif self.target.y < (self.y - self.game_height/2) then self.scroll_target.y = self.scroll_target.y - self.game_height end
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
        self.scroll_target.x = self.scroll_target.x + (self.target.x - self.last_target_position.x)*self.follow_lead.x
        self.scroll_target.y = self.scroll_target.y + (self.target.y - self.last_target_position.y)*self.follow_lead.y
        self.last_target_position.x = self.target.x
        self.last_target_position.y = self.target.y

        if self.follow_lerp == 0 then

        else
            self:move((self.scroll_target.x - self.x)*dt/(dt+self.follow_lerp*dt),
                      (self.scroll_target.y - self.y)*dt/(dt+self.follow_lerp*dt))
        end
    end
end

function camera:update(dt)
    self:setGameSize()
    if self.target then self:updateFollow(dt) end
    if self.bounds then
        local camera_left, camera_top = self:getWorldCoords(self.x - self.game_width/2, self.y - self.game_height/2)
        local camera_right, camera_bottom = self:getWorldCoords(self.x + self.game_width/2, self.y + self.game_height/2)
        local left = utils.math.clamp(camera_left, self.bounds.left, self.bounds.right)
        local right = utils.math.clamp(camera_right, self.bounds.left, self.bounds.right)
        local top = utils.math.clamp(camera_top, self.bounds.top, self.bounds.down)
        local bottom = utils.math.clamp(camera_bottom, self.bounds.top, self.bounds.down)
        self.x = utils.math.clamp(self.x, left, right)
        self.y = utils.math.clamp(self.y, top, bottom)
    end
    self:updateShake(dt)
end

function camera:draw(func)
	self:attach()
	func()
	self:detach()
end

function camera:debugDraw()
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
            local left, top = self.deadzone.x, self.deadzone.y
            local right, bottom = self.deadzone.width, self.deadzone.height
            self:attach()
            love.graphics.setLineWidth(3)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle('line', self.x + left, self.y + top, right, bottom)
            love.graphics.setLineWidth(1.5)
            love.graphics.setColor(255, 255, 255)
            love.graphics.rectangle('line', self.x + left, self.y + top, right, bottom)
            love.graphics.print('Style: ' .. tostring(self.follow_style), self.x + 40, self.y)
            love.graphics.print('lerp: ' .. tostring(self.follow_lerp), self.x + 40, self.y + 15)
            love.graphics.print('lead: ' .. tostring(self.follow_lead.x), self.x + 40, self.y + 30)
            self:detach()
        end
        love.graphics.setLineWidth(1)
    end
end

function camera:getCameraCoords(x,y)
	-- x,y = ((x,y) - (self.x, self.y)):rotated(self.rot) * self.scale + center
	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	local c,s = cos(self.rotation), sin(self.rotation)
	x,y = x - self.x, y - self.y
	x,y = c*x - s*y, s*x + c*y
	return x*self.scale + w/2, y*self.scale + h/2
end

function camera:getWorldCoords(x,y)
	-- x,y = (((x,y) - center) / self.scale):rotated(-self.rot) + (self.x,self.y)
	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	local c,s = cos(-self.rotation), sin(-self.rotation)
	x,y = (x - w/2) / self.scale, (y - h/2) / self.scale
	x,y = c*x - s*y, s*x + c*y
	return x+self.x, y+self.y
end

function camera:getMousePosition()
	return self:worldCoords(love.mouse.getPosition())
end

-- the module
return setmetatable({new = new},
	{__call = function(_, ...) return new(...) end})
