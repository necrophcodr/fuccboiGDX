local Class = require (mogamett_path .. '/libraries/classic/classic')
local Background = Class:extend()

function Background:new(x, y, image)
    self.image = image
    self.w = image:getWidth()
    self.h = image:getHeight()
    self.x = x
    self.y = y
end

function Background:draw()
    love.graphics.draw(self.image, self.x - self.w/2, self.y - self.h/2) 
end

return Background
