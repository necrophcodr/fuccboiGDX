BallTrail = mg.Class('BallTrail')

function BallTrail:init(x, y, r, rotation)
    self.x = x
    self.y = y
    self.r = r + mg.utils.math.random(-4, 4)
    self.rotation = mg.utils.math.random(0, 2*math.pi)
    self.alpha = 0
    self.dead = false

    mg.timer:tween(0.02, self, {alpha = 255}, 'in-out-cubic')
    mg.timer:after(0.02, function()
        mg.timer:tween(0.4, self, {alpha = 0}, 'in-out-cubic')
        mg.timer:after(0.4, function() self.dead = true end)
    end)
end

function BallTrail:update(dt)

end

function BallTrail:draw()
    love.graphics.setColor(255, 255, 255, self.alpha)
    mg.utils.graphics.pushRotate(self.x, self.y, self.rotation)
    love.graphics.rectangle('fill', self.x - self.r/2, self.y - self.r/2, self.r, self.r)
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)
end
