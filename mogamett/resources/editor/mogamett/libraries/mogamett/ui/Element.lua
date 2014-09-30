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

    self.children = {}

    self.last_x, self.last_y = 0, 0
end

function Element:update(dt)
    if utils.mouseColliding(self.x, self.y, self.w, self.h) then self.hot = true
    else self.hot = false end

    -- Drag
    if (self.hot or self.down) and mg.ui.input:down('activate') then 
        self.down = true
        local mx, my = love.mouse.getPosition()
        local dx, dy = mx - self.last_x, my - self.last_y
        self.x, self.y = self.x + dx, self.y + dy
    end

    if self.down and mg.ui.input:released('activate') then self.down = false end

    self.last_x, self.last_y = love.mouse.getPosition()
end

function Element:draw()
    mg.ui.style.elementDraw(self)
end

return Element
