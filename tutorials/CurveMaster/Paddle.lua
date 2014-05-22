Paddle = mg.Class('Paddle')

require 'PaddleTrail'

function Paddle:init(x, y, settings)
    settings = settings or {}
    self.x = x
    self.y = y
    self.last_y = self.y
    self.w = settings.w or 30
    self.h = settings.h or 100
    self.v = 0
    self.max_v = 400
    self.ai = settings.ai
    self.idle = false

    self.w_add = 0
    self.h_add = 0
    mg.timer:every({0.02, 0.04}, function()
        mg.timer:tween(0.02, self, {w_add = mg.utils.math.random(-4, 4)}, 'in-elastic')
        mg.timer:tween(0.02, self, {h_add = mg.utils.math.random(-4, 4)}, 'in-elastic')
    end)

    mg.timer:every({0.02, 0.04}, function()
        table.insert(paddle_trails, PaddleTrail(self.x, self.y, self.w, self.h))
    end)
    
    self.idle_p = 0
    mg.timer:every({0.3, 0.6}, function()
        self.idle_p = 300 + math.random(-150, 150)
    end)
end

function Paddle:update(dt)
    self.last_y = self.y

    self.max_v = 175*level

    -- Movement
    if self.ai then
        local dy = self.y - balls[1].y
        if self.idle then dy = self.y - self.idle_p end
        if dy < 0 then
            self.y = self.y - math.max((level+1.2)*dy, -self.max_v)*dt
        else
            self.y = self.y - math.min((level*1.2)*dy, self.max_v)*dt
        end
    else
        local mx, my = love.mouse.getPosition()
        self.y = my
    end

    self.v = self.last_y - self.y

    -- Limit to screen
    if self.y < 0 + self.h/2 then
        self.y = 0 + self.h/2
    end
    if self.y > 600 - self.h/2 then
        self.y = 600 - self.h/2
    end
end

function Paddle:draw()
    local w, h = self.w + self.w_add, self.h + self.h_add
    love.graphics.rectangle('fill', self.x - w/2, self.y - h/2, w, h)
end
