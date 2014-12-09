local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Spritebatch = Class:extend('Spritebatch')

function Spritebatch:new(x, y, image, size, usage_hint)
    self.image = image
    self.size = size
    self.usage_hint = usage_hint
    self.x = x or 0
    self.y = x or 0
    self.spritebatch = love.graphics.newSpriteBatch(image, size, usage_hint or 'dynamic')

    self.to_be_added = {}
end

function Spritebatch:update(dt)
    if self.usage_hint == 'stream' then
        self.spritebatch:clear()
    end
end

function Spritebatch:draw()
    love.graphics.draw(self.spritebatch, self.x, self.y) 
end

return Spritebatch
