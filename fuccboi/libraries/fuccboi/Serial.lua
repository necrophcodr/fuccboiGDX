local Serial = {}
Serial.__index = Serial

local ser = require (fuccboi_path .. '/libraries/ser/ser')

function Serial.new()
    local self = {}
    self.ser = ser
    return setmetatable(self, Serial)
end

function Serial:loadArea(filename, area)
    
end

function Serial:loadObject(filename, area)
    
end

function Serial:saveArea(filename, area, dropped_classes)
    
end

function Serial:saveObject(filename, object)
    if object.save then
        local data = object:save()
        self.ser.serialize(data) 

    end
end

return setmetatable({new = new}, {__call = function(_, ...) return Serial.new(...) end})
