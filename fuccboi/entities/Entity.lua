local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Entity = Class:extend('Entity') 

function Entity:new(area, x, y, settings)
    self.dead = false
    self.area = area 
    self.id = self.area.fg.getUID()
    self.pool_active = false
    self.x = x
    self.y = y
    if settings then
        for k, v in pairs(settings) do self[k] = v end
    end
end

return Entity
