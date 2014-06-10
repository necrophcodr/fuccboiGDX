local Entity = require(mogamett_path .. '/entities/Entity')
local Solid = Entity:extend('Solid')
local PhysicsBody = require (mogamett_path .. '/mixins/PhysicsBody')
Solid:implement(PhysicsBody)

function Solid:new(world, x, y, settings)
    Solid.super.new(self, world, x, y, settings)
    self:physicsBodyNew(world, x, y, settings)
end

function Solid:update(dt)
    self:physicsBodyUpdate(dt)
end

function Solid:draw()
    self:physicsBodyDraw()
end

return Solid
