local Collision = require (mogamett_path .. '/world/Collision')
local Render = require (mogamett_path .. '/world/Render')
local Area = require (mogamett_path .. '/world/Area')

local utils = require (mogamett_path .. '/libraries/mogamett/utils')

local Class = require (mogamett_path .. '/libraries/classic/classic')
local World = Class:extend()
World:implement(Collision)
World:implement(Render)

function World:new(mg)
    self.mg = mg
    self.id = self.mg.getUID()

    love.physics.setMeter(32)
    self.world = love.physics.newWorld(0, 0) 
    self.world:setCallbacks(self.collisionOnEnter, self.collisionOnExit, self.collisionPre, self.collisionPost)

    self:collisionNew()
    self:renderNew()

    self:collisionClear()
    self:collisionSet()

    self.areas = {}
end

function World:createArea(area_name, x, y, settings)
    if not self.areas[area_name] then
        self.areas[area_name] = Area(self, x, y, settings)
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
    self:renderUpdate(dt)
    self.world:update(dt)
    self:collisionClear()
    self:collisionSet()

    for area_name, area in pairs(self.areas) do
        if area.active then area:update(dt) end
    end
end

function World:draw()
    self:renderDraw()
    self.camera:debugDraw()
end

function World:resize(w, h)
    self:renderResize(w, h)
end

return World
