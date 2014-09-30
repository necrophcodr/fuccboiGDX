require 'ui/LayerMenu'
require 'ui/SettingsMenu'

Menus = mg.Class:extend('Menus')

function Menus:new(parent)
    self.parent = parent

    self.layer_menu = LayerMenu(self)
    self.settings_menu = SettingsMenu(self)
end

function Menus:update(dt)
    self.layer_menu:update(dt)
    self.settings_menu:update(dt)
end

function Menus:draw()

end
