HittableRed = {
    hittableInit = function(self, interval, hit_color)
        self.hit = false
        self.heal = false
        self.init_hit_color = hit_color or {128, 32, 32, 255}
        self.hit_color = hit_color or {128, 32, 32, 255}
        self.heal_color = {32, 128, 32, 255}
        self.interval = interval or 0.2
        self.combine = shaders['combine']

        self.blinking = false
        self.invulnerable = false
        self.blink_timer = 0
        self.blink_interval = 0
    end,

    hittableHit = function(self, interval, color)
        self.hit_color = self.init_hit_color
        if color then self.hit_color = color end
        self.hit = true 
        self.timer:after(interval or self.interval, function()
            self.hit = false
        end)
    end,

    hittableHitInvulnerable = function(self, interval, duration)
        self:timerCancel('blink')
        self:timerCancel('invulnerable')
        self:timerCancel('blink interval change')
        self.invulnerable = true
        self:timerAfter('invulnerable', duration, function() 
            self.invulnerable = false 
            self.blinking = false
            self.blink_timer = 0
            self.blink_interval = 0
        end)
        self.blink_interval = interval
        self:timerTween('blink interval change', duration, self, {blink_interval = 0.03}, 'in-out-cubic')
    end,

    hittableUpdate = function(self, dt)
        if self.invulnerable then
            self.blink_timer = self.blink_timer + dt
            if self.blink_timer > self.blink_interval then
                self.blinking = not self.blinking
                self.blink_timer = 0
            end
        end
    end,

    hittableHeal = function(self, interval)
        self.heal = true 
        self.timer:after(interval or self.interval, function()
            self.heal = false
        end)
    end,

    hittableDraw = function(self)
        if self.hit then
            love.graphics.setShader(self.combine)
            love.graphics.setColor(unpack(self.hit_color))
        end
        if self.heal then
            love.graphics.setShader(self.combine)
            love.graphics.setColor(unpack(self.heal_color))
        end
        local r, g, b, a = love.graphics.getColor()
        if self.blinking then love.graphics.setColor(r, g, b, 0)
        else love.graphics.setColor(r, g, b, 255) end
    end
}
