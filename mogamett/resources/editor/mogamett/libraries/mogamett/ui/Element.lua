local Element = mg.Class:extend('Element')

local utils = require (mogamett_path .. '/libraries/mogamett/ui/utils')

function Element:new(settings)
    local settings = settings or {}
    self.x = settings.x or 0
    self.y = settings.y or 0
    self.w = settings.w or 150
    self.h = settings.h or 150 

    self.hot = false
    self.down = false
    self.draggable = true
    self.selected = false
    self.selected_child_index = 0

    self.children = {}

    self.last_x, self.last_y = 0, 0
end

function Element:addChild(object)
    object.x_offset, object.y_offset = object.x, object.y
    object.x, object.y = self.x + object.x, self.y + object.y
    table.insert(self.children, object)
end

function Element:select()
    local anyChildSelected = function()
        for _, child in ipairs(self.children) do
            if child.selected then return true end
        end
    end
    
    if self.selected or anyChildSelected() then
        self.selected = false

        -- Element -> first child
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

function Element:update(dt)
    -- Force top only element to be activated; for instance, an element won't be dragged
    -- if a button on top of it is press + dragged.
    for i, child in ipairs(self.children) do
        if (child.hot or child.down) then 
            child:update(dt)
            return
        end
    end

    -- Hot
    if utils.mouseColliding(self.x, self.y, self.w, self.h) then self.hot = true
    else self.hot = false end

    if self.draggable then
        -- Drag
        if (self.hot or self.down) and mg.ui.input:down('mouse1') then 
            self.down = true
            local mx, my = love.mouse.getPosition()
            local dx, dy = mx - self.last_x, my - self.last_y
            self.x, self.y = self.x + dx, self.y + dy
        end

        -- Undrag
        if self.down and mg.ui.input:released('mouse1') then self.down = false end
    end

    -- Children update
    for _, child in ipairs(self.children) do 
        child.x, child.y = self.x + child.x_offset, self.y + child.y_offset
        child:update(dt) 
    end

    self.last_x, self.last_y = love.mouse.getPosition()
end

function Element:draw()
    mg.ui.style.elementDraw(self)
    for _, child in ipairs(self.children) do child:draw() end
end

return Element
