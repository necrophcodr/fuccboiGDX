local Class = require (mogamett_path .. '/libraries/classic/classic')
local Factory = Class:extend()

function Factory:factoryNew()
    self.to_be_created = {}
end

function Factory:createEntity(type, x, y, settings)
    table.insert(self.to_be_created, {type = type, x = x, y = y, settings = settings})
end

function Factory:createEntityImmediate(type, x, y, settings)
    if self.mg.classes[type].pool_enabled then
        local entity = self.pools[type]:getFirstFreeObject()
        if entity then
            entity:reset(x, y, settings)
            return entity
        end
    else
        local entity = self.mg.classes[type](self, x, y, settings)
        return entity 
    end
end

function Factory:poolCreateEntity(type, x, y, settings)
    local entity = self.mg.classes[type](self, x, y, settings) 
    if entity then
        self:addToGroup(type, entity)
        self:addToLayer(self.mg.classes[type].layer or 'Default', entity)
    end
    return entity
end

function Factory:createPostWorldStep()
    for _, o in ipairs(self.to_be_created) do
        local entity = nil
        if o.type then 
            if self.mg.classes[o.type].pool_enabled then
                entity = self.pools[o.type]:getFirstFreeObject()
                if entity then
                    entity:reset(o.x, o.y, o.settings)
                end
            else 
                entity = self.mg.classes[o.type](self, o.x, o.y, o.settings) 
                if entity then
                    self:addToGroup(o.type, entity)
                    self:addToLayer(self.mg.classes[o.type].layer or 'Default', entity)
                end
            end
        end
    end
    self.to_be_created = {}
end

return Factory