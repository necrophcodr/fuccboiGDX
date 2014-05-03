PhysicsChain = {
	physicsChainInit = function(self, world, x, y, vertices, body_type)
		self.body = love.physics.newBody(world, x, y, body_type)
		self.shape = love.physics.newChainShape(false, unpack(vertices))

		self.fixture = love.physics.newFixture(self.body, self.shape)
        self.fixture:setCategory(unpack(collision_masks[self.class.name].categories))
        self.fixture:setMask(unpack(collision_masks[self.class.name].masks))
        self.fixture:setUserData(self)

        self.sensor = love.physics.newFixture(self.body, self.shape)
        self.sensor:setSensor(true)
        self.sensor:setUserData(self)
	end,

	physicsChainDraw = function(self)
		if debug_draw then
			love.graphics.setLineWidth(2)
	        love.graphics.setColor(64, 128, 244)
	        local points = {self.body:getWorldPoints(self.shape:getPoints())}
	        for i = 1, #points, 2 do
	        	if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
	        end
	        love.graphics.setColor(255, 255, 255)
			love.graphics.setLineWidth(1)
		end	
	end
}