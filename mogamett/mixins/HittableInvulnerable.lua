local HittableInvulnerable = {
    hittableInit = function(self, settings)
        self.blinking = false
        self.invulnerable = false
        self.hit_alpha = 255
        self.interval = settings.interval or 0.05
        self.times = settings.times or 20
    end,

    hittableHit = function(self)
        self.invulnerable = true
        self.timer:every(self.interval, function() 
            self.blinking = not self.blinking
        end, self.times)
        self.timer:after(self.interval*(self.times+2), function() 
            self.invulnerable = false
            self.blinking = false 
        end)
    end,

    hittableDraw = function(self)
        if self.blinking then self.hit_alpha = 0
        else self.hit_alpha = 255 end
        love.graphics.setColor(255, 255, 255, self.hit_alpha)
    end
}

return HittableInvulnerable
