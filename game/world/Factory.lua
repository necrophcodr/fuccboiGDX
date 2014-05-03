Factory = {
    factoryInit = function(self)
        self.to_be_created = {}
    end,

    create = function(self, type, x, y, settings)
        table.insert(self.to_be_created, {type = type, x = x, y = y, settings = settings})
    end,

    createToGroup = function(self, type, x, y, settings)
        table.insert(self.to_be_created, {group = true, type = type, x = x, y = y, settings = settings})
    end,

    createToGroupIm = function(self, type, x, y, settings)
        local entity = _G[o.type](self, o.x, o.y, o.settings)
        self:addToGroup(o.type, entity)
        return entity 
    end,

    createPostWorldStep = function(self)
        for _, o in ipairs(self.to_be_created) do
            local entity = nil
            if o.type then entity = classes[o.type](self, o.x, o.y, o.settings) end
            if entity then
                if o.group then self:addToGroup(o.type, entity)
                else self:add(entity) end
            end
        end
        self.to_be_created = {}
    end
}
