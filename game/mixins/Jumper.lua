Jumper = {
    jumperInit = function(self, jump_a, jumps_left)
        self.jump_a = jump_a
        self.max_jumps = jumps_left
        self.jumps_left = jumps_left 
        self.jump_down = false
        self.on_ground = false
        self.falling = false
        self.jump_normal = Vector(0, 0)
        self.jump_press_time = 0
        self.jump_stopping_id = nil
        self.jump_vy = 0
    end,

    jump = function(self)
        self.jump_down = true
    end,

    impulse = function(self, m)
        local x, y = self.body:getLinearVelocity() 
        self.jump_down = true
        self.on_ground = false
        self.jumps_left = self.jumps_left - 1
        self.body:setLinearVelocity(x, m*self.jump_a)
    end,

    jumpPressed = function(self)
        local x, y = self.body:getLinearVelocity()
        if self.jumps_left >= 1 then 
            sound:play('Player Jump')
            self.jumps_left = self.jumps_left - 1
            self.on_ground = false
            self.jump_press_time = love.timer.getTime()
            self.body:setLinearVelocity(x, self.jump_a) 
            self.jump_vy = self.jump_a/2
        end 
    end,

    jumpReleased = function(self)
        local dt = love.timer.getTime() - self.jump_press_time
        if dt >= 0.15 then 
            self.jump_down = false 
            self.jump_press_time = 0
        else self.timer:after(0.15 - dt, function() self.jump_down = false; self.jump_press_time = 0 end) end
    end,

    jumperCollisionEnter = function(self, solid, nx, ny)
        if solid then
            if solid.y > self.y then return end
        end
        self.on_ground = true
        self.jump_down = false 
    end,

    jumperUpdate = function(self, dt)
        local x, y = self.body:getLinearVelocity() 

        if y > 10 then self.falling = true else self.falling = false end

        -- Stops going up whenever jump key isn't being pressed
        if not self.falling then
            if not self.jump_down then
                if not self.jump_stopping_id then
                    local vx, vy = self.body:getLinearVelocity()
                    if vy < -100 or vy > 100 then
                        self.jump_stopping_id = self.timer:tween(0.04, self, {jump_vy = 0}, 'linear')
                        self.timer:after(0.04, function() self.jump_stopping_id = nil end)
                        self.body:setLinearVelocity(x, self.jump_vy)
                    end
                end
            end
        end

        -- Resets jumps left when on ground
        if self.on_ground then
            self.jumps_left = self.max_jumps
            -- Jumps again if jump key is down
            if self.jump_down then
                self:jumpPressed()
            end
        end
    end
}
