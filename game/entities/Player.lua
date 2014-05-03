classes['Player'] = class('Player', Entity); local Player = classes['Player']
Player:include(PhysicsPolygon)
Player:include(Timer)
Player:include(Input)
Player:include(Movable)
Player:include(Jumper)
Player:include(Particler)

function Player:init(world, x, y, settings)
	Entity.init(self, world, x, y, settings)
	self:timerInit()
	self:inputInit(player_keys)
	self.w = 8
	self.h = 8
    self.verticeb = {0, self.h + self.h/4 - self.h/4,
                     0 - self.w + self.w/8 + self.w/4, self.h/2 - self.h/4,
                     0 - self.w + self.w/4, 0,
                     0 - 2*self.w/3 + self.w/4, 0 - self.h/2 + self.h/4,
                     0, 0 - self.h - self.h/4 + self.h/4,
                     0 + 2*self.w/3 - self.w/4, 0 - self.h/2 + self.h/4,
                     0 + self.w - self.w/4, 0,
                     0 + self.w - self.w/8 - self.w/4, self.h/2 - self.h/4}
	self:physicsPolygonInit(self.world.world, x, y, self.verticeb, 'dynamic')
	self:movableInit(50, 2000, 1)
	self:jumperInit(-50, 2)
    self:particlerInit()

	self.scale_x = 1
	self.scale_y = 1
	self.angle = self.body:getAngle() - math.pi/4
	self.angle_v = 0
	self.angle_v_direction = 1

	self.added_vertices = {}
    self.vertices = {0, self.h + self.h/4,
                     0 - self.w/3, self.h + self.h/8,
                     0 - self.w + self.w/8, self.h/2,
                     0 - self.w, 0,
                     0 - 2*self.w/3, 0 - self.h/2,
                     0 - self.w/3, 0 - self.h - self.h/8,
                     0, 0 - self.h - self.h/4,
                     0 + self.w/3, 0 - self.h - self.h/8,
                     0 + 2*self.w/3, 0 - self.h/2,
                     0 + self.w, 0,
                     0 + self.w - self.w/8, self.h/2,
                     0 + self.w/3, self.h + self.h/8}
    self.random_offsets = {}
    self.offset_intensity = 0
    for i = 1, #self.vertices do self.random_offsets[i] = 0 end
    self.timer:every(0.05, function()
    	for i = 1, #self.vertices do self.random_offsets[i] = math.prandom(-self.offset_intensity, self.offset_intensity) end
    end)

    self.hp = 20
    self.max_hp = 20
    self.ammo = 50
    self.max_ammo = 50
    self.pistol = false 
    self.laser_light = false
    self.sticky_light = false
    self.breaking_light = false
    self.bigger_lights = false
    self.damaging_lights = false
    self.double_mana_gain = false
    self.double_hp_gain = false
    self.invulnerable = false
    self.map_change = false
end

