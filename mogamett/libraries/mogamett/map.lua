local map = {}
map.__index = map

local function new()
    
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
