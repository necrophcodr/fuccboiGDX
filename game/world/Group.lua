Group = class('Group')

function Group:init(name)
    self.name = name
    self.stop_on_frame_stopped = false
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
    table.remove(self.entities, findIndexByID(self.entities, id))
end

function Group:removePostWorldStep()
    for i = #self.entities, 1, -1 do
        if self.entities[i].dead then
            if self.entities[i].class:includes(Timer) then self.entities[i]:timerDestroy() end
            if self.entities[i].class:includes(PhysicsRectangle) or self.entities[i].class:include(PhysicsCircle) or 
               self.entities[i].class:include(PhysicsBSGRectangle) or self.entities[i].class:includes(PhysicsPolygon) then
                if self.entities[i].fixture then 
                    self.entities[i].fixture:setUserData(nil) 
                    self.entities[i].fixture = nil
                end
                if self.entities[i].sensor then 
                    self.entities[i].sensor:setUserData(nil) 
                    self.entities[i].sensor = nil
                end
                if self.entities[i].body then 
                    self.entities[i].body:destroy() 
                    self.entities[i].body = nil
                end
            end
            self.entities[i].world = nil
            self:remove(self.entities[i].id)
        end
    end
end

function Group:actionPostWorldStep()
    for _, entity in ipairs(self.entities) do
        if entity.actionPostWorldStep then
            entity:actionPostWorldStep()
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
