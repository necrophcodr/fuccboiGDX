Rock = mg.class('Rock', mg.Entity)
Rock:include(mg.PhysicsBody)

function Rock:init(world, x, y, settings)
    mg.Entity.init(self, world, x, y, settings)
    self:physicsBodyInit(world, x, y, settings)
    self.body:setFixedRotation(false)
    self.fixture:setRestitution(0.5)

    self.body:applyLinearImpulse(mg.utils.math.random(-1, 1), mg.utils.math.random(-1, 1))

    self.rock_type = settings.rock_type or mg.utils.table.random({1, 2})
    self.visual = rocks[self.rock_type]
end

function Rock:update(dt)
    self:physicsBodyUpdate(dt)

    if mg.input:down('attract') then
        local mx, my = love.mouse.getPosition()
        local d = mg.Vector(self.x, self.y):dist(mg.Vector(mx, my))
        self.body:applyForce(24*(mx - self.x)/d, 24*(my - self.y)/d)
    end

    if mg.input:down('repulse') then
        local mx, my = love.mouse.getPosition()
        local d = mg.Vector(self.x, self.y):dist(mg.Vector(mx, my))
        self.body:applyForce(256*(self.x - mx)/d, 256*(self.y - my)/d)
    end
end

function Rock:draw()
    self:physicsBodyDraw()
    mg.utils.graphics.pushRotate(self.x, self.y, self.body:getAngle())
    love.graphics.draw(self.visual, self.x - self.visual:getWidth()/2, self.y - self.visual:getHeight()/2)
    love.graphics.pop()
end
