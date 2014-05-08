local class = require (mogamett_path .. '/libraries/middleclass/middleclass')
local Body = class('Body')
local PhysicsBody = require (mogamett_path .. '/mixins/PhysicsBody')
local Timer = require (mogamett_path .. '/mixins/Timer')
Body:include(PhysicsBody)
Body:include(Timer)

function Body:init(world, x, y, settings)
    self.dead = false
    self.world = world
    self.id = self.world.mm.getUID()
    self.x = x
    self.y = y
    if settings then
        for k, v in pairs(settings) do self[k] = v end
    end

    self:physicsBodyInit(self.world.world, x, y, settings)
    self:timerInit()
end

function Body:update(dt)
    self.x, self.y = self.body:getPosition()
    self:timerUpdate(dt)
end

function Body:draw()
    self:physicsBodyDraw()
end

return Body
