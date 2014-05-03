classes['Solid'] = class('Solid', Entity); local Solid = classes['Solid']
Solid:include(PhysicsChain)
Solid:include(Timer)

function Solid:init(world, x, y, settings) 
    Entity.init(self, world, x, y, settings)
    self:timerInit()
    self:physicsChainInit(self.world.world, x, y, settings.vertices, 'static')

    self.added_vertices = {unpack(self.vertices)}
    self.timer:every(0.05, function()
		self.added_vertices = {unpack(self.vertices)}
		for i, v in ipairs(self.added_vertices) do
			self.added_vertices[i] = self.added_vertices[i] + rng:random(-0.75, 0.75)
		end
    end)
end

function Solid:update(dt)
	self:timerUpdate(dt)
end

function Solid:draw()
	love.graphics.setLineStyle('smooth')
	for i = 1, #self.added_vertices-2, 2 do
		love.graphics.setColor(244, 244, 244, 200)
		love.graphics.setLineWidth(1.5)
    	love.graphics.line(640 + self.added_vertices[i], self.added_vertices[i+1], 640 + self.added_vertices[i+2], self.added_vertices[i+3])
		love.graphics.setColor(192, 192, 192)
		love.graphics.setLineWidth(0.75)
    	love.graphics.line(640 + self.added_vertices[i], self.added_vertices[i+1], 640 + self.added_vertices[i+2], self.added_vertices[i+3])
    end
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(1)
	self:physicsChainDraw()
end