Girl = mg.class('Girl', mg.Entity)
Girl:include(mg.PhysicsBody)

function Girl:init(world, x, y, settings)
    mg.Entity.init(self, world, x, y, settings)
    self:physicsBodyInit(world, x, y, settings)

    self.idle_animation = mg.Animation(love.graphics.newImage('idle.png'), 64, 64, 0.1)
    self.run_animation = mg.Animation(love.graphics.newImage('run.png'), 64, 64, 0.1)

    if self.controlled then
        mg.world.camera:follow(self, {lerp = 1})
        mg.world.camera:setBounds(0, 0, 800, 600)
        mg.world.camera.debug_draw = true
        mg.input:bind('a', 'move left')
        mg.input:bind('d', 'move right')
    end
end

function Girl:update(dt)
    self:physicsBodyUpdate(dt) 
    self.idle_animation:update(dt)

    if self.controlled then
        if mg.input:down('move left') then
            local vx, vy = self.body:getLinearVelocity()
            self.body:setLinearVelocity(-200, vy)
        end

        if mg.input:down('move right') then
            local vx, vy = self.body:getLinearVelocity()
            self.body:setLinearVelocity(200, vy)
        end

        if not mg.input:down('move left') and not mg.input:down('move right') then
            local vx, vy = self.body:getLinearVelocity()
            self.body:setLinearVelocity(0.9*vx, vy)
        end
    end
end

function Girl:draw()
    self:physicsBodyDraw()
    self.idle_animation:draw(self.x, self.y)
end
