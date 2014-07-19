local Class = require (mogamett_path .. '/libraries/classic/classic')
local Layer = Class:extend()

local utils = require (mogamett_path .. '/libraries/mogamett/utils')

function Layer:new(world, name, settings)
    self.world = world
    self.parallax_scale = settings.parallax_scale or 1
    self.name = name
    self.entities = {}

    self.shader_canvas_names = {}
    self.shaders = {}
    self.canvases = {}
end

function Layer:addShader(name, vertex_path, fragment_path)
    table.insert(self.shader_canvas_names, name)
    self.shaders[name] = love.graphics.newShader(vertex_path, fragment_path)
    self.canvases[name] = love.graphics.newCanvas(mg.game_width, mg.game_height)
end

function Layer:sendShader(name, variable, value)
    self.shaders[name]:send(variable, value)
end

function Layer:update(dt)
    
end

function Layer:resize(w, h)
    for _, name in ipairs(self.shader_canvas_names) do
        self.canvases[name] = love.graphics.newCanvas(w, h)
    end
end

function Layer:add(object)
    table.insert(self.entities, object)
end

function Layer:remove(id)
    for i, entity in ipairs(self.entities) do
        if entity.id == id then table.remove(self.entities, i); return end
    end
end

function Layer:draw()
    if #self.shader_canvas_names > 0 then
        for _, name in ipairs(self.shader_canvas_names) do self.canvases[name]:clear() end
        for i = 1, #self.shader_canvas_names+1 do
            local name = self.shader_canvas_names[i]
            if i == 1 then
                self.canvases[name]:renderTo(function()
                    self.world:renderAttach()
                    for _, entity in ipairs(self.entities) do entity:draw() end
                    self.world:renderDetach()
                end)
            elseif i <= #self.shader_canvas_names then
                local prev_name = self.shader_canvas_names[i-1]
                self.canvases[name]:renderTo(function()
                    love.graphics.setShader(self.shaders[prev_name])
                    love.graphics.draw(self.canvases[prev_name], 0, 0)
                    love.graphics.setShader()
                end)
            else
                local prev_name = self.shader_canvas_names[i-1]
                love.graphics.setShader(self.shaders[prev_name])
                love.graphics.draw(self.canvases[prev_name], 0, 0)
                love.graphics.setShader()
            end
        end

    else
        self.world:renderAttach()
        for _, entity in ipairs(self.entities) do entity:draw() end
        self.world:renderDetach()
    end
end

return Layer
