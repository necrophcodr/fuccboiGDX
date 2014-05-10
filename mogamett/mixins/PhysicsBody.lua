local PhysicsBody = {
    physicsBodyInit = function(self, world, x, y, settings)
        settings = settings or {}
        self.body = love.physics.newBody(world, x, y, settings.body_type or 'dynamic')
        self.body:setFixedRotation(true)
        self.shape_name = string.lower(settings.shape) or 'rectangle'
        if self.shape_name == 'bsgrectangle' then
            local w, h, s = settings.w or 32, settings.h or 32, settings.s or 4
            self.w, self.h = w, h
            self.shape = love.physics.newPolygonShape(
                -w/2, -h/2 + s, -w/2 + s, -h/2,
                 w/2 - s, -h/2, w/2, -h/2 + s,
                 w/2, h/2 - s, w/2 - s, h/2,
                -w/2 + s, h/2, -w/2, h/2 - s
            )
        elseif self.shape_name == 'rectangle' then
            self.w, self.h = settings.w or 32, settings.h or 32
            self.shape = love.physics.newRectangleShape(settings.w or 32, settings.h or 32)
        elseif self.shape_name == 'polygon' then
            self.shape = love.physics.newPolygonShape(unpack(settings.vertices))
        elseif self.shape_name == 'chain' then
            self.shape = love.physics.newChainShape(settings.loop or false, unpack(settings.vertices))
        elseif self.shape_name == 'circle' then
            self.r = settings.r or 16
            self.w, self.h = settings.r or 32, settings.r or 32
            self.shape = love.physics.newCircleShape(settings.r or 16)
        end

        local name = settings.other or self.class.name
        self.fixture = love.physics.newFixture(self.body, self.shape)
        self.fixture:setCategory(unpack(self.world.mm.Collision.masks[self.class.name].categories))
        self.fixture:setMask(unpack(self.world.mm.Collision.masks[self.class.name].masks))
        self.fixture:setUserData(self)
        self.sensor = love.physics.newFixture(self.body, self.shape)
        self.sensor:setSensor(true)
        self.sensor:setUserData(self)
    end,

    physicsBodyUpdate = function(self, dt)
        self.x, self.y = self.body:getPosition()
    end,

    physicsBodyDraw = function(self)
        if self.world.mm.debug_draw then
            if self.shape_name == 'bsgrectangle' or self.shape_name == 'polygon' or self.shape_name == 'rectangle' then
                love.graphics.setColor(64, 128, 244)
                love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
                love.graphics.setColor(255, 255, 255)
            elseif self.shape_name == 'chain' then
                love.graphics.setColor(64, 128, 244)
                local points = {self.body:getWorldPoints(self.shape:getPoints())}
                for i = 1, #points, 2 do
                    if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
                end
                love.graphics.setColor(255, 255, 255)
            elseif self.shape_name == 'circle' then
                love.graphics.setColor(64, 128, 244)
                local x, y = self.body:getPosition()
                love.graphics.circle('line', x, y, self.r, 360)
                love.graphics.setColor(255, 255, 255)
            end
        end
    end,
    
    handleCollisions = function(self, type, object, contact, ni1, ti1, ni2, ti2)
        if type == 'pre' then
            if self.preSolve then
                self:preSolve(object, contact)
            end
        elseif type == 'post' then
            if self.postSolve then
                self:postSolve(object, contact, ni1, ti1, ni2, ti2)
            end
        elseif type == 'enter' then
            if self.onCollisionEnter then
                self:onCollisionEnter(object, contact)
            end
        elseif type == 'exit' then
            if self.onCollisionExit then
                self:onCollisionExit(object, contact)
            end
        end
    end,
}

return PhysicsBody
