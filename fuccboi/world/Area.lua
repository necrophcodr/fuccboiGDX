local Factory = require (fuccboi_path .. '/world/Factory')
local Group = require (fuccboi_path .. '/world/Group')
local HitFrameStop = require (fuccboi_path .. '/world/HitFrameStop')
local Query = require (fuccboi_path .. '/world/Query')
local Particle = require (fuccboi_path .. '/world/Particle')
local Tilemap = require (fuccboi_path .. '/world/Tilemap')
local Pool = require (fuccboi_path .. '/world/Pool')

local utils = require (fuccboi_path .. '/libraries/fuccboi/utils')

local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Area = Class:extend()
Area:implement(Factory)
Area:implement(Query)
Area:implement(HitFrameStop)
Area:implement(Particle)
Area:implement(Tilemap)

function Area:new(world, x, y, settings)
    self.fg = world.fg
    self.id = self.fg.getUID()

    self.world = world
    self.x = x
    self.y = y
    
    self.active = false

    self:factoryNew()
    self:queryNew()
    self:hitFrameStopNew()
    self:particleNew()
    self:tilemapNew()

    self.pools = {}
    self.groups = {}
    for class_name, _ in pairs(self.fg.classes) do self:addGroup(class_name) end
end

function Area:update(dt)
    self:hitFrameStopUpdate(dt)
    for _, group in ipairs(self.groups) do 
        if self.frame_stopped then
            if not self.fg.fn.contains(self.groups_stopped, group.name) then group:update(dt) end
        else group:update(dt) end
    end

    self:particleUpdate(dt)
    self:createPostWorldStep()
    for _, group in ipairs(self.groups) do group:removePostWorldStep() end
end

function Area:draw()
    
end

function Area:save()
    
end

function Area:load(data)
    
end

function Area:activate()
    self.active = true
end

function Area:deactivate()
    self.active = false
end

function Area:initializePools()
    for class_name, _ in pairs(self.fg.classes) do 
        if self.fg.classes[class_name].pool_enabled then
            self.pools[class_name] = Pool(self, class_name, self.fg.classes[class_name].pool_enabled, 
                                          self.fg.classes[class_name].pool_overflow_rule)
        end
    end
end

function Area:getAllEntities()
    local entities = {}
    for _, group in ipairs(self.groups) do
        local group_entities = group:getEntities()
        for _, group_entity in ipairs(group_entities) do
            table.insert(entities, group_entity)
        end
    end
    return entities
end

function Area:addGroup(group_name)
    table.insert(self.groups, Group(group_name))
end

function Area:addToGroup(group_name, entity)
    for _, group in ipairs(self.groups) do
        if group.name == group_name then
            group:add(entity)
            return
        end
    end
end

function Area:getEntityById(id)
    for _, group in ipairs(self.groups) do
        local group_entities = group:getEntities()
        for _, group_entity in ipairs(group_entities) do
            if group_entity.id == id then
                return group_entity
            end
        end
    end
end

function Area:getEntitiesFromGroups(group_names)
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

function Area:removeFromGroup(group_name, id)
    for _, group in ipairs(self.groups) do
        if group.name == group_name then
            group:remove(id)
            return
        end
    end
end

function Area:destroy()
    for _, group in ipairs(self.groups) do group:apply(function(entity) entity.dead = true end) end
    self.fg.world:renderUpdate(0)
    for i, group in ipairs(self.groups) do 
        group:removePostWorldStep() 
        group:destroy()
    end
    self.groups = {}
end

return Area
