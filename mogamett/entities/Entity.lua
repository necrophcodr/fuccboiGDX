local Class = require (mogamett_path .. '/libraries/classic/classic')
local Entity = Class:extend('Entity') 

function Entity:new(world, x, y, settings)
    self.dead = false
    self.world = world
    self.id = self.world.mg.getUID()
    self.x = x
    self.y = y
    if settings then
        for k, v in pairs(settings) do self[k] = v end
    end
end

return Entity
