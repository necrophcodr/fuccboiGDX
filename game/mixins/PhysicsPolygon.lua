PhysicsPolygon = {
    physicsPolygonInit = function(self, world, x, y, vertices, body_type)
        self.body = love.physics.newBody(world, x, y, body_type)
        self.shape = love.physics.newPolygonShape(unpack(vertices))
        self.new_vertices = nil

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

    physicsPostUpdateVertices = function(self, vertices)
        self.new_vertices = vertices
    end,

    physicsPolygonVertices = function(self)
        if not self.new_vertices then return end
        local angle = self.body:getAngle()
        self.body:destroy()
        self.body = love.physics.newBody(self.world.world, self.x, self.y, 'dynamic')
        self.shape = love.physics.newPolygonShape(unpack(self.new_vertices))
        self.new_vertices = nil

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

        self.body:setAngle(angle)
    end,

    physicsPolygonDraw = function(self)
        if debug_draw then
            love.graphics.setColor(64, 128, 244)
            love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
            love.graphics.setColor(255, 255, 255)
        end
    end
}
