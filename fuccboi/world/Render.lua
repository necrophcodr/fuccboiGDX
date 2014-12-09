local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Render = Class:extend()

local Layer = require (fuccboi_path .. '/world/Layer')

function Render:renderNew()
    self.camera = self.fg.Camera()

    self.main_canvas = love.graphics.newCanvas(self.fg.screen_width, self.fg.screen_height)
    self.main_canvas:setFilter('nearest', 'nearest')

    self.layers = {}
    self.sortable_layers = {}
    self.layers_order = {'Default'}
    self:addLayer('Default')
end

function Render:setLayerOrder(layers_order)
    self.layers_order = layers_order
end   

function Render:sortLayerRenderOrder(layer_name, order_function)
    table.sort(self.layers[layer_name].entities, order_function)
end

function Render:sortRenderOrder(order_function)
    for _, layer_name in ipairs(self.layers_order) do
        table.sort(self.layers[layer_name].entities, order_function)
    end
end

function Render:sortRenderOrderManual(order_function)
    for _, layer_name in ipairs(self.sortable_layers) do
        self.layers[layer_name].entities = order_function(self.layers[layer_name].entities)
    end
end

function Render:addLayer(layer_name, settings)
    local settings = settings or {}
    self.layers[layer_name] = Layer(self, layer_name, settings) 
    if settings.not_sortable then return end
    table.insert(self.sortable_layers, layer_name)
end

function Render:addToLayer(layer_name, object)
    if not self.layers[layer_name] then self:addLayer(layer_name) end
    if self.layers[layer_name] then self.layers[layer_name]:add(object) end
end

function Render:addShaderToLayer(layer_name, shader_name, shader_vertex_path, shader_fragment_path)
    self.layers[layer_name]:addShader(shader_name, shader_vertex_path, shader_fragment_path)
end

function Render:sendToShader(layer_name, shader_name, variable, value)
    self.layers[layer_name]:sendShader(shader_name, variable, value)
end

function Render:setShaderClassList(layer_name, shader_name, class_list)
    self.layers[layer_name]:setShaderClassList(shader_name, class_list) 
end

function Render:removeFromRender(id)
    for _, layer in pairs(self.layers) do layer:remove(id) end
end

function Render:renderUpdate(dt)
    self.camera:update(dt)
end

function Render:renderResize(w, h)
    self.camera:resize(w, h)
end

function Render:renderAttach()
    self.camera:attach()
end

function Render:renderDetach() 
    self.camera:detach()
end

function Render:renderDraw()
    self.main_canvas:clear()
    self.main_canvas:renderTo(function()
        -- Draw all layers
        local bx, by = self.camera:getPosition()
        for _, layer_name in ipairs(self.layers_order) do
            self.camera.x = bx*self.layers[layer_name].parallax_scale
            self.camera.y = by*self.layers[layer_name].parallax_scale
            self.layers[layer_name]:draw()
        end
    end)

    love.graphics.draw(self.main_canvas, 0, 0, 0, self.fg.screen_scale, self.fg.screen_scale)

    --[[
    -- Draw all layers
    local bx, by = self.camera:getPosition()
    for _, layer_name in ipairs(self.layers_order) do
        self.camera.x = bx*self.layers[layer_name].parallax_scale
        self.camera.y = by*self.layers[layer_name].parallax_scale
        self.layers[layer_name]:draw()
    end
    ]]--
end

return Render
