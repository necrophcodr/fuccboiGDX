local Class = require (mogamett_path .. '/libraries/classic/classic')
local Group = Class:extend()

local utils = require (mogamett_path .. '/libraries/mogamett/utils')

function Group:new(name)
    self.name = name
    self.entities = {}
end

function Group:update(dt)
    for _, entity in ipairs(self.entities) do 
        if entity.update then
            if not entity.world.mg.classes[entity.class_name].pool_enabled or entity.pool_active then
                entity:update(dt) 
            end
        end
    end
end

function Group:draw()
    for _, entity in ipairs(self.entities) do 
        if entity.draw then
            if not entity.world.mg.classes[entity.class_name].pool_enabled or entity.pool_active then
                entity:draw()
            end
        end
    end
end

function Group:add(entity)
    table.insert(self.entities, entity)
end

function Group:remove(id)
    local fid = utils.findIndexById(self.entities, id)
    if fid then table.remove(self.entities, fid) end
end

function Group:removePostWorldStep()
    for i = #self.entities, 1, -1 do
        if self.entities[i].dead then
            if self.entities[i].world.mg.classes[self.entities[i].class_name].pool_enabled then
                self.entities[i].world.pools[self.entities[i].class_name]:unsetObject(self.entities[i])
            else
                if self.entities[i].timer then self.entities[i].timer:destroy() end
                if self.entities[i].bodies then
                    for j = #self.entities[i].bodies, 1, -1 do
                        if self.entities[i].bodies[j]:type() == 'Body' then 
                            if self.entities[i].fixtures[j] then self.entities[i].fixtures[j]:setUserData(nil) end
                            if self.entities[i].sensors[j] then self.entities[i].sensors[j]:setUserData(nil) end
                            if self.entities[i].joints[j] then self.entities[i].joints[j]:destroy() end
                            if self.entities[i].bodies[j] then self.entities[i].bodies[j]:destroy() end
                            if j == 1 then
                                self.entities[i].fixture = nil
                                self.entities[i].sensor = nil
                                self.entities[i].body = nil
                            end
                            self.entities[i].fixtures[j] = nil
                            self.entities[i].sensors[j] = nil
                            self.entities[i].joints[j] = nil
                            self.entities[i].bodies[j] = nil
                        end
                    end
                end
                self.entities[i].world:removeFromRender(self.entities[i].id)
                table.remove(self.entities, i)
                -- self.entities[i].world = nil
                -- self:remove(self.entities[i].id)
            end
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
