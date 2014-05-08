local PhysicsBody = {
    physicsBodyInit = function(self, world, x, y, settings)
        self.body = love.physics.newBody(world, x, y, settings.body_type or 'static')
        self.shape_name = settings.shape or 'Rectangle'
        if self.shape_name == 'BSGRectangle' then
            local w, h, s = settings.w or 32, settings.h or 32, settings.s or 4
            self.w, self.h = w, h
            self.shape = love.physics.newPolygonShape(
                -w/2, -h/2 + s, -w/2 + s, -h/2,
                 w/2 - s, -h/2, w/2, -h/2 + s,
                 w/2, h/2 - s, w/2 - s, h/2,
                -w/2 + s, h/2, -w/2, h/2 - s
            )
        elseif self.shape_name == 'Rectangle' then
            self.w, self.h = settings.w or 32, settings.h or 32
            self.shape = love.physics.newRectangleShape(settings.w or 32, settings.h or 32)
        elseif self.shape_name == 'Polygon' then
            self.shape = love.physics.newPolygonShape(unpack(settings.vertices))
        elseif self.shape_name == 'Chain' then
            self.shape = love.physics.newChainShape(settings.loop or false, unpack(settings.vertices))
        elseif self.shape_name == 'Circle' then
            self.w, self.h = settings.r or 32, settings.r or 32
            self.shape = love.physics.newCircleShape(settings.r or 16)
        end

        local name = settings.other or self.class.name
        self.fixture = love.physics.newFixture(self.body, self.shape)
        self.fixture:setCategory(unpack(self.world.mm._Collision.masks[self.class.name].categories))
        self.fixture:setMask(unpack(self.world.mm._Collision.masks[self.class.name].masks))
        self.fixture:setUserData(self)
        self.sensor = love.physics.newFixture(self.body, self.shape)
        self.sensor:setSensor(true)
        self.sensor:setUserData(self)
    end,

    physicsBodyDraw = function(self)
        if self.world.mm.debug_draw then
            if self.shape_name == 'BSGRectangle' or self.shape_name == 'Polygon' or self.shape_name == 'Rectangle' then
                love.graphics.setColor(64, 128, 244)
                love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
                love.graphics.setColor(255, 255, 255)
            elseif self.shape_name == 'Chain' then
                love.graphics.setColor(64, 128, 244)
                local points = {self.body:getWorldPoints(self.shape:getPoints())}
                for i = 1, #points, 2 do
                    if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
                end
                love.graphics.setColor(255, 255, 255)
            elseif self.shape_name == 'Circle' then
                love.graphics.setColor(64, 128, 244)
                local x, y = self.body:getPosition()
                love.graphics.circle('line', x, y, self.r, 360)
                love.graphics.setColor(255, 255, 255)
            end
        end
    end,
}

return PhysicsBody