function Player:loseHP()
    if self.invulnerable then return end
    self.invulnerable = true
    self:timerCancel('inv')
    self:timerAfter('inv', 1, function() self.invulnerable = false end)
    local hp_nodes = self.world:getEntitiesFromGroup('HPNode')
    if #hp_nodes <= 0 then self:die(); return end
    self.hp = self.hp - 1
    self.world:createToGroup('Text', self.x, self.y, {text = '-1hp', fast = true})
    local hp_node = hp_nodes[math.random(1, #hp_nodes)]
    hp_node.dead = true
    self:particlerSpawn('HPDead', hp_node.x, hp_node.y)
end

function Player:loseAmmo()
    local ammo_nodes = self.world:getEntitiesFromGroup('AmmoNode')
    if #ammo_nodes <= 0 then return end
    self.ammo = self.ammo - 1
    -- self.world:createToGroup('Text', self.x, self.y, {text = '-1mana', fast = true})
    local ammo_node = ammo_nodes[math.random(1, #ammo_nodes)]
    ammo_node.dead = true
    self:particlerSpawn('AmmoDead', ammo_node.x, ammo_node.y)
end

function Player:die()
    self.world:playerDead()
end

function Player:update(dt)
	self.x, self.y = self.body:getPosition()
	self:timerUpdate(dt)
	self:inputUpdate(dt)
	self:movableUpdate(dt)
	self:jumperUpdate(dt)
    self:particlerUpdate(dt)

	if self.direction == 'left' then self.angle_v_direction = -1
	else self.angle_v_direction = 1 end

	local vx, vy = self.body:getLinearVelocity()
	local len = math.min(Vector(vx, vy):len(), self.max_v)
	self.angle = self.angle + self.angle_v*dt
	self.angle_v = self.angle_v_direction*0.16*math.abs(len)
	self.scale_x = 1 - 0.0042*math.abs(len)
	self.scale_y = 1 - 0.0042*math.abs(len)
	self.offset_intensity = 0.015*math.abs(len) + 1

    if self.x < 50 and self.direction == 'left' then 
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(0, vy)
    end

    if self.x > 1950 and self.direction == 'right' then
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(0, vy)
        if not self.map_change then
            self.map_change = true
            self.x = 120
            self.y = 120
            mapn = mapn + 1
            self.world:mapChange(mapn)
        end
    end
end

function Player:draw()
	self.added_vertices = {unpack(self.vertices)}
	for i, v in ipairs(self.added_vertices) do
		if i % 2 == 0 then self.added_vertices[i] = self.added_vertices[i] + self.y
		else self.added_vertices[i] = self.added_vertices[i] + self.x end
	end
	for i, p in ipairs(self.added_vertices) do
		self.added_vertices[i] = self.added_vertices[i] + self.random_offsets[i] or 0
	end

	pushRotateScale(self.x, self.y, self.angle, self.scale_x, self.scale_y)
	love.graphics.setColor(183, 196, 217)	
	love.graphics.polygon('fill', unpack(self.added_vertices))
	love.graphics.setColor(255, 255, 255)
	love.graphics.pop()
	self:physicsPolygonDraw()
    self:particlerDraw()
end

function Player:keypressed(key)
	self:inputKeypressed(key)	
end

function Player:keyreleased(key)
	self:inputKeyreleased(key)
end

function Player:mousepressed(x, y, button)
    if button == 'r' then
        if self.world.hp_ammo then 
            self:loseAmmo() 
            local ammo_nodes = self.world:getEntitiesFromGroup('AmmoNode')
            if #ammo_nodes <= 0 then return end
        end
        local wx, wy = self.world.camera:worldCoords(game_mouse.x, game_mouse.y)
        local angle = math.atan2(wy-self.y, wx-self.x)
        self.world:createToGroup('Projectile', self.x, self.y, {angle = angle, v = math.random(40, 60)})
    end
    
    if button == 'l' then
        if self.pistol then
            if self.world.hp_ammo then 
                self:loseAmmo() 
                local ammo_nodes = self.world:getEntitiesFromGroup('AmmoNode')
                if #ammo_nodes <= 0 then return end
            end
            local wx, wy = self.world.camera:worldCoords(game_mouse.x, game_mouse.y)
            local angle = math.atan2(wy-self.y, wx-self.x)
            self.world:createToGroup('Flash', self.x + 8*math.cos(angle), self.y + 8*math.sin(angle))
            self:particlerSpawn('HitNormal', self.x + 8*math.cos(angle), self.y + 8*math.sin(angle), {rotation = angle})
            self.world:cameraShakeAdd(0.5, 0.25)
            local enemies = self.world:getEntitiesFromGroup('Enemy')
            for _, enemy in ipairs(enemies) do
                local x1, y1 = self.x + 8*math.cos(angle), self.y + 8*math.sin(angle)
                local x2, y2 = self.x + 2008*math.cos(angle), self.y + 2008*math.sin(angle)
                local xn, yn, fraction = enemy.shape:rayCast(x1, y1, x2, y2, 1, enemy.x, enemy.y, enemy.body:getAngle(), 1)
                if xn and yn and fraction then
                    local hitx, hity = x1 + (x2 - x1)*fraction, y1 + (y2 - y1)*fraction
                    local ens = self.world:queryAreaCircle(Vector(hitx, hity), 50, {'Enemy'})
                    for _, e in ipairs(ens) do e.active = true end
                    self.world:createToGroup('Flash', hitx, hity, {long = true})
                    self.world:createToGroup('FlashLine', 0, 0, {x1 = self.x + 8*math.cos(angle), y1 = self.y + 8*math.sin(angle), x2 = hitx, y2 = hity})
                    self:particlerSpawn('HitBig', hitx, hity, {rotation = math.pi+angle})
                    enemy.dead = true
                    self:particlerSpawn('EnemyDead', hitx, hity)
                    if math.random(1, 2) == 1 then
                        self.world:createToGroup('Item', hitx, hity, {name = chooseWithProb({'HP', 'Mana'}, {0.2, 0.8})})
                    end
                    self.world:cameraShakeAdd(0.5, 0.25)
                    return
                end
            end
            local solids = self.world:getEntitiesFromGroup('Solid')
            for _, solid in ipairs(solids) do
                for i = 1, solid.shape:getChildCount() do
                    local x1, y1 = self.x + 8*math.cos(angle), self.y + 8*math.sin(angle)
                    local x2, y2 = self.x + 2008*math.cos(angle), self.y + 2008*math.sin(angle)
                    local xn, yn, fraction = solid.shape:rayCast(x1, y1, x2, y2, 1, solid.x, solid.y, solid.body:getAngle(), i)
                    if xn and yn and fraction then
                        local hitx, hity = x1 + (x2 - x1)*fraction, y1 + (y2 - y1)*fraction
                        local ens = self.world:queryAreaCircle(Vector(hitx, hity), 50, {'Enemy'})
                        for _, e in ipairs(ens) do e.active = true end
                        self.world:createToGroup('Flash', hitx, hity, {long = true})
                        self.world:createToGroup('FlashLine', 0, 0, {x1 = self.x + 8*math.cos(angle), y1 = self.y + 8*math.sin(angle), x2 = hitx, y2 = hity})
                        self:particlerSpawn('HitBig', hitx, hity, {rotation = math.pi+angle})
                        self.world:cameraShakeAdd(0.5, 0.25)
                        return
                    end
                end
            end
        end
    end
end

function Player:mousereleased(x, y, button)

end

function Player:handleCollisions(type, object, nx, ny, contact)
	if type == 'enter' then
		if object.class.name == 'Solid' then
			self:jumperCollisionEnter(object, nx, ny)
        
        elseif object.class.name == 'Item' then
            object:activate(self)

        elseif object.class.name == 'Enemy' then
            self:loseHP()
		end
	end
end

collision_table['Player'] = {
	c('enter', 'Solid'),
    c('enter', 'Item'),
    c('enter', 'Enemy'),
}
