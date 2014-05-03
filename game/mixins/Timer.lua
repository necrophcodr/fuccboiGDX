Timer = {
    timerInit = function(self)
        self.timer = GTimer.new()
        self.timer_tags = {}
    end,
    
    timerUpdate = function(self, dt)
        self.timer:update(dt)
    end,

    timerTween = function(self, tag, n, tbl, twn_tbl, twn_f)
        if not self.timer_tags[tag] then
            self.timer_tags[tag] = self.timer:tween(n, tbl, twn_tbl, twn_f)
        end
    end,

    timerAfter = function(self, tag, n, f)
        if not self.timer_tags[tag] then
            self.timer_tags[tag] = self.timer:after(n, f)
        end
    end,

    timerEvery = function(self, tag, n, f, c)
        if not self.timer_tags[tag] then
            self.timer_tags[tag] = self.timer:every(n, f, c)
        end
    end,

    timerCancel = function(self, tag)
        if self.timer_tags[tag] then
            self.timer:cancel(self.timer_tags[tag])
            self.timer_tags[tag] = nil
        end
    end,

    timerDestroy = function(self)
        self.timer:clear()
        self.timer = nil
    end
}
