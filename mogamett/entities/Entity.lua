local class = require (mogamett_path .. '/libraries/middleclass/middleclass')
local Entity = class('Entity')

function Entity:init(world, x, y, settings)
    self.dead = false
    self.world = world
    self.id = self.world.mm.getUID()
    self.x = x
    self.y = y
    if settings then
        for k, v in pairs(settings) do self[k] = v end
    end
end

return Entity
