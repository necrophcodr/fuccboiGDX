local Checkbox = mg.Class:extend('Checkbox')

local utils = require (mogamett_path .. '/libraries/mogamett/ui/utils')
local config = require (mogamett_path .. '/libraries/mogamett/ui/config')

function Checkbox:new(settings)
    local settings = settings or {}
    self.x = settings.x or 0
    self.y = settings.y or 0
    self.w = settings.w or 100
    self.h = settings.h or 30

    self.hot = false
    self.selected = false
    self.enabled = true 
    self.checked = false
    self.down = false

    self.text = mg.Text(settings.text or 'Default', {font = settings.font or config.default_font})
end

function Checkbox:select()
    if self.selected then
        self.selected = false
    else self.selected = true end
end

function Checkbox:update(dt)
    if self.enabled then
        self.text:update(dt)

        if utils.mouseColliding(self.x, self.y, self.w, self.h) then self.hot = true
        else self.hot = false end

        if ((self.hot and self.down) or self.selected) and mg.ui.input:released('activate') then self.checked = not self.checked end

        if ((self.hot or self.down) or self.selected) and mg.ui.input:down('activate') then self.down = true
        else self.down = false end
    end
end

function Checkbox:draw()
    mg.ui.style.checkboxDraw(self)
end

return Checkbox
