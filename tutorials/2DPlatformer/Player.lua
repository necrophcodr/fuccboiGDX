Player = mg.class('Player', mg.Entity)
Player:include(mg.PhysicsBody)

function Player:init(world, x, y, settings)
    mg.Entity.init(self, world, x, y, settings)
    self:physicsBodyInit(world, x, y, settings)

    mg.input:bind('a', 'move_left')
    mg.input:bind('d', 'move_right')
    self.direction = 'right'

    self.animation_state = 'idle'
    self.idle = mg.Animation(love.graphics.newImage('idle.png'), 32, 32, 0)
    self.run = mg.Animation(love.graphics.newImage('run.png'), 32, 32, 0.1)
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
        self.body:setLinearVelocity(0.8*vx, vy)
    end

    local vx, vy = self.body:getLinearVelocity()
    if math.abs(vx) < 25 then self.animation_state = 'idle'
    else self.animation_state = 'run' end
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
