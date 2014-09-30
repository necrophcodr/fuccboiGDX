local Button = mg.Class:extend('Button')

local utils = require (mogamett_path .. '/libraries/mogamett/ui/utils')
local config = require (mogamett_path .. '/libraries/mogamett/ui/config')

function Button:new(settings)
    local settings = settings or {}
    self.x = settings.x or 0
    self.y = settings.y or 0
    self.w = settings.w or 100
    self.h = settings.h or 30
    self.action = settings.action or function() end

    self.hot = false
    self.enabled = true 
    self.down = false

    self.text = mg.Text(settings.text or 'Default', {font = settings.font or config.default_font})
end

function Button:update(dt)
    if self.enabled then
        self.text:update(dt)

        if utils.mouseColliding(self.x, self.y, self.w, self.h) then self.hot = true
        else self.hot = false end

        if self.down and mg.ui.input:released('activate') then self:action() end

        if self.hot and mg.ui.input:down('activate') then self.down = true
        else self.down = false end
    end
end

function Button:draw()
    mg.ui.style.buttonDraw(self)
end

return Button
