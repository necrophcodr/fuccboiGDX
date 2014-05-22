PaddleTrail = mg.Class('PaddleTrail')

function PaddleTrail:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w + mg.utils.math.random(-2, 2)
    self.h = h + mg.utils.math.random(-2, 2)
    self.alpha = 0
    self.dead = false

    mg.timer:tween(0.02, self, {alpha = 255}, 'in-out-cubic')
    mg.timer:after(0.02, function()
        mg.timer:tween(0.2, self, {alpha = 0}, 'in-out-cubic')
        mg.timer:after(0.2, function() self.dead = true end)
    end)
end

function PaddleTrail:update(dt)

end

function PaddleTrail:draw()
    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.h/2, self.w, self.h)
    love.graphics.setColor(255, 255, 255, 255)
end
