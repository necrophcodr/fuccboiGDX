local class = require (mogamett_path .. '/libraries/middleclass/middleclass')
local Group = class('Group')

function Group:init(world, name)
    self.world = world
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

function Group:draw(offset_x, offset_y)
    for _, entity in ipairs(self.entities) do 
        if entity.draw then
            entity:draw(offset_x, offset_y)
        end
    end
end

function Group:add(entity)
    table.insert(self.entities, entity)
end

function Group:remove(id)
    table.remove(self.entities, self.world.mm.utils.findIndexByID(self.entities, id))
end

function Group:removePostWorldStep()
    for i = #self.entities, 1, -1 do
        if self.entities[i].dead then
            if self.entities[i].class:includes(Timer) then self.entities[i]:timerDestroy() end
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

function Group:call(action_name, ...)
    for _, entity in ipairs(self.entities) do
        if entity[action_name] then entity[action_name](...) end
    end
end

function Group:keypressed(key)
    for _, entity in ipairs(self.entities) do 
        if entity.keypressed then
            entity:keypressed(key)
        end
    end
end

function Group:keyreleased(key)
    for _, entity in ipairs(self.entities) do 
        if entity.keyreleased then
            entity:keyreleased(key)
        end
    end
    
end

function Group:mousepressed(x, y, button)
    for _, entity in ipairs(self.entities) do 
        if entity.mousepressed then
            entity:mousepressed(x, y, button)
        end
    end
end

function Group:mousereleased(x, y, button)
    for _, entity in ipairs(self.entities) do 
        if entity.mousereleased then
            entity:mousereleased(x, y, button)
        end
    end
end

return Group
