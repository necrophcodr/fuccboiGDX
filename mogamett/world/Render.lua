local Render = {
    renderInit = function(self)
        self.camera = self.mg.Camera()
        self.camera_v = self.mg.Vector(0, 0)
        self.camera_v_multiplier = 0.2
        self.layers = {}
        self.layers_order = {'Default'}
    end,

    setLayerOrder = function(layers_order)
        self.layers_order = layers_order
    end,

    order = function(order_function)
        for _, layer_name in ipairs(self.layers_order) do
            table.sort(self.layers[layer_name], order_function)
        end
    end,

    addToLayer = function(self, layer_name, object)
        if not self.layers[layer_name] then self.layers[layer_name] = {} end
        if self.layers[layer_name] then table.insert(self.layers[layer_name], object) end
    end,

    renderUpdate = function(self, dt, follow)
        -- Camera movement, follows follow
        if follow then
            local x, y = self.camera:pos()
            self.camera_v = mg.Vector(follow.x - x, follow.y - y)
            self.camera:move(self.camera_v.x*self.camera_v_multiplier, self.camera_v.y*self.camera_v_multiplier)
        end

        -- Clear dead objects from layers
        for layer_name, layer in pairs(self.layers) do
            for i = #self.layers[layer_name], 1, -1 do
                if object.dead then table.remove(self.layers[layer_name], i) end
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
