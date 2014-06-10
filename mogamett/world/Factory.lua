local Class = require (mogamett_path .. '/libraries/classic/classic')
local Factory = Class:extend()

function Factory:factoryNew()
    self.to_be_created = {}
end

function Factory:createEntity(type, x, y, settings)
    table.insert(self.to_be_created, {type = type, x = x, y = y, settings = settings})
end

function Factory:createEntityImmediate(type, x, y, settings)
    local entity = classes[o.type](self, o.x, o.y, o.settings)
    self:addToGroup(o.type, entity)
    return entity 
end

function Factory:createPostWorldStep()
    for _, o in ipairs(self.to_be_created) do
        local entity = nil
        if o.type then entity = self.mg.classes[o.type](self, o.x, o.y, o.settings) end
        if entity then
            self:addToGroup(o.type, entity)
            self:addToLayer(self.mg.classes[o.type].layer or 'Default', entity)
        end
    end
    self.to_be_created = {}
end

return Factory
