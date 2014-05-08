local Timer = {
    timerInit = function(self)
        self.timer = self.world.mg.Timer.new() 
        self._timer_tags = {}
    end,
    
    timerUpdate = function(self, dt)
        self.timer:update(dt)
    end,

    timerTween = function(self, tag, n, tbl, twn_tbl, twn_f)
        if not self._timer_tags[tag] then
            self._timer_tags[tag] = self.timer:tween(n, tbl, twn_tbl, twn_f)
        end
    end,

    timerAfter = function(self, tag, n, f)
        if not self._timer_tags[tag] then
            self._timer_tags[tag] = self.timer:after(n, f)
        end
    end,

    timerEvery = function(self, tag, n, f, c)
        if not self._timer_tags[tag] then
            self._timer_tags[tag] = self.timer:every(n, f, c)
        end
    end,

    timerCancel = function(self, tag)
        if self._timer_tags[tag] then
            self.timer:cancel(self._timer_tags[tag])
            self._timer_tags[tag] = nil
        end
    end,

    timerDestroy = function(self)
        self.timer:clear()
        self.timer = nil
    end
}

return Timer
