local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Factory = Class:extend()

function Factory:factoryNew()
    self.to_be_created = {}
end

function Factory:createEntity(type, x, y, settings)
    table.insert(self.to_be_created, {type = type, x = self.x + x, y = self.y + y, settings = settings})
end

function Factory:createEntityImmediate(type, x, y, settings)
    local settings = settings or {}

    if self.fg.classes[type].pool_enabled then
        local entity = self.pools[type]:getFirstFreeObject()
        if entity then
            entity:reset(self.x + x, self.y + y, settings)
            return entity
        end
    else
        local entity = self.fg.classes[type](self, self.x + x, self.y + y, settings)
        self:addToGroup(type, entity)
        if not settings.no_layer then self.fg.world:addToLayer(entity.layer or self.fg.classes[type].layer or 'Default', entity) end
        return entity 
    end
end

function Factory:poolCreateEntity(type, x, y, settings)
    local entity = self.fg.classes[type](self, self.x + x, self.y + y, settings) 
    if entity then
        self:addToGroup(type, entity)
        self.fg.world:addToLayer(entity.layer or self.fg.classes[type].layer or 'Default', entity)
    end
    return entity
end

function Factory:createPostWorldStep()
    for _, o in ipairs(self.to_be_created) do
        local entity = nil
        if o.type then 
            if self.fg.classes[o.type].pool_enabled then
                entity = self.pools[o.type]:getFirstFreeObject()
                if entity then
                    entity:reset(o.x, o.y, o.settings)
                end
            else 
                entity = self.fg.classes[o.type](self, o.x, o.y, o.settings) 
                if entity then
                    self:addToGroup(o.type, entity)
                    self.fg.world:addToLayer(entity.layer or self.fg.classes[o.type].layer or 'Default', entity)
                end
            end
        end
    end
    self.to_be_created = {}
end

return Factory
