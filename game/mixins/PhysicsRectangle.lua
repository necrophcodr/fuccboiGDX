PhysicsRectangle = {
    physicsRectangleInit = function(self, world, x, y, body_type, w, h, other)
        self.w = w
        self.h = h
        self.body = love.physics.newBody(world, x, y, body_type)
        self.shape = love.physics.newRectangleShape(w, h)

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

    addFixture = function(self, x, y, w, h, other)
        self.nshape = love.physics.newRectangleShape(x, y, w, h)
        self.nfixture = love.physics.newFixture(self.body, self.nshape)
        if other then
            self.nfixture:setCategory(unpack(collision_masks[other].categories))
            self.nfixture:setMask(unpack(collision_masks[other].masks))
        else
            self.nfixture:setCategory(unpack(collision_masks[self.class.name].categories))
            self.nfixture:setMask(unpack(collision_masks[self.class.name].masks))
        end
        self.nfixture:setUserData(self)
        self.nsensor = love.physics.newFixture(self.body, self.nshape)
        self.nsensor:setSensor(true)
        self.nsensor:setUserData(self)
    end,

    physicsDestroy = function(self)
        self.fixture:setUserData(nil)
        self.sensor:setUserData(nil)
        self.body:destroy()
        self.fixture = nil
        self.sensor = nil
        self.body = nil
    end,

    physicsRectangleDraw = function(self, offset_x, offset_y)
        if debug_draw then
            love.graphics.setLineWidth(2)
            love.graphics.setColor(64, 128, 244)
            local map = function(offset_x, offset_y, ...)
                local args = {...}
                local outs = {}
                for i, arg in ipairs(args) do
                    if i % 2 == 0 then table.insert(outs, arg + offset_y)
                    else table.insert(outs, arg + offset_x) end
                end
                return unpack(outs)
            end
            love.graphics.polygon('line', map(offset_x or 0, offset_y or 0, self.body:getWorldPoints(self.shape:getPoints())))
            love.graphics.setColor(255, 255, 255)
            love.graphics.setLineWidth(1)

            if self.nshape then
                love.graphics.setColor(64, 128, 244)
                love.graphics.polygon('line', self.body:getWorldPoints(self.nshape:getPoints()))
                love.graphics.setColor(255, 255, 255)
            end
        end
    end
}
