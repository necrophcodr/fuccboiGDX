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

    self.button_test = mg.ui.Button({x = 400, y = 300, w = 80, h = 30, text = 'Button'})
end

function Editor:update(dt)
    self.menus:update(dt)

    self.button_test:update(dt)
end

function Editor:draw()
    self.button_test:draw()
end
