local Frame = mg.Class:extend('Frame')

local utils = require (mogamett_path .. '/libraries/mogamett/ui/utils')
local config = require (mogamett_path .. '/libraries/mogamett/ui/config')

function Frame:new(settings)
    local settings = settings or {}
    self.x = settings.x or 0
    self.y = settings.y or 0
    self.w = settings.w or 150
    self.h = settings.h or 150 

    self.hot = false
    self.down = false
    self.selected = false
    self.selected_child_index = 0

    self.title_bar_height = 20
    self.title_bar_text = mg.Text(settings.text or 'Default', {font = settings.font or config.default_font_bold})

    self.children = {}

    self.last_x, self.last_y = 0, 0
end

function Frame:addChild(object)
    object.x_offset, object.y_offset = object.x, object.y + self.title_bar_height
    object.x, object.y = self.x + object.x, self.y + object.y
    table.insert(self.children, object)
end

function Frame:select()
    self.title_bar_text:update(dt)

    local anyChildSelected = function()
        for _, child in ipairs(self.children) do
            if child.selected then return true end
        end
    end

    if self.selected or anyChildSelected() then
        self.selected = false
        -- Frame -> first child
        if self.selected_child_index == 0 then 
            self.children[1]:select()
            self.selected_child_index = 1
        -- Last child -> nil
        elseif self.selected_child_index == #self.children then
            self.children[#self.children]:select()
            self.selected_child_index = 0
        -- Previous child -> next child
        else
            self.children[self.selected_child_index]:select()
            self.selected_child_index = self.selected_child_index + 1
            self.children[self.selected_child_index]:select()
        end
    else self.selected = true end
end

function Frame:update(dt)
    for _, child in ipairs(self.children) do
        if (child.hot or child.down) then child:update(dt); return end
    end

    -- Hot
    if utils.mouseColliding(self.x, self.y, self.w, self.title_bar_height) then self.hot = true
    else self.hot = false end

    -- Drag
    if (self.hot or self.down) and mg.ui.input:down('mouse1') then 
        self.down = true
        local mx, my = love.mouse.getPosition()
        local dx, dy = mx - self.last_x, my - self.last_y
        self.x, self.y = self.x + dx, self.y + dy
    end

    -- Undrag
    if self.down and mg.ui.input:released('mouse1') then self.down = false end

    -- Children update
    for _, child in ipairs(self.children) do 
        child.x, child.y = self.x + child.x_offset, self.y + child.y_offset
        child:update(dt) 
    end

    self.last_x, self.last_y = love.mouse.getPosition()
end

function Frame:draw()
    mg.ui.style.frameDraw(self)
    for _, child in ipairs(self.children) do child:draw() end
end

return Frame
