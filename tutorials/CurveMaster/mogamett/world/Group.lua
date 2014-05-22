local class = require (mogamett_path .. '/libraries/middleclass/middleclass')
local Group = class('Group')

local utils = require (mogamett_path .. '/libraries/mogamett/utils')

function Group:init(name)
    self.name = name
    self.entities = {}
end

function Group:update(dt)
    for _, entity in ipairs(self.entities) do 
        if entity.update then
            entity:update(dt) 
        end
    end
end

function Group:draw()
    for _, entity in ipairs(self.entities) do 
        if entity.draw then
            entity:draw()
        end
    end
end

function Group:add(entity)
    table.insert(self.entities, entity)
end

function Group:remove(id)
    table.remove(self.entities, utils.findIndexByID(self.entities, id))
end

function Group:removePostWorldStep()
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
            self:remove(self.entities[i].id)
        end
    end
end

function Group:destroy()
    self.entities = nil
end

function Group:getEntities()
    return self.entities
end

function Group:apply(action)
    for _, entity in ipairs(self.entities) do action(entity) end
end

return Group
