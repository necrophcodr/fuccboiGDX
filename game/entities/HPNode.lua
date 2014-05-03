classes['HPNode'] = class('HPNode', Entity); local HPNode = classes['HPNode']
HPNode:include(PhysicsRectangle)
HPNode:include(Particler)
HPNode:include(Steerable)

function HPNode:init(world, x, y, settings)
    Entity.init(self, world, x, y, settings)
    self:physicsRectangleInit(self.world.world, x, y, 'dynamic', 4, 4)
    self:steerableInit(0, 0, 200, 1000, 2)
    self:particlerInit()
end

function HPNode:update(dt)
    self.x, self.y = self.body:getPosition()
    local cx, cy = self.world.camera:pos()
    self.target = Vector(cx - 160 + 20, cy + 120 - 20)
    self.current_behavior = 'seek'
    self:steerableUpdate(dt)
    self:particlerUpdate(dt)
end

function HPNode:draw()
    self:physicsRectangleDraw()
    self:particlerDraw()
    love.graphics.setColor(200, 64, 64)
    love.graphics.circle('fill', self.x, self.y, 5 + math.random(-1, 1), 24)
    love.graphics.setColor(255, 255, 255, 255)
end
