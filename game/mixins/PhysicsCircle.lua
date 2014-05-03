PhysicsCircle = {
    physicsCircleInit = function(self, world, x, y, body_type, r, other)
        self.r = r
        self.w = 2*r
        self.h = 2*r
        self.body = love.physics.newBody(world, x, y, body_type)
        self.shape = love.physics.newCircleShape(r)

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

    physicsCircleDraw = function(self)
        if debug_draw then
            love.graphics.setColor(64, 128, 244)
            local x, y = self.body:getPosition()
            love.graphics.circle('line', x, y, self.r, 360)
            love.graphics.setColor(255, 255, 255)
        end
    end
}
