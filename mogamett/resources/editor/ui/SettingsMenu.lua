SettingsMenu = mg.Class:extend('SettingsMenu')

function SettingsMenu:new()
    self.width = 220
    self.height = 535

    self.frame = mg.loveframes.Create('frame')
    self.frame:SetPos(1280 - self.width, 260)
    self.frame:SetWidth(self.width - 5)
    self.frame:SetHeight(self.height)
    self.frame:SetName('Settings')
    self.frame:SetDraggable(false)
    self.frame:ShowCloseButton(false)

    self.panel = mg.loveframes.Create('panel', self.frame)
    self.panel:SetPos(5, 30)
    self.panel:SetSize(self.width - 15, self.height - 35)
end

function SettingsMenu:update(dt)

end

function SettingsMenu:layerSettings(layer)
    -- Clean up
    if self.name then self.name:Remove() end
    if self.name_text then self.name_text:Remove() end
    if self.tileset then self.tileset:Remove() end
    if self.tileset_text then self.tileset_text:Remove() end
    if self.tilesize then self.tilesize:Remove() end
    if self.tilesize_number then self.tilesize_number:Remove() end
    if self.save then self.save:Remove() end
    editor.menus.current_focus = nil

    -- Create
    self.name = mg.loveframes.Create('button', self.panel):SetPos(5, 5):SetSize(50, 30):SetText('Name'):SetClickable(false)
    self.name_text = mg.loveframes.Create('textinput', self.panel):SetPos(55, 5):SetSize(145, 30):SetText(layer.name)
    self.name_text.OnFocusGained = function(object) 
        editor.current_focus = 'Menus'
        editor.menus.current_focus = 'name_text' 
    end

    self.tileset = mg.loveframes.Create('button', self.panel):SetPos(5, 40):SetSize(70, 30):SetText('Tileset'):SetClickable(false)
    self.tileset_text = mg.loveframes.Create('textinput', self.panel):SetPos(75, 40):SetSize(125, 30):SetText(layer.tileset)
    self.tileset_text.OnFocusGained = function(object) 
        editor.current_focus = 'Menus'
        editor.menus.current_focus = 'tileset_text' 
    end

    self.tilesize = mg.loveframes.Create('button', self.panel):SetPos(5, 75):SetSize(70, 30):SetText('Tilesize'):SetClickable(false)
    self.tilesize_number = mg.loveframes.Create('textinput', self.panel):SetPos(75, 75):SetSize(125, 30):SetText(tostring(layer.tilesize))
    self.tilesize_number.OnFocusGained = function(object) 
        editor.current_focus = 'Menus'
        editor.menus.current_focus = 'tilesize_number' 
    end

    self.save = mg.loveframes.Create('button', self.panel):SetPos(80, self.height - 70):SetSize(120, 30):SetText('Apply Changes')
    self.save.OnClick = function(object)
        editor.current_focus = 'Menus'
        editor.menus.current_focus = nil 
    end
end

function SettingsMenu:layerSettingsNextFocus(current_focus)
    -- Go to next field
    if current_focus then
        if current_focus == 'name_text' then
            self.tileset_text:SetFocus(true)
        elseif current_focus == 'tileset_text' then
            self.tilesize_number:SetFocus(true)
        elseif current_focus == 'tilesize_number' then
            self.name_text:SetFocus(true)
        end

    -- Force focus to first field
    else
        if self.name_text then self.name_text:SetFocus(true) end
    end
end
