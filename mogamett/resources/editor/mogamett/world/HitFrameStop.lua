local Class = require (mogamett_path .. '/libraries/classic/classic')
local HitFrameStop = Class:extend()

local utils = require (mogamett_path .. '/libraries/mogamett/utils')

function HitFrameStop:hitFrameStopNew()
    self.frames_left = 0
    self.groups_stopped = {}
    self.after_function = nil
end

function HitFrameStop:hitFrameStopUpdate(dt)
    self.frames_left = math.max(self.frames_left - 1, 0)
    if self.frames_left <= 0 then 
        self.frame_stopped = false
        self.groups_stopped = {}
        if self.after_function then
            self.after_function()
            self.after_function = nil
        end
    else self.frame_stopped = true end
end

function HitFrameStop:hitFrameStopAdd(number_of_frames, groups, after_function)
    if self.frames_left < number_of_frames then
        self.frames_left = number_of_frames
    end

    if groups[1] == 'All' then
        for _, group in ipairs(self.groups) do 
            if groups.except then
                if not utils.table.contains(groups.except, group.name) then
                    table.insert(self.groups_stopped, group.name) 
                end
            else table.insert(self.groups_stopped, group.name) end
        end
    else self.groups_stopped = groups end

    self.after_function = after_function
end

return HitFrameStop
