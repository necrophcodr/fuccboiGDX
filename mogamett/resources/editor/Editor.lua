require 'ui/Menus'
require 'logic/Layer'

Editor = mg.Class:extend('Editor')

local config = require (mogamett_path .. '/libraries/mogamett/ui/config')

function Editor:new()
    mg.screen_width = 1280
    mg.screen_height = 800
    love.window.setMode(mg.screen_width, mg.screen_height, {display = 1, resizable = true})

    self.config = require 'config'
    for key, binding in pairs(self.config.key_bindings) do mg.input:bind(key, binding) end

    self.menus = Menus(self)

    self.element = mg.ui.Frame({x = 400, y = 300, w = 150, h = 150, text = 'Frame'})
    self.element:addChild(mg.ui.Button({x = 5, y = 5, w = 80, h = 30, text = 'Button', action = function(button) print(1) end}))
    self.element:addChild(mg.ui.Checkbox({x = 5, y = 40, w = 80, h = 32, text = 'Checkbox'}))
end

function Editor:update(dt)
    if mg.ui.input:pressed('select') then self.element:select() end

    self.menus:update(dt)
    self.element:update(dt)
end

function Editor:draw()
    self.element:draw()
end
