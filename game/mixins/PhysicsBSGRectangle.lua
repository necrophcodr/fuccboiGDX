PhysicsBSGRectangle = {
    physicsBSGRectangleInit = function(self, world, x, y, body_type, w, h, s, other)
        self.w = w
        self.h = h
        self.body = love.physics.newBody(world, x, y, body_type)
        self.shape = love.physics.newPolygonShape(
            -w/2, -h/2 + s, -w/2 + s, -h/2,
             w/2 - s, -h/2, w/2, -h/2 + s,
             w/2, h/2 - s, w/2 - s, h/2,
            -w/2 + s, h/2, -w/2, h/2 - s
        )

        if other then
            self.fixture = love.physics.newFixture(self.body, self.shape)
            self.fixture:setCategory(unpack(collision_masks[other].categories))
            self.fixture:setMask(unpack(collision_masks[other].masks))
            self.fixture:setUserData(self)
        else
            self.fixture = love.physics.newFixture(self.body, self.shape)
            self.fixture:setCategory(unpack(collision_masks[self.class.name].categories))
            self.fixture:setMask(unpack(collision_masks[self.class.name].masks))
            self.fixture:setUserData(self)
        end

        self.sensor = love.physics.newFixture(self.body, self.shape)
        self.sensor:setSensor(true)
        self.sensor:setUserData(self)
    end,

    physicsBSGRectangleDraw = function(self)
        love.graphics.setColor(64, 128, 244)
        love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
        love.graphics.setColor(255, 255, 255)
    end
}
