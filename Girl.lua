Girl = mg.class('Girl', mg.Entity)
Girl:include(mg.PhysicsBody)

function Girl:init(world, x, y, settings)
    mg.Entity.init(self, world, x, y, settings)
    self:physicsBodyInit(world, x, y, settings)

    self.idle_animation = mg.Animation(love.graphics.newImage('idle.png'), 64, 64, 0.1)
    self.run_animation = mg.Animation(love.graphics.newImage('run.png'), 64, 64, 0.1)
    print(self.idle_animation.size)
end

function Girl:update(dt)
    self:physicsBodyUpdate(dt) 
    self.idle_animation:update(dt)
end

function Girl:draw()
    self:physicsBodyDraw()
    self.idle_animation:draw(self.x, self.y)
end
