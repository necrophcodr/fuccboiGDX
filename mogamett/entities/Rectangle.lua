local Rectangle = loadstring("local Rectangle = " .. mogamett_name .. ".class('Rectangle', " .. mogamett_name .. ".Entity); return Rectangle")()
-- local Rectangle = mm.class('Rectangle', mm.Entity)

function Rectangle:init(world, x, y, settings)
    local Entity = loadstring('return ' .. mogamett_name .. '.Entity')()
    Entity.init(self, world, x, y, settings)
    self.w = settings.w or 50
    self.h = settings.h or 50
end

function Rectangle:update(dt)
    
end

function Rectangle:draw()
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.h/2, self.w, self.h)
end

return Rectangle 
