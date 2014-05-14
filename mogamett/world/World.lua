local Collision = require (mogamett_path .. '/world/Collision')
local Render = require (mogamett_path .. '/world/Render')
local Factory = require (mogamett_path .. '/world/Factory')
local Group = require (mogamett_path .. '/world/Group')
local HitFrameStop = require (mogamett_path .. '/world/HitFrameStop')
local Query = require (mogamett_path .. '/world/Query')
local Particle = require (mogamett_path .. '/world/Particle')

local class = require (mogamett_path .. '/libraries/middleclass/middleclass')
local World = class('World')
World:include(Collision)
World:include(Render)
World:include(Factory)
World:include(Query)
World:include(HitFrameStop)
World:include(Particle)

function World:init(mg)
    self.mg = mg
    self.id = self.mg.getUID()
    self:collisionInit()
    self:renderInit()
    self:factoryInit()
    self:queryInit()
    self:hitFrameStopInit()
    self:particleInit()
    love.physics.setMeter(32)
    self.world = love.physics.newWorld(0, 0) 
    self.world:setCallbacks(self.collisionOnEnter, self.collisionOnExit, self.collisionPre, self.collisionPost)
    self.groups = {}
    self.entities = {}
    self.stopped = false

    for class_name, _ in pairs(self.mg.classes) do self:addGroup(class_name) end
    local collision_table = self.mg.Collision:getCollisionCallbacksTable()
    for class_name, collision_list in pairs(collision_table) do
        for _, collision_info in ipairs(collision_list) do
            if collision_info.type == 'enter' then 
                self:addCollisionEnter(class_name, collision_info.other, 'handleCollisions', collision_info.physical) 
            end
            if collision_info.type == 'exit' then 
                self:addCollisionExit(class_name, collision_info.other, 'handleCollisions', collision_info.physical) 
            end
            if collision_info.type == 'pre' then 
                self:addCollisionPre(class_name, collision_info.other, 'handleCollisions', collision_info.physical) 
            end
            if collision_info.type == 'post' then 
                self:addCollisionPre(class_name, collision_info.other, 'handleCollisions', collision_info.physical) 
            end
        end
    end
end

function World:update(dt)
    if self.stopped then return end
    self:hitFrameStopUpdate(dt)
    if self.frame_stopped then return end
    for _, group in ipairs(self.groups) do group:update(dt) end
    for _, entity in ipairs(self.entities) do entity:update(dt) end
    self:renderUpdate(dt)
    self.world:update(dt)
    self:createPostWorldStep()
    self:removePostWorldStep()
    for _, group in ipairs(self.groups) do 
        group:removePostWorldStep() 
    end
end

function World:draw()
    self:renderAttach()
    self:renderDraw()
    self:renderDetach()
    self.camera:debugDraw()
end

function World:getAllEntities()
    local entities = {}
    for _, group in ipairs(self.groups) do
        local group_entities = group:getEntities()
        for _, group_entity in ipairs(group_entities) do
            table.insert(entities, group_entity)
        end
    end
    return entities
end

function World:addGroup(group_name)
    table.insert(self.groups, Group(group_name))
end

function World:addToGroup(group_name, entity)
    for _, group in ipairs(self.groups) do
        if group.name == group_name then
            group:add(entity)
            return
        end
    end
end

function World:getEntityById(id)
    for _, group in ipairs(self.groups) do
        local group_entities = group:getEntities()
        for _, group_entity in ipairs(group_entities) do
            if group_entity.id == id then
                return group_entity
            end
        end
    end
end

function World:getEntitiesFromGroup(group_name)
    local entities = {}
    for _, group in ipairs(self.groups) do
        if group.name == group_name then
            entities = group:getEntities()
            return entities
        end
    end
end

function World:removeFromGroup(group_name, id)
    for _, group in ipairs(self.groups) do
        if group.name == group_name then
            group:remove(id)
            return
        end
    end
end

function World:removePostWorldStep()
    for i = #self.entities, 1, -1 do
        if self.entities[i].dead then
            if self.entities[i].timer then self.entities[i].timer:destroy() end
            if self.entities[i].class:includes(PhysicsBody) then 
                if self.entities[i].fixture then self.entities[i].fixture:setUserData(nil) end
                if self.entities[i].sensor then self.entities[i].sensor:setUserData(nil) end
                if self.entities[i].body then self.entities[i].body:destroy() end
                self.entities[i].fixture = nil
                self.entities[i].sensor = nil
                self.entities[i].body = nil
            end
            self.entities[i].world = nil
        end
    end
end

function World:destroy()
    for _, group in ipairs(self.groups) do
        group:apply(function(entity) entity.dead = true end)
    end
    self:renderUpdate(0)
    for i, group in ipairs(self.groups) do 
        group:removePostWorldStep() 
        group:destroy()
    end
    for i, entity in ipairs(self.entities) do
        entity.dead = true
    end
    self:removePostWorldStep()
    self.entities = {}
    self.groups = {}
end

return World
