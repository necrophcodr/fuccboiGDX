Ball = mg.Class('Ball')

require 'BallTrail'

function Ball:init(x, y, settings)
    settings = settings or {}
    self.x = x
    self.y = y
    self.r = settings.r or 30
    self.angle = mg.utils.table.random({math.pi/4, 7*math.pi/4})
    self.v = settings.v or mg.Vector(400 + 25*level, 400 + 25*level)
    self.rotation = 0
    self.rotation_speed = math.pi
    self.angle_speed = 0

    self.just_hit_paddle = false

    self.trail_t = 0

    self.r_add = 0
    mg.timer:every({0.02, 0.04}, function()
        mg.timer:tween(0.02, self, {r_add = mg.utils.math.random(-2, 2)}, 'in-elastic')
    end)
end

function Ball:update(dt)
    self.x = self.x + self.v.x*math.cos(self.angle)*dt
    self.y = self.y + self.v.y*math.sin(self.angle)*dt
    self.rotation = self.rotation + self.rotation_speed*dt
    self.angle = self.angle + self.angle_speed*dt

    self.trail_t = self.trail_t + dt
    if self.trail_t > (0.03 - math.abs(0.0125*self.angle_speed)) then
        self.trail_t = 0
        table.insert(ball_trails, BallTrail(self.x, self.y, self.r, self.rotation)) 
    end

    
    -- Screen edges
    if self.x < 0 + self.r/2 then
        self.dead = true
        mg.world:spawnParticles('hit', self.x, self.y, {rotation = 0})
    end
    if self.x > 800 - self.r/2 then
        self.dead = true
        mg.world:spawnParticles('hit', self.x, self.y, {rotation = math.pi})
    end
    if self.y < 0 + self.r/2 then
        self.angle = -self.angle
        self.rotation_speed = self.rotation_speed/2
        mg.world:spawnParticles('hit', self.x, 0, {rotation = math.pi/2})
    end
    if self.y > 600 - self.r/2 then
        self.angle = -self.angle
        self.rotation_speed = self.rotation_speed/2
        mg.world:spawnParticles('hit', self.x, 600, {rotation = -math.pi/2})
    end

    -- Paddles
    if not self.just_hit_paddle then
        if (self.x - self.r/2 <= paddle1.x + paddle1.w/2) and (self.y >= paddle1.y - paddle1.h/2) and (self.y <= paddle1.y + paddle1.h/2) then
            camera:shake(5, 0.5)
            mg.world:spawnParticles('hit', paddle1.x + paddle1.w/2, self.y, {rotation = 0})
            self.v.x = -(1.07 + 0.01*level)*self.v.x 
            self.rotation_speed = paddle1.v/4
            self.angle_speed = paddle1.v/96
            mg.timer:cancel('r_speed_add')
            mg.timer:tween('r_speed_add', 1.5, self, {r = 30 - math.abs(12.5*self.angle_speed)}, 'in-out-cubic')

            paddle2.idle = false
            self.just_hit_paddle = true
            mg.timer:after(0.2, function() self.just_hit_paddle = false end)
        end
        if (self.x + self.r/2 >= paddle2.x - paddle2.w/2) and (self.y >= paddle2.y - paddle2.h/2) and (self.y <= paddle2.y + paddle2.h/2) then
            camera:shake(5, 0.5)
            mg.world:spawnParticles('hit', paddle2.x - paddle2.w/2, self.y, {rotation = math.pi})
            self.v.x = -(1.07 + 0.01*level)*self.v.x 
            self.rotation_speed = paddle2.v/4
            self.angle_speed = paddle2.v/96
            mg.timer:cancel('r_speed_add')
            mg.timer:tween('r_speed_add', 1.5, self, {r = 30 - math.abs(12.5*self.angle_speed)}, 'in-out-cubic')

            paddle2.idle = true
            self.just_hit_paddle = true
            mg.timer:after(0.2, function() self.just_hit_paddle = false end)
        end
    end

    if self.dead then
        if self.x > 400 then level = level + 1 end
        if self.x < 400 then level = level - 1 end
        paddle2.idle = false
        table.insert(balls, Ball(400, 300))
    end
end

function Ball:draw()
    mg.utils.graphics.pushRotate(self.x, self.y, self.rotation)
    local r = self.r + self.r_add
    love.graphics.rectangle('fill', self.x - r/2, self.y - r/2, r, r)
    love.graphics.pop()
end
