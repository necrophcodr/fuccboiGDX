-- Requires PhysicsRectangle
Steerable = {
    steerableInit = function(self, angle, v, max_v, max_f, turn_m)
        self.current_behavior = 'idle'
        self.angle = angle or 0
        self.direction = angleToDirection(angle)
        self.v = Vector(math.cos(angle)*v, math.sin(angle)*v)
        self.init_max_v = max_v or 0
        self.max_v = self.init_max_v
        self.max_f = max_f or 0
        self.turn_multiplier = turn_m or 1
        self.steering = Vector(0, 0)
        self.steering_force = Vector(0, 0)
        self.target = Vector(0, 0)
        self.damping = 0.95
        self.arrival_radius = 25
        self.flee_radius = 40
    end,

    steerableUpdate = function(self, dt)
        if self.current_behavior == 'idle' then return
        elseif self.current_behavior == 'seek' then self:steerableSeek(self.target)
        elseif self.current_behavior == 'arrival' then self:steerableArrival(self.target) 
        elseif self.current_behavior == 'flee' then self:steerableFlee(self.target)
        end

        self.steering_force = self.steering:min(self.max_f)
        self.v = (self.v + self.steering_force*dt):min(self.max_v)
        self.body:setLinearVelocity(self.v.x, self.v.y)
        self.angle = self.v:angle()
        self.direction = angleToDirection(self.angle)
    end,
    
    steerableSeek = function(self, target)
        local position = Vector(self.body:getPosition())
        local desired_velocity = (target - position):normalized()*self.max_v
        local velocity = Vector(self.body:getLinearVelocity())
        self.steering = (desired_velocity - velocity)*self.turn_multiplier
    end,

    steerableFlee = function(self, target)
        local position = Vector(self.body:getPosition())
        local desired_velocity = (position - target)
        local distance = desired_velocity:len()
        if distance < self.flee_radius then
            desired_velocity = desired_velocity:normalized()*self.max_v*(1-(distance/self.flee_radius))
        else desired_velocity = Vector(0, 0) end
        local velocity = Vector(self.body:getLinearVelocity())
        self.steering = (desired_velocity - velocity)*self.turn_multiplier
    end,

    steerableArrival = function(self, target)
        local position = Vector(self.body:getPosition())
        local desired_velocity = (target - position)
        local distance = desired_velocity:len()
        if distance < self.arrival_radius then
            desired_velocity = desired_velocity:normalized()*self.max_v*(distance/self.arrival_radius)
        else desired_velocity = desired_velocity:normalized()*self.max_v end
        local velocity = Vector(self.body:getLinearVelocity())
        self.steering = (desired_velocity - velocity)*self.turn_multiplier
    end,

    steerableDraw = function(self)
        if debug_draw then
            if self.target then
                local x, y = self.body:getPosition()
                love.graphics.setColor(128, 64, 244, 255)
                love.graphics.line(x, y, self.target.x, self.target.y)
                love.graphics.setColor(244, 244, 64, 255)
                love.graphics.circle('line', self.target.x, self.target.y, self.arrival_radius)
                love.graphics.setColor(255, 255, 255, 255)
            end
        end
    end
}
