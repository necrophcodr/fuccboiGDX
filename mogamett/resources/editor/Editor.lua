require 'ui/Menus'
require 'logic/Layer'

Editor = mg.Class:extend('Editor')

function Editor:new()
    mg.screen_width = 1280
    mg.screen_height = 800
    love.window.setMode(mg.screen_width, mg.screen_height, {display = 1, resizable = true})

    mg.input:bind('tab', 'next')
    mg.input:bind('a', 'add_layer')
    mg.input:bind('c', 'apply_changes')
    mg.input:bind('r', 'remove_layer')
    mg.input:bind('lalt', 'shortcut_alt')
    mg.input:bind('lctrl', 'shortcut_control')

    self.layers = {}

    self.current_focus = nil
    self.menus = Menus()
end

function Editor:update(dt)
    self.menus:update(dt)

    -- Tab Selection
    if mg.input:pressed('next') then
        -- When focus is on layers/settings menus
        if self.current_focus == 'Menus' then
            if self.menus.current_focus then
                self.menus.settings_menu:layerSettingsNextFocus(self.menus.current_focus)
            -- If no current settings menu focus but is focused on either menu,
            -- then force it to focus on the first field that can be changed.
            else self.menus.settings_menu:layerSettingsNextFocus() end

        -- When focus is on the map editor
        else

        end
    end

    -- Add layer (layer menu)
    if mg.input:pressed('add_layer') and mg.input:down('shortcut_alt') then
        self.menus.layer_menu.add:OnClick()
    end

    -- Remove layer (layer menu)
    if mg.input:pressed('remove_layer') and mg.input:down('shortcut_alt') then
        self.menus.layer_menu.remove:OnClick()
    end

    -- Apply changes (settings menu)
    if mg.input:pressed('apply_changes') and mg.input:down('shortcut_alt') then
        if self.menus.settings_menu.save then
            self.menus.settings_menu.save:OnClick()
        end
    end
end

function Editor:addLayer(settings)
    table.insert(self.layers, Layer(settings))
end

function Editor:getLastLayer()
    return self.layers[#self.layers]
end
