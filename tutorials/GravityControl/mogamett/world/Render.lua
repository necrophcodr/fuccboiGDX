local Render = {
    renderInit = function(self)
        self.camera = self.mg.Camera(self.mg)

        self.layers = {}
        self.layers_order = {'Default'}
        self:addLayer('Default')
    end,

    setLayerOrder = function(self, layers_order)
        self.layers_order = layers_order
    end,

    sortLayerRenderOrder = function(self, layer_name, order_function)
        table.sort(self.layers[layer_name], order_function)
    end,

    sortRenderOrder = function(self, order_function)
        for _, layer_name in ipairs(self.layers_order) do
            table.sort(self.layers[layer_name], order_function)
        end
    end,

    addLayer = function(self, layer_name, scale)
        self.layers[layer_name] = {scale = scale or 1}
    end,

    addToLayer = function(self, layer_name, object)
        if not self.layers[layer_name] then self:addLayer(layer_name) end
        if self.layers[layer_name] then table.insert(self.layers[layer_name], object) end
    end,

    removeFromRender = function(self, id)
        for layer_name, layer in pairs(self.layers) do
            local fid = self.mg.utils.findIndexById(layer, id)
            if fid then table.remove(layer, fid); return end
        end
    end,

    renderUpdate = function(self, dt)
        self.camera:update(dt)

        --[[
        -- Clear dead objects from layers
        for layer_name, layer in pairs(self.layers) do
            for i = #self.layers[layer_name], 1, -1 do
                if self.layers[layer_name][i].dead then print(i); table.remove(self.layers[layer_name], i) end
            end
        end
        ]]--
    end,

    renderAttach = function(self)
        self.camera:attach()
    end,

    renderDetach = function(self)
        self.camera:detach()
    end,

    renderDraw = function(self)
        local bx, by = self.camera:getPosition()
        for _, layer_name in ipairs(self.layers_order) do
            self.camera.x = bx*self.layers[layer_name].scale
            self.camera.y = by*self.layers[layer_name].scale
            self:renderAttach()
            for _, object in ipairs(self.layers[layer_name]) do
                object:draw()
            end
            self:renderDetach()
        end
    end
}

return Render
