Player = mg.class('Player', mg.Entity)
Player:include(mg.PhysicsBody)

Player.static.enter = {'Solid'}

function Player:init(world, x, y, settings)
    mg.Entity.init(self, world, x, y, settings)
    self:physicsBodyInit(world, x, y, settings)

    self.fixture:setFriction(0)

    mg.input:bind('a', 'move_left')
    mg.input:bind('d', 'move_right')
    mg.input:bind(' ', 'jump')

    mg.world.camera:follow(self, {lerp = 1, follow_style = 'platformer'})

    self.direction = 'right'
    self.jumping = false
    self.max_jumps = 2
    self.jumps_left = 1
    self.jump_press_time = 0

    self.animation_state = 'idle'
    self.idle = mg.Animation(love.graphics.newImage('idle.png'), 32, 32, 0)
    self.run = mg.Animation(love.graphics.newImage('run.png'), 32, 32, 0.1)
    self.jump = mg.Animation(love.graphics.newImage('jump.png'), 32, 32, 0)
    self.fall = mg.Animation(love.graphics.newImage('fall.png'), 32, 32, 0)
end

function Player:update(dt)
    self:physicsBodyUpdate(dt)

    if mg.input:down('move_left') then
        self.direction = 'left'
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(-150, vy)
    end
    if mg.input:down('move_right') then
        self.direction = 'right'
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(150, vy)
    end
    if not mg.input:down('move_left') and not mg.input:down('move_right') then
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(vx*40.94*dt, vy)
    end

    if mg.input:pressed('jump') then
        if self.jumps_left > 0 then
            local vx, vy = self.body:getLinearVelocity()
            self.body:setLinearVelocity(vx, -250)
            self.jumping = true
            self.jumps_left = self.jumps_left - 1
            self.jump_press_time = love.timer.getTime()
        end
    end

    if mg.input:released('jump') then
        local stopJump = function()
            self.jump_press_time = 0
            local vx, vy = self.body:getLinearVelocity()
            if vy < 0 then self.body:setLinearVelocity(vx, 0) end
        end
        local dt = love.timer.getTime() - self.jump_press_time
        if dt >= 0.125 then stopJump()
        else mg.timer:after(0.125 - dt, function() stopJump() end) end
    end

    local vx, vy = self.body:getLinearVelocity()
    if math.abs(vx) < 25 then self.animation_state = 'idle'
    else self.animation_state = 'run' end
    if self.jumping then self.animation_state = 'jump' end
    if vy > 5 then self.animation_state = 'fall' end
    self[self.animation_state]:update(dt)
end

function Player:draw()
    self:physicsBodyDraw()
    if self.direction == 'right' then
        self[self.animation_state]:draw(self.x - self[self.animation_state].frame_width/2, 
                                        self.y - self[self.animation_state].frame_height/2 - 2)
    else
        self[self.animation_state]:draw(self.x + self[self.animation_state].frame_width/2, 
                                        self.y - self[self.animation_state].frame_height/2 - 2, 0, -1, 1)
    end
end

function Player:onCollisionEnter(object, contact)
    if object.class.name == 'Solid' then
        local solid_top = object.y - object.h/2
        local player_bottom = self.y + self.h/2 - 4
        if solid_top > player_bottom then
            self.jumping = false
            self.jumps_left = self.max_jumps
        end
    end
end
