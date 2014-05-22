local class = require (mogamett_path .. '/libraries/middleclass/middleclass')
local Entity = require(mogamett_path .. '/entities/Entity')
local Solid = class('Solid', Entity)
local PhysicsBody = require (mogamett_path .. '/mixins/PhysicsBody')
Solid:include(PhysicsBody)

function Solid:init(world, x, y, settings)
    Entity.init(self, world, x, y, settings)
    self:physicsBodyInit(world, x, y, settings)
end

function Solid:update(dt)
    self:physicsBodyUpdate(dt)
end

function Solid:draw()
    self:physicsBodyDraw()
end

return Solid
