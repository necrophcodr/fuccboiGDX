classes['Flash'] = class('Flash', Entity); local Flash = classes['Flash']
Flash:include(Timer)

function Flash:init(world, x, y, settings)
    Entity.init(self, world, x, y, settings)
    self:timerInit()
    local m = 1
    if self.long then m = 2 end
    self.r = 0.1
    if self.size then self.final_r = self.size
    else self.final_r = math.prandom(12*m, 24*m) end
    if not self.permanent then
        local d = math.prandom(0.05*m, 0.1*m)
        self.timer:tween(d, self, {r = self.final_r}, 'in-elastic')
        self.timer:after(d, function()
            local e = math.prandom(0.25*m, 0.5*m)
            if m == 2 then self.timer:tween(e, self, {r = 0}, 'in-elastic')
            else self.timer:tween(e, self, {r = 0}, 'in-out-cubic') end
            self.timer:after(e, function() self.dead = true end)
        end)
    else
        local d = 0
        if self.fast then d = math.prandom(1*m, 2*m)
        else d = math.prandom(3*m, 6*m) end
        self.timer:tween(d, self, {r = self.final_r}, 'in-out-cubic')
    end
end

function Flash:update(dt)
    self:timerUpdate(dt)
    if self.follow_camera_left then
        local cx, cy = self.world.camera:pos()
        self.x = cx - 160
        self.y = cy + 120
    end
    if self.follow_camera_right then
        local cx, cy = self.world.camera:pos()
        self.x = cx + 160
        self.y = cy + 120
    end
    if self.parent then
        if self.parent.dead then self.parent = nil; self.dead = true; return end
        local angle = self.parent.body:getAngle()
        self.x = self.parent.x + math.cos(angle)*(self.x_offset or 0)
        self.y = self.parent.y + math.sin(angle)*(self.y_offset or 0)
    end
end

function Flash:draw()
    
end
