local Class = require (mogamett_path .. '/libraries/classic/classic')
local PhysicsBody = Class:extend()  

function PhysicsBody:physicsBodyNew(world, x, y, settings)
    self.bodies = {}
    self.shapes = {}
    self.fixtures = {}
    self.sensors = {}
    self.joints = {}

    self:addBody(world, x, y, settings)
end

function PhysicsBody:addBody(world, x, y, settings)
    settings = settings or {}

    local body = love.physics.newBody(world.world, x, y, settings.body_type or 'dynamic')
    body:setFixedRotation(true)

    settings.shape = settings.shape or 'rectangle'
    local shape = nil
    local shape_name = string.lower(settings.shape)
    local body_w, body_h, body_r = 0, 0, 0

    if shape_name == 'bsgrectangle' then
        local w, h, s = settings.w or 32, settings.h or 32, settings.s or 4
        body_w, body_h = w, h
        shape = love.physics.newPolygonShape(
            -w/2, -h/2 + s, -w/2 + s, -h/2,
             w/2 - s, -h/2, w/2, -h/2 + s,
             w/2, h/2 - s, w/2 - s, h/2,
            -w/2 + s, h/2, -w/2, h/2 - s
        )

    elseif shape_name == 'rectangle' then
        body_w, body_h = settings.w or 32, settings.h or 32
        shape = love.physics.newRectangleShape(settings.w or 32, settings.h or 32)

    elseif shape_name == 'polygon' then
        shape = love.physics.newPolygonShape(unpack(settings.vertices))

    elseif shape_name == 'chain' then
        shape = love.physics.newChainShape(settings.loop or false, unpack(settings.vertices))

    elseif shape_name == 'circle' then
        body_r = settings.r or 16
        body_w, body_h = settings.r or 32, settings.r or 32
        shape = love.physics.newCircleShape(settings.r or 16)
    end

    local mask_name = settings.collision_class or self.class_name
    local fixture = love.physics.newFixture(body, shape)
    fixture:setCategory(unpack(self.world.mg.Collision.masks[mask_name].categories))
    fixture:setMask(unpack(self.world.mg.Collision.masks[mask_name].masks))
    fixture:setUserData({object = self, mask_name = mask_name})
    local sensor = love.physics.newFixture(body, shape)
    sensor:setSensor(true)
    sensor:setUserData({object = self, mask_name = mask_name})

    table.insert(self.bodies, body)
    table.insert(self.shapes, shape)
    table.insert(self.fixtures, fixture)
    table.insert(self.sensors, sensor)

    -- Set self.---- to the first added ----
    if #self.bodies == 1 then
        self.w, self.h, self.r = body_w, body_h, body_r
        self.body = self.bodies[1]
        self.shape = self.shapes[1]
        self.fixture = self.fixtures[1]
        self.sensor = self.sensors[1]
    end
end

function PhysicsBody:addJoint(type, ...)
    local args = {...}
    local joint_name = string.lower(type)
    local joint = nil
    local joint_name_to_function_name = {
        distance = 'newDistanceJoint', friction = 'newFrictionJoint', gear = 'newGearJoint',
        mouse = 'newMouseJoint', prismatic = 'newPrismaticJoint', pulley = 'newPulleyJoint',
        revolute = 'newRevoluteJoint', rope = 'newRopeJoint', weld = 'newWeldJoint', wheel = 'newWheelJoint',
    }
    joint = love.physics[joint_name_to_function_name[joint_name]](unpack(args))
    table.insert(self.joints, joint)
end

function PhysicsBody:removeJoint(n)
    self.joints[n]:destroy()
    table.remove(self.joints, n)
end

function PhysicsBody:physicsBodyUpdate(dt)
    self.x, self.y = self.body:getPosition()
end

function PhysicsBody:physicsBodyDraw()
    self.x, self.y = self.body:getPosition()
    if not self.world.mg.debug_draw then return end

    for i = 1, #self.bodies do
        if self.shapes[i]:type() == 'PolygonShape' then
            love.graphics.setColor(64, 128, 244)
            love.graphics.polygon('line', self.bodies[i]:getWorldPoints(self.shapes[i]:getPoints()))
            love.graphics.setColor(255, 255, 255)

        elseif self.shapes[i]:type() == 'EdgeShape' then
            love.graphics.setColor(64, 128, 244)
            local points = {self.bodies[i]:getWorldPoints(self.shapes[i]:getPoints())}
            for i = 1, #points, 2 do
                if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
            end
            love.graphics.setColor(255, 255, 255)

        elseif self.shapes[i]:type() == 'CircleShape' then
            love.graphics.setColor(64, 128, 244)
            local x, y = self.bodies[i]:getPosition()
            love.graphics.circle('line', x, y, self.r, 360)
            love.graphics.setColor(255, 255, 255)
        end
    end

    for i = 1, #self.joints do
        local x1, y1, x2, y2 = self.joints[i]:getAnchors()
        love.graphics.setPointSize(8)
        love.graphics.setColor(244, 128, 64)
        love.graphics.point(x1, y1)
        love.graphics.setColor(128, 244, 64)
        love.graphics.point(x2, y2)
        love.graphics.setColor(255, 255, 255)
        love.graphics.setPointSize(1)
    end
end

function PhysicsBody:handleCollisions(type, object, contact, ni1, ti1, ni2, ti2)
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
end

return PhysicsBody
