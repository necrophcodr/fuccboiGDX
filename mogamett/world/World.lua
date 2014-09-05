local Collision = require (mogamett_path .. '/world/Collision')
local Render = require (mogamett_path .. '/world/Render')
local Factory = require (mogamett_path .. '/world/Factory')
local Group = require (mogamett_path .. '/world/Group')
local HitFrameStop = require (mogamett_path .. '/world/HitFrameStop')
local Query = require (mogamett_path .. '/world/Query')
local Particle = require (mogamett_path .. '/world/Particle')
local Tilemap = require (mogamett_path .. '/world/Tilemap')
local Pool = require (mogamett_path .. '/world/Pool')

local utils = require (mogamett_path .. '/libraries/mogamett/utils')

local Class = require (mogamett_path .. '/libraries/classic/classic')
local World = Class:extend()
World:implement(Collision)
World:implement(Render)
World:implement(Factory)
World:implement(Query)
World:implement(HitFrameStop)
World:implement(Particle)
World:implement(Tilemap)

function World:new(mg)
    self.mg = mg
    self.id = self.mg.getUID()
    self:collisionNew()
    self:renderNew()
    self:factoryNew()
    self:queryNew()
    self:hitFrameStopNew()
    self:particleNew()
    self:tilemapNew()
    love.physics.setMeter(32)
    self.world = love.physics.newWorld(0, 0) 
    self.world:setCallbacks(self.collisionOnEnter, self.collisionOnExit, self.collisionPre, self.collisionPost)
    self.groups = {}
    self.pools = {}
    self.entities = {}
    self.stopped = false

    for class_name, _ in pairs(self.mg.classes) do self:addGroup(class_name) end

    self:collisionClear()
    self:collisionSet()
end

function World:initializePools()
    for class_name, _ in pairs(self.mg.classes) do 
        if mg.classes[class_name].pool_enabled then
            self.pools[class_name] = Pool(self, class_name, self.mg.classes[class_name].pool_enabled, self.mg.classes[class_name].pool_overflow_rule)
        end
    end
end

function World:collisionSet()
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
    for _, group in ipairs(self.groups) do 
        if self.frame_stopped then
            if not utils.table.contains(self.groups_stopped, group.name) then group:update(dt) end
        else group:update(dt) end
    end

    for _, entity in ipairs(self.entities) do entity:update(dt) end
    self:particleUpdate(dt)
    self:renderUpdate(dt)
    if not self.frame_stopped then self.world:update(dt) end
    self:createPostWorldStep()
    self:removePostWorldStep()
    for _, group in ipairs(self.groups) do group:removePostWorldStep() end
    self:collisionClear()
    self:collisionSet()
end

function World:draw()
    self:renderDraw()
    self.camera:debugDraw()
end

function World:resize(w, h)
    self:renderResize(w, h)
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

function World:getEntitiesFromGroups(group_names)
    local entities = {}
    for _, group_name in ipairs(group_names) do
        for _, group in ipairs(self.groups) do
            if group.name == group_name then
                local group_entities = group:getEntities()
                for _, entity in ipairs(group_entities) do
                    table.insert(entities, entity)
                end
            end
        end
    end
    return entities
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
            if self.entities[i].world.mg.classes[self.entities[i].class_name].pool_enabled then
                self.entities[i].world.pools[self.entities[i].class_name]:unsetObject(self.entities[i])
            else
                if self.entities[i].timer then self.entities[i].timer:destroy() end
                if self.entities[i].bodies then
                    for name, _ in pairs(self.entities[i].bodies) do
                        if self.entities[i].bodies[name]:type() == 'Body' then 
                            if self.entities[i].fixtures[name] then self.entities[i].fixtures[name]:setUserData(nil) end
                            if self.entities[i].sensors[name] then self.entities[i].sensors[name]:setUserData(nil) end
                            if self.entities[i].joints[name] then self.entities[i].joints[name]:destroy() end
                            if self.entities[i].bodies[name] then self.entities[i].bodies[name]:destroy() end
                            if j == 1 then
                                self.entities[i].fixture = nil
                                self.entities[i].sensor = nil
                                self.entities[i].body = nil
                                self.entities[i].shape = nil
                            end
                            self.entities[i].fixtures[name] = nil
                            self.entities[i].sensors[name] = nil
                            self.entities[i].joints[name] = nil
                            self.entities[i].bodies[name] = nil
                            self.entities[i].shapes[name] = nil
                        end
                    end
                end
                self.entities[i].world:removeFromRender(self.entities[i].id)
                table.remove(self.entities, i)
            end
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
