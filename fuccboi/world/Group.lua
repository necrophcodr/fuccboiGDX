local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Group = Class:extend()

local utils = require (fuccboi_path .. '/libraries/fuccboi/utils')

function Group:new(name)
    self.name = name
    self.entities = {}
end

function Group:update(dt)
    for _, entity in ipairs(self.entities) do 
        if entity.update then
            if not entity.area.fg.classes[entity.class_name].pool_enabled or entity.pool_active then
                entity:update(dt) 
            end
        end
    end
end

function Group:draw()
    for _, entity in ipairs(self.entities) do 
        if entity.draw then
            if not entity.area.fg.classes[entity.class_name].pool_enabled or entity.pool_active then
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
            if self.entities[i].area.fg.classes[self.entities[i].class_name].pool_enabled then
                self.entities[i].area.pools[self.entities[i].class_name]:unsetObject(self.entities[i])
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
                self.entities[i].area.world:removeFromRender(self.entities[i].id)
                table.remove(self.entities, i)
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
