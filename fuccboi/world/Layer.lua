local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Layer = Class:extend()

local utils = require (fuccboi_path .. '/libraries/fuccboi/utils')

function Layer:new(world, name, settings)
    self.world = world
    self.parallax_scale = settings.parallax_scale or 1
    self.name = name
    self.entities = {}

    self.shader_names = {}
    self.shader_classes = {}
    self.shaders = {}
    self.canvases = {}

    self.main_canvas = love.graphics.newCanvas(fg.screen_width, fg.screen_height)
    self.main_canvas:setFilter('nearest', 'nearest')
end

function Layer:addShader(name, vertex_path, fragment_path)
    table.insert(self.shader_names, name)
    self.shaders[name] = love.graphics.newShader(vertex_path, fragment_path)
    self.canvases[name] = love.graphics.newCanvas(fg.screen_width, fg.screen_height)
    self.canvases[name]:setFilter('nearest', 'nearest')
end

function Layer:sendShader(name, variable, value)
    self.shaders[name]:send(variable, value)
end

function Layer:setShaderClassList(shader_name, list)
    self.shader_classes[shader_name] = utils.table.copy(list)
end

function Layer:update(dt)
    
end

function Layer:resize(w, h)
    self.main_canvas = love.graphics.newCanvas(w, h)
    for _, name in ipairs(self.shader_names) do
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
    self.main_canvas:clear()

    -- Normal draw
    if #self.shader_names > 0 then
        for _, name in ipairs(self.shader_names) do self.canvases[name]:clear() end
        for i = 1, #self.shader_names+1 do
            local name = self.shader_names[i]
            -- Shader classes list defined = apply only to classes in the list
            if self.shader_classes[name] then
                if i == 1 then
                    self.canvases[name]:renderTo(function()
                        self.world:renderAttach()
                        for _, entity in ipairs(self.entities) do 
                            if utils.table.contains(self.shader_classes[name], entity.class_name) then 
                                if entity.area.active then entity:draw() end
                            end
                        end
                        self.world:renderDetach()
                    end)
                    self.main_canvas:renderTo(function()
                        self.world:renderAttach()
                        for _, entity in ipairs(self.entities) do 
                            if not utils.table.contains(self.shader_classes[name], entity.class_name) then 
                                if entity.area.active then entity:draw() end
                            end
                        end
                        self.world:renderDetach()
                    end)
                elseif i <= #self.shader_names then
                    local prev_name = self.shader_names[i-1]
                    self.canvases[name]:renderTo(function()
                        love.graphics.setShader(self.shaders[prev_name])
                        love.graphics.draw(self.canvases[prev_name], 0, 0)
                        love.graphics.setShader()
                    end)
                else
                    local prev_name = self.shader_names[i-1]
                    self.main_canvas:renderTo(function()
                        love.graphics.setShader(self.shaders[prev_name])
                        love.graphics.draw(self.canvases[prev_name], 0, 0)
                        love.graphics.setShader()
                    end)
                end

            -- Shader classes list not defined = apply shader to all
            else
                if i == 1 then
                    self.canvases[name]:renderTo(function()
                        self.world:renderAttach()
                        for _, entity in ipairs(self.entities) do 
                            if entity.area.active then entity:draw() end
                        end
                        self.world:renderDetach()
                    end)
                elseif i <= #self.shader_names then
                    local prev_name = self.shader_names[i-1]
                    self.canvases[name]:renderTo(function()
                        love.graphics.setShader(self.shaders[prev_name])
                        love.graphics.draw(self.canvases[prev_name], 0, 0)
                        love.graphics.setShader()
                    end)
                else
                    local prev_name = self.shader_names[i-1]
                    self.main_canvas:renderTo(function()
                        love.graphics.setShader(self.shaders[prev_name])
                        love.graphics.draw(self.canvases[prev_name], 0, 0)
                        love.graphics.setShader()
                    end)
                end
            end
        end

    else
        self.main_canvas:renderTo(function()
            self.world:renderAttach()
            for _, entity in ipairs(self.entities) do 
                if entity.area.active then entity:draw() end
            end
            self.world:renderDetach()
        end)
    end

    love.graphics.draw(self.main_canvas, 0, 0)
end

return Layer
