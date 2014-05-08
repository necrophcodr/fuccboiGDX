local Fader = {
    faderInit = function(self, settings)
        self.in_alpha = settings.in_alpha
        self.in_target = settings.in_target
        self.fade_alpha = self.in_alpha or 255
    end,

    fadeIn = function(self, delay, duration, tween_function)
        self.timer:after(delay, function()
            self.timer:tween(duration, self, {fade_alpha = self.in_target or 255}, tween_function)
        end)
    end,

    fadeOut = function(self, delay, duration, tween_function)
        self.timer:after(delay, function()
            self.timer:tween(duration, self, {fade_alpha = self.in_alpha or 0}, tween_function)
            self.timer:after(duration, function() self.dead = true end)
        end)
    end,

    faderDraw = function(self)
        love.graphics.setColor(255, 255, 255, self.fade_alpha)
    end
}

return Fader
