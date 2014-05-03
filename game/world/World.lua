require 'game/world/Collision'
require 'game/world/Render'
require 'game/world/Factory'
require 'game/world/Group'
require 'game/world/CameraShake'
require 'game/world/HitFrameStop'
require 'game/world/Query'
require 'game/world/Particle'

World = class('World')
World:include(Collision)
World:include(Render)
World:include(Factory)
World:include(Query)
World:include(CameraShake)
World:include(HitFrameStop)
World:include(Particle)

function World:init(game)
    self.game = game
    self.id = getUID()
    self:collisionInit()
    self:renderInit()
    self:factoryInit()
    self:queryInit()
    self:cameraShakeInit()
    self:hitFrameStopInit()
    self:particleInit()
    self.world = self.game.world
    self.world:setCallbacks(self.collisionOnEnter, self.collisionOnExit, self.collisionPre)
    self.groups = {}
    self.entities = {}
    self.player = nil
    self.frame_n = 0
    self.stopped = false

    for class_name, _ in pairs(classes) do self:addGroup(class_name) end
    for class_name, collision_list in pairs(collision_table) do
        for _, collision_info in ipairs(collision_list) do
            if collision_info.type == 'enter' then self:addCollisionEnter(class_name, collision_info.other, 'handleCollisions', collision_info.physical) end
            if collision_info.type == 'exit' then self:addCollisionExit(class_name, collision_info.other, 'handleCollisions', collision_info.physical) end
            if collision_info.type == 'pre' then self:addCollisionPre(class_name, collision_info.other, 'handleCollisions', collision_info.physical) end
        end
    end

    self:createToGroup('Player', 120, 120)
    self:createPostWorldStep()
    for _, group in ipairs(self.groups) do
        if group.name == 'Player' then
            self.player = group:getEntities()[1]
        end
    end

    self:generateMap(mapn)
end

function World:generateMap(n)
    if n == 1 then
        local bottom_vertices = {}
        local top_vertices = {}
        for i = 1, 2*math.floor(2040/5) do
            -- y
            if i % 2 == 0 then
                if i == 2 then table.insert(bottom_vertices, rng:random(144, 192))
                else 
                    table.insert(bottom_vertices, math.min(192, math.max(144, bottom_vertices[i-2] + rng:random(-rng:random(0, 4), rng:random(0, 4)))))
                end
            -- x
            else table.insert(bottom_vertices, -700 + math.floor(i/2)*5) end
        end
        for i = 1, 2*math.floor(2040/5) do
            -- y
            if i % 2 == 0 then
                if i == 2 then table.insert(top_vertices, rng:random(48, 96))
                else
                    table.insert(top_vertices, math.max(48, math.min(96, top_vertices[i-2] + rng:random(-rng:random(0, 4), rng:random(0, 4)))))
                end
            -- x
            else table.insert(top_vertices, -700 + math.floor(i/2)*5) end
        end
        self:createToGroup('Solid', 640, 0, {vertices = bottom_vertices, bottom = true})
        self:createToGroup('Solid', 640, 0, {vertices = top_vertices, top = true})
        self:createToGroup('Item', 1140, 120, {name = 'linumllum'})
        self:createToGroup('Enemy', 1200, 120)
        local r = math.random(4, 10)
        for i = 1, r do 
            if math.random(1, 3) > 1 then
                self:createToGroup('Enemy', 1200 + i*(800/r), 120) 
            else
                for j = 1, math.random(2, 4) do
                    self:createToGroup('Enemy', 1200 + i*(800/r) + math.prandom(-5, 5), 120) 
                end
            end
        end
    elseif n == 2 then 
        local bottom_vertices = {}
        local top_vertices = {}
        for i = 1, 2*math.floor(2040/5) do
            -- y
            if i % 2 == 0 then
                if i == 2 then table.insert(bottom_vertices, rng:random(144, 192))
                else 
                    table.insert(bottom_vertices, math.min(192, math.max(144, bottom_vertices[i-2] + rng:random(-rng:random(0, 4), rng:random(0, 4)))))
                end
            -- x
            else table.insert(bottom_vertices, -700 + math.floor(i/2)*5) end
        end
        for i = 1, 2*math.floor(2040/5) do
            -- y
            if i % 2 == 0 then
                if i == 2 then table.insert(top_vertices, rng:random(48, 96))
                else
                    table.insert(top_vertices, math.max(48, math.min(96, top_vertices[i-2] + rng:random(-rng:random(0, 4), rng:random(0, 4)))))
                end
            -- x
            else table.insert(top_vertices, -700 + math.floor(i/2)*5) end
        end
        self:createToGroup('Solid', 640, 0, {vertices = bottom_vertices, bottom = true})
        self:createToGroup('Solid', 640, 0, {vertices = top_vertices, top = true})
        self:createToGroup('Flash', 60, 120, {fast = true, size = 200, permanent = true})
        self:createToGroup('Item', 500, 120, {name = table.random({'byggllum', 'haereollum', 'llumkir'})})
        local r = math.random(16, 24)
        for i = 1, r do 
            if math.random(1, 3) > 2 then
                self:createToGroup('Enemy', 600 + i*(1400/r), 120) 
            else
                for j = 1, math.random(2, 4) do
                    self:createToGroup('Enemy', 600 + i*(1400/r) + math.prandom(-5, 5), 120) 
                end
            end
        end

    elseif n >= 3 then
        local bottom_vertices = {}
        local top_vertices = {}
        for i = 1, 2*math.floor(2040/5) do
            -- y
            if i % 2 == 0 then
                if i == 2 then table.insert(bottom_vertices, rng:random(144, 192))
                else 
                    table.insert(bottom_vertices, math.min(192, math.max(144, bottom_vertices[i-2] + rng:random(-rng:random(0, 4), rng:random(0, 4)))))
                end
            -- x
            else table.insert(bottom_vertices, -700 + math.floor(i/2)*5) end
        end
        for i = 1, 2*math.floor(2040/5) do
            -- y
            if i % 2 == 0 then
                if i == 2 then table.insert(top_vertices, rng:random(48, 96))
                else
                    table.insert(top_vertices, math.max(48, math.min(96, top_vertices[i-2] + rng:random(-rng:random(0, 4), rng:random(0, 4)))))
                end
            -- x
            else table.insert(top_vertices, -700 + math.floor(i/2)*5) end
        end
        self:createToGroup('Solid', 640, 0, {vertices = bottom_vertices, bottom = true})
        self:createToGroup('Solid', 640, 0, {vertices = top_vertices, top = true})
        self:createToGroup('Flash', 60, 120, {fast = true, size = 200, permanent = true})
        self:createToGroup('Item', 500, 120, {name = table.random({'byggllum', 'haereollum', 'llumkir'})})
        local r = math.random(16+2*n, 24+2*n)
        for i = 1, r do 
            if math.random(1, 3) > 2 then
                self:createToGroup('Enemy', 600 + i*(1400/r), 120) 
            else
                for j = 1, math.random(2+2*n, 4+2*n) do
                    self:createToGroup('Enemy', 600 + i*(1400/r) + math.prandom(-5, 5), 120) 
                end
            end
        end
    end
