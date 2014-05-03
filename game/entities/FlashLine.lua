classes['FlashLine'] = class('FlashLine', Entity); local FlashLine = classes['FlashLine']
FlashLine:include(Timer)

function FlashLine:init(world, x, y, settings)
    Entity.init(self, world, x, y, settings)
    self:timerInit()
    self.w = 1
    self.final_w = math.prandom(12, 24)
    self.alpha = 0
    local d = math.prandom(0.1, 0.2)
    self.timer:tween(d, self, {w = self.final_w}, 'in-elastic')
    self.timer:tween(d, self, {alpha = 255}, 'in-out-cubic')
    self.timer:after(d, function()
        local e = math.prandom(0.4, 0.6)
        self.timer:tween(e, self, {alpha = 0}, 'in-out-cubic')
        self.timer:tween(e, self, {w = 0}, 'in-elastic')
        self.timer:after(e, function() self.dead = true end)
    end)
end

function FlashLine:update(dt)
    self:timerUpdate(dt)
end

function FlashLine:draw()
    love.graphics.setLineWidth(self.w/10 + math.prandom(-1, 1))
    love.graphics.setColor(244, 244, 244, self.alpha)
    love.graphics.line(self.x1, self.y1, self.x2, self.y2)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setLineWidth(1)
end
