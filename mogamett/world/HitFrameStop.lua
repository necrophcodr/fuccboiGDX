local Class = require (mogamett_path .. '/libraries/classic/classic')
local HitFrameStop = Class:extend()

function HitFrameStop:hitFrameStopNew()
    self.frame_stopped = false
    self.frames_left = 0
end

function HitFrameStop:hitFrameStopUpdate(dt)
    self.frames_left = math.max(self.frames_left - 1, 0)
    if self.frames_left <= 0 then self.frame_stopped = false
    else self.frame_stopped = true end
end

function HitFrameStop:hitFrameStopAdd(number_of_frames)
    if self.frames_left < number_of_frames then
        self.frames_left = number_of_frames
    end
end

return HitFrameStop
