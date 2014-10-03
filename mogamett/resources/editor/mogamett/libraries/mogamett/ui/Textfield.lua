local Textfield = mg.Class:extend('Textfield')

local utils = require (mogamett_path .. '/libraries/mogamett/ui/utils')
local config = require (mogamett_path .. '/libraries/mogamett/ui/config')

function Textfield:new(settings)
    local settings = settings or {}
    self.x = settings.x or 0
    self.y = settings.y or 0
    self.w = settings.w or 100
    self.h = settings.h or 30

    self.hot = false
    self.down = false
    self.selected = false
    self.enabled = true
    self.focused = false

    self.delete_delay = 0.03
    self.can_delete = true
    self.delete_timer = 0
    self.just_pressed_backspace = false

    self.cursor_blink_timer = 0
    self.cursor_blink_rate = 0.5
    self.cursor_visible = false
    self.cursor_index = 0

    self.text = ''
end

function Textfield:select()
    if self.selected then self.selected = false; self.focused = false
    else self.selected = true; self.focused = true end
end

function Textfield:update(dt)
    if not self.enabled then return end

    self.text = self.text .. mg.ui.input:getText()

    if utils.mouseColliding(self.x, self.y, self.w, self.h) then self.hot = true
    else self.hot = false end

    if self.hot and mg.ui.input:released('mouse1') then self.focused = true end
    if not self.hot and mg.ui.input:released('mouse1') then self.selected = false; self.focused = false end

    if ((self.hot or self.down) and mg.ui.input:down('mouse1')) or (self.selected and mg.ui.input:down('return')) then self.down = true
    else self.down = false end

    -- Character deletion
    self.delete_timer = self.delete_timer + dt
    if self.delete_timer > self.delete_delay then
        self.can_delete = true
        self.delete_timer = 0
    end
    if mg.ui.input:pressed('backspace') then
        self.just_pressed_backspace = true
        mg.timer:after('just_pressed_backspace', 0.3, function() self.just_pressed_backspace = false end)
        self.text = string.sub(self.text, 1, -2)
    end
    if mg.ui.input:down('backspace') then 
        if self.can_delete and not self.just_pressed_backspace then
            self.can_delete = false
            self.text = string.sub(self.text, 1, -2)
        end
    end

    -- Cursor
    self.cursor_blink_timer = self.cursor_blink_timer + dt
    if self.cursor_blink_timer > self.cursor_blink_rate then
        self.cursor_blink_timer = 0
        if self.focused then self.cursor_visible = not self.cursor_visible end
    end
end

function Textfield:draw()
    mg.ui.style.textfieldDraw(self)
end

return Textfield
