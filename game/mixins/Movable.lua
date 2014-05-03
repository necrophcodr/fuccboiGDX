Movable = {
    movableInit = function(self, max_v, a, gravity_scale)
        self.init_max_v = max_v
        self.max_v = max_v 
        self.v = Vector(0, 0)
        self.init_a = a
        self.a = self.init_a
        self.damping = 0.8
        self.gravity_scale = gravity_scale
        self.moving = {left = false, right = false}
        self.direction = 'right'
        self.body:setGravityScale(gravity_scale)
    end,

    changeMaxV = function(self, m)
        self:timerCancel('changeMaxV')
        self:timerCancel('restoreInitMaxV')
        self:timerTween('changeMaxV', 0.2, self, {max_v = m*self.init_max_v}, 'linear')
    end,

    restoreInitMaxV = function(self)
        self:timerCancel('changeMaxV')
        self:timerCancel('restoreInitMaxV')
        self:timerTween('restoreInitMaxV', 0.2, self, {max_v = self.init_max_v}, 'linear')
    end,
    
    moveLeft = function(self)
        self.moving.left = true 
    end,

    moveRight = function(self)
        self.moving.right = true 
    end,

    movableUpdate = function(self, dt)
        local vx, vy = self.body:getLinearVelocity()

        if self.moving.left then
            self.v.x = math.max(self.v.x - self.a*dt, -self.max_v)
            self.body:setLinearVelocity(self.v.x, vy)
            self.direction = 'left'
        end

        if self.moving.right then
            self.v.x = math.min(self.v.x + self.a*dt, self.max_v)
            self.body:setLinearVelocity(self.v.x, vy)
            self.direction = 'right'
        end

        if not self.moving.right and not self.moving.left then
            self.v.x = self.v.x*self.damping
            self.body:setLinearVelocity(self.v.x, vy)
            if math.abs(self.v.x) < 24 then self.v.x = 0 end
        end

        self.moving.left = false
        self.moving.right = false
    end
}
