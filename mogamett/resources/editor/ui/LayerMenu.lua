LayerMenu = mg.Class:extend('LayerMenu')

function LayerMenu:new(parent)
    self.parent = parent
    self.width = 220
    self.height = 250

    self.frame = mg.loveframes.Create('frame') 
    self.frame:SetPos(1280 - self.width, 5)
    self.frame:SetWidth(self.width - 5)
    self.frame:SetHeight(self.height)
    self.frame:SetName('Layers')
    self.frame:SetDraggable(false)
    self.frame:ShowCloseButton(false)

    self.panel = mg.loveframes.Create('panel', self.frame)
    self.panel:SetPos(5, 30)
    self.panel:SetSize(self.width - 15, self.height - 35)

    self.list = mg.loveframes.Create('list', self.panel)
    self.list:SetPos(5, 5)
    self.list:SetSize(self.width - 25, self.height - 85)
    self.list:SetPadding(3)
    self.list:SetSpacing(3)

    self.add = mg.loveframes.Create('button', self.panel)
    self.add:SetPos(8, self.height - 70)
    self.add:SetSize(50, 30)
    self.add:SetText('+')
    self.add.OnClick = function(object)
        editor:addLayer({name = 'New Layer'})
        self:addLayer('New Layer')

        editor.current_focus = 'Menus'
        editor.menus.current_focus = nil 
    end

    self.remove = mg.loveframes.Create('button', self.panel)
    self.remove:SetPos(63, self.height - 70)
    self.remove:SetSize(50, 30)
    self.remove:SetText('-')
    self.remove.OnClick = function(object)

        editor.current_focus = 'Menus'
        editor.menus.current_focus = nil 
    end

    self.layers = {}
end

function LayerMenu:update(dt)
    
end

function LayerMenu:addLayer(name)
    self.parent.settings_menu:layerSettings(editor:getLastLayer())

    local panel = mg.loveframes.Create('panel')
    panel:SetHeight(30)

    local active = mg.loveframes.Create('checkbox', panel)
    active:SetText('')
    active:SetSize(30, 30)

    local layer = mg.loveframes.Create('button', panel)
    layer:SetText(name)
    layer:SetClickable(false)
    layer:SetPos(30, 0)
    layer:SetSize(130, 30)

    local selected = mg.loveframes.Create('button', panel)
    selected:SetText('')
    selected:SetSize(30, 30)
    selected:SetPos(160, 0)
    selected.OnClick = function(object)
        -- Single selection logic
        local children = self.list:GetChildren()
        for _, child in ipairs(children) do child:GetChildren()[3]:SetClickable(true) end
        selected:SetClickable(false)

        -- Create layer settings menu
        self.parent.settings_menu:layerSettings(editor:getLastLayer())

        editor.current_focus = 'Menus'
        editor.menus.current_focus = nil 
    end
    local children = self.list:GetChildren()
    for _, child in ipairs(children) do child:GetChildren()[3]:SetClickable(true) end
    selected:SetClickable(false)

    self.list:AddItem(panel)
end
