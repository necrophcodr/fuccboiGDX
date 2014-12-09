local Entity = require(fuccboi_path .. '/entities/Entity')
local PhysicsBody = require (fuccboi_path .. '/mixins/PhysicsBody')
local Solid = Entity:extend('Solid')
Solid:implement(PhysicsBody)

function Solid:new(area, x, y, settings)
    Solid.super.new(self, area, x, y, settings)
    self:physicsBodyNew(area, x, y, settings)
end

function Solid:update(dt)
    self:physicsBodyUpdate(dt)
end

function Solid:draw()
    self:physicsBodyDraw()
end

return Solid
