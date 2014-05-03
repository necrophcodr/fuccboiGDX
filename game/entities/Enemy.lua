classes['Enemy'] = class('Enemy', Entity); local Enemy = classes['Enemy']
Enemy:include(PhysicsCircle)
Enemy:include(Steerable)
Enemy:include(Timer)
Enemy:include(Particler)

function Enemy:init(world, x, y, settings)
	Entity.init(self, world, x, y, settings)
	self:timerInit()
	self:physicsCircleInit(self.world.world, x, y, 'dynamic', 4)
    self:particlerInit()
    self:steerableInit(0, 0, 100, 2000, 2)
	self.body:setGravityScale(-1)
    self.world:createToGroup('Flash', self.x, self.y, {parent = self, x_offset = 0, y_offset = 2, size = 2, permanent = true})
    self.added_vertices = {}
    self.alpha = 0
    self.active = false
    self.vertices = {0, 0 + self.h,
                     0 - self.w/2, 0 + self.h/2,
                     0 - self.w, 0,
                     0 - self.w/2, 0 - self.h/2,
                     0, 0 - self.h,
                     0 + self.w/2, 0 - self.h/2,
                     0 + self.w, 0,
                     0 + self.w/2, 0 + self.h/2}
    self.random_offsets = {}
    self.offset_intensity = 0
    self.scale_x = 1
    self.scale_y = 1
    self.timer:tween(math.prandom(0.5, 2), self, {alpha = 255}, 'in-out-cubic')
    self.body:setAngle(math.pi/2)
    for i = 1, #self.vertices do self.random_offsets[i] = 0 end
    self.timer:every(0.05, function()
    	for i = 1, #self.vertices do self.random_offsets[i] = math.prandom(-self.offset_intensity, self.offset_intensity) end
    end)
end

function Enemy:update(dt)
	self.x, self.y = self.body:getPosition()
	self:timerUpdate(dt)
    self:particlerUpdate(dt)
    self:steerableUpdate(dt)

    if self.world.player.x > self.x then self.active = true end
    if self.active then
        self.current_behavior = 'seek'
        self.target = Vector(self.world.player.x, self.world.player.y)
    end

	local vx, vy = self.body:getLinearVelocity()
	local len = math.min(Vector(vx, vy):len(), self.max_v)
	self.scale_x = 1 - 0.0042*math.abs(len)
	self.scale_y = 1 - 0.0042*math.abs(len)
	self.offset_intensity = 0.015*math.abs(len) + 1
end

function Enemy:draw()
    self.added_vertices = {unpack(self.vertices)}
    for i, v in ipairs(self.added_vertices) do
		if i % 2 == 0 then self.added_vertices[i] = self.added_vertices[i] + self.y
		else self.added_vertices[i] = self.added_vertices[i] + self.x end
    end
    for i, p in ipairs(self.added_vertices) do
        self.added_vertices[i] = self.added_vertices[i] + self.random_offsets[i] or 0
    end
    pushRotateScale(self.x, self.y, self.body:getAngle(), self.scale_x, self.scale_y)
    love.graphics.setColor(32, 32, 32, self.alpha)
	love.graphics.polygon('fill', unpack(self.added_vertices))
    love.graphics.pop()
    pushRotateScale(self.x, self.y + 2, self.body:getAngle(), self.scale_x, self.scale_y)
    love.graphics.setColor(244, 0, 0, self.alpha)
    love.graphics.circle('fill', self.x, self.y + 2, 1.5 + math.prandom(-0.5, 0.5), 24)
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)
	self:physicsCircleDraw()	
    self:particlerDraw()
end
