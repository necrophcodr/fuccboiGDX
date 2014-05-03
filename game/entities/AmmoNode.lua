classes['AmmoNode'] = class('AmmoNode', Entity); local AmmoNode = classes['AmmoNode']
AmmoNode:include(PhysicsRectangle)
AmmoNode:include(Particler)
AmmoNode:include(Steerable)

function AmmoNode:init(world, x, y, settings)
    Entity.init(self, world, x, y, settings)
    self:physicsRectangleInit(self.world.world, x, y, 'dynamic', 4, 4)
    self:steerableInit(0, 0, 200, 1000, 2)
    self:particlerInit()
end

function AmmoNode:update(dt)
    self.x, self.y = self.body:getPosition()
    local cx, cy = self.world.camera:pos()
    self.target = Vector(cx + 160 - 20, cy + 120 - 20)
    self.current_behavior = 'seek'
    self:steerableUpdate(dt)
    self:particlerUpdate(dt)
end

function AmmoNode:draw()
    self:physicsRectangleDraw()
    self:particlerDraw()
    love.graphics.setColor(32, 64, 222)
    love.graphics.circle('fill', self.x, self.y, 5 + math.random(-1, 1), 24)
    love.graphics.setColor(255, 255, 255, 255)
end
