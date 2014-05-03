HitFrameStop = {
    hitFrameStopInit = function(self)
        self.frame_stopped = false
        self.frames_left = 0
    end,

    hitFrameStopUpdate = function(self, dt)
        self.frames_left = math.max(self.frames_left - 1, 0)
        if self.frames_left <= 0 then self.frame_stopped = false
        else self.frame_stopped = true end
    end,

    hitFrameStopAdd = function(self, number_of_frames)
        if self.frames_left < number_of_frames then
            self.frames_left = number_of_frames
        end
    end
}
