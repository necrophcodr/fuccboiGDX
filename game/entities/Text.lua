classes['Text'] = class('Text', Entity); local Text = classes['Text']
Text:include(Timer)

function Text:init(world, x, y, settings)
    Entity.init(self, world, x, y, settings)
    self:timerInit()
    self.w = small_font:getWidth(self.text)
    self.alpha = 0
    if self.fast then
        self.timer:tween(0.2, self, {alpha = 255}, 'in-out-cubic')
        self.timer:tween(2, self, {y = self.y - 20}, 'linear')
        self.timer:after(0.2, function()
            self.timer:tween(1.8, self, {alpha = 0}, 'linear')
            self.timer:after(1.8, function() self.dead = true end)
        end)
    else
        self.timer:tween(20, self, {y = self.y + 100}, 'linear')
        self.timer:tween(1, self, {alpha = 255}, 'in-out-cubic')
        self.timer:after(1, function()
            self.timer:tween(19, self, {alpha = 0}, 'linear')
            self.timer:after(19, function() self.dead = true end)
        end)
    end
end

function Text:update(dt)
    self:timerUpdate(dt)
end

function Text:draw()
    love.graphics.setFont(small_font)
    love.graphics.setColor(244, 244, 244, self.alpha)
    love.graphics.print(self.text, self.x - self.w/2, self.y)
    love.graphics.setColor(255, 255, 255)
end
