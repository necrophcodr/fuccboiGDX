local Render = {
    renderInit = function(self)
        self.camera = self.mm.Camera(self.mm)

        self.layers = {}
        self.layers_order = {'Default'}
        self:addLayer('Default')
    end,

    setLayerOrder = function(self, layers_order)
        self.layers_order = layers_order
    end,

    order = function(self, order_function)
        for _, layer_name in ipairs(self.layers_order) do
            table.sort(self.layers[layer_name], order_function)
        end
    end,

    addLayer = function(self, layer_name)
        self.layers[layer_name] = {}
    end,

    addToLayer = function(self, layer_name, object)
        if not self.layers[layer_name] then self:addLayer(layer_name) end
        if self.layers[layer_name] then table.insert(self.layers[layer_name], object) end
    end,

    renderUpdate = function(self, dt)
        -- self.camera:move(self.camera.target.x*self.camera.lerp, self.camera.target.y*self.camera.lerp)
        self.camera:update(dt)

        -- Clear dead objects from layers
        for layer_name, layer in pairs(self.layers) do
            for i = #self.layers[layer_name], 1, -1 do
                if self.layers[layer_name][i].dead then table.remove(self.layers[layer_name], i) end
            end
        end
    end,

    renderAttach = function(self)
        self.camera:attach()
    end,

    renderDetach = function(self)
        self.camera:detach()
    end,

    renderDraw = function(self)
        for _, layer_name in ipairs(self.layers_order) do
            for _, object in ipairs(self.layers[layer_name]) do
                object:draw()
            end
        end
    end
}

return Render