end

function World:mapChange(n)
    for _, entity in ipairs(self:getAllEntities()) do 
        if entity.class.name ~= 'Player' then
            entity.dead = true 
        end
    end
    for _, group in ipairs(self.groups) do group:removePostWorldStep() end
    self:removePostWorldStep()

    self.player.body:setPosition(60, 120)
    self.player.map_change = false
    self:generateMap(n)
    for i = 1, self.player.hp do self:createToGroup('HPNode', self.player.x, 500) end
    for i = 1, self.player.ammo do self:createToGroup('AmmoNode', self.player.x, 500) end
    self:createToGroup('Flash', 0, 0, {follow_camera_left = true, size = 60, permanent = true})
    self:createToGroup('Flash', 0, 0, {follow_camera_right = true, size = 60, permanent = true})
end

--[[
timer:every(8, function()
    local solids = self:getEntitiesFromGroup('Solid')
    local s = nil
    for _, solid in ipairs(solids) do
        if solid.top then s = solid; break end
    end
    local points = {s.shape:getPoints()}
    local chosen_points = {}
    for i = 1, #points, 2 do
        if points[i] >= self.player.x - 64 and points[i] <= self.player.x + 64 then
            table.insert(chosen_points, {x = points[i], y = points[i+1]})
        end
    end
    local point = chosen_points[math.random(1, #chosen_points)]
    self:createToGroup('Enemy', point.x, point.y)
end)
]]--

function World:update(dt)
    if self.stopped then return end
    self:hitFrameStopUpdate(dt)
    if self.frame_stopped then return end
    if not self.player_dead then
        for _, group in ipairs(self.groups) do group:update(dt) end
        for _, entity in ipairs(self.entities) do entity:update(dt) end
    end
    if camera_follow_player then
        if self.player then self:renderUpdate(dt, Vector(self.player.x, self.player.y))
        else self:renderUpdate(dt) end
    else self:renderUpdate(dt) end
    self:cameraShakeUpdate(dt)
    if not self.player_dead then
        self.world:update(dt)
    end
    self:createPostWorldStep()
    self:removePostWorldStep()
    self:remove()
    for _, group in ipairs(self.groups) do 
        group:removePostWorldStep() 
        group:actionPostWorldStep()
    end
end

function World:stop(duration)
    if self.stopped then return end
    self.stopped = true
    timer:after(duration, function() self.stopped = false end)
end

function World:beforeAllGroupDraw()
    for _, group_ro in ipairs(self.before_all_groups) do
        for _, group in ipairs(self.groups) do
            if group.name == group_ro then
                group:draw()
            end
        end
    end
end

function World:draw()
    self:renderAttach()
    self:renderDraw()
    self:renderDetach()
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

function World:getUIDS()
    local uids = {}
    for _, group in ipairs(self.groups) do
        local group_entities = group:getEntities()
        for _, group_entity in ipairs(group_entities) do
            table.insert(uids, group_entity.id)
        end
    end
    return uids
end

function World:getEntityByName(name)
    for _, group in ipairs(self.groups) do
        local group_entities = group:getEntities()
        for _, group_entity in ipairs(group_entities) do
            if group_entity.name == name then
                return group_entity
            end
        end
    end
end

function World:add(entity)
    table.insert(self.entities, entity)
end

function World:remove(id)
    table.remove(self.entities, findIndexByID(self.entities, id))
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

function World:getEntitiesFromGroup(group_name)
    local entities = {}
    for _, group in ipairs(self.groups) do
        if group.name == group_name then
            entities = group:getEntities()
            return entities
        end
    end
end

function World:removeGroup(group_name)
    for i, group in ipairs(self.groups) do
        if group.name == group_name then
            group:destroy()
            table.remove(self.groups, i)
            return
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
            if self.entities[i].class:includes(Timer) then self.entities[i]:timerDestroy() end
            if self.entities[i].class:includes(PhysicsRectangle) or self.entities[i].class:include(PhysicsCircle) or 
               self.entities[i].class:include(PhysicsBSGRectangle) or self.entities[i].class:includes(PhysicsPolygon) then
                self.entities[i].fixture:setUserData(nil)
                self.entities[i].sensor:setUserData(nil)
                self.entities[i].body:destroy()
                self.entities[i].fixture = nil
                self.entities[i].sensor = nil
                self.entities[i].body = nil
            end
            self.entities[i].world = nil
            self:remove(self.entities[i].id)
        end
    end
end

function World:destroy()
    for _, group in ipairs(self.groups) do
        group:apply(function(entity)
            entity.dead = true
        end)
    end
    for i, group in ipairs(self.groups) do 
        group:removePostWorldStep() 
        group:destroy()
    end
    for i, entity in ipairs(self.entities) do
        entity.dead = true
    end
    self:removePostWorldStep()
    self.entities = nil
    self.groups = nil
    self.player = nil
    self.camera = nil
    self.groups = nil
    self.world = nil
end

function World:keypressed(key)
    if not self.player then return end
    self.player:keypressed(key)
end

function World:keyreleased(key)
    if not self.player then return end
    self.player:keyreleased(key)
end

function World:mousepressed(x, y, button)
    if not self.player then return end
    if button == 'r' then
        if not self.first_click then 
            self.first_click = true
            timer:tween(2, self, {arrow_alpha = 255}, 'in-out-cubic')
            timer:after(2, function() timer:tween(20, self, {arrow_alpha = 0}, 'in-out-cubic') end)
        end
    end
    if button == 'l' then
        if self.player_dead then
            if not self.can_restart_click then return end
            for _, entity in ipairs(self:getAllEntities()) do 
                if entity.class.name ~= 'Player' then
                    entity.dead = true 
                end
            end
            for _, group in ipairs(self.groups) do group:removePostWorldStep() end
            self:removePostWorldStep()

            self.player.body:setPosition(120, 120)
            self.player.map_change = false
            mapn = 1
            self:generateMap(1)
            self.keys_alpha = 0
            self.keys_text = 'click, A, D, space'
            self.arrow_alpha = 0
            self.arrow_text = '----->'
            self.survive_text = 'survive'
            self.first_click = false
            timer:tween(5, self, {keys_alpha = 255}, 'in-out-cubic')
            timer:after(5, function() timer:tween(20, self, {keys_alpha = 0}, 'in-out-cubic') end)
            self.sanity = false
            self.sanity_alpha = 0
            self.sanity_text = 'the depths are dark and full of terrors'
            self.hp_alpha = 0
            self.hp_text = '<-hp'
            self.ammo_text = '->mana'
            self.arrow_alpha_2 = 0
            self.keep_going = false
            self.hp_ammo = false
            self.depth = 0 
            self.player_dead = false
            self.can_restart_click = false
            self.dead_alpha = 0
            self.dead_text = 'you died, click to restart'
        end
    end
    self.player:mousepressed(x, y, button)
end

function World:mousereleased(x, y, button)
    if not self.player then return end
    self.player:mousereleased(x, y, button)
end

function World:gamepadpressed(button)
    self.player:gamepadpressed(button)
end

function World:gamepadreleased(button)
    self.player:gamepadreleased(button)
end
