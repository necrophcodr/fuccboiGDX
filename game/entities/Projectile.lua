classes['Projectile'] = class('Projectile', Entity); local Projectile = classes['Projectile']
Projectile:include(PhysicsCircle)
Projectile:include(Timer)
Projectile:include(Particler)

function Projectile:init(world, x, y, settings)
	Entity.init(self, world, x, y, settings)
	self:timerInit()
	self:physicsCircleInit(self.world.world, x, y, 'dynamic', 4)
    self:particlerInit()
	self.body:setGravityScale(1)
	self.body:setLinearVelocity(self.v*math.cos(self.angle), self.v*math.sin(self.angle))
	self.i_r = self.r
	self.r = 0.1
    local r = math.random(0.5, 1)
	self.timer:tween(r, self, {r = self.i_r}, 'in-elastic')
    self.timer:after(r, function()
        local m = 1
        if self.world.player.sticky_light then m = 4 end
        local r = math.random(8*m, 16*m)
        self.timer:tween(r, self, {r = 0}, 'linear')
        self.timer:after(r, function() self.dead = true end)

        if self.world.player.laser_light then
            if math.random(1, 8) <= self.world.player.laser_light then
                self.dead = true
                local angles = {}
                for i = 1, 24 do table.insert(angles, i*2*math.pi/24) end
                for k = 1, #angles do
                    local angle = angles[k]
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
                            goto continue
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
                                self.world:createToGroup('FlashLine', 0, 0, {x1 = self.x + 8*math.cos(angle), y1 = self.y + 8*math.sin(angle), 
                                                                             x2 = hitx, y2 = hity})
                                self:particlerSpawn('HitBig', hitx, hity, {rotation = math.pi+angle})
                                self.world:cameraShakeAdd(0.5, 0.25)
                                goto continue 
                            end
                        end
                    end
                    ::continue::
                end
            end
        end
    end)
    self:particlerSpawn('SmokeUp', self.x, self.y, {parent = self})
    self.sticked = false
end

function Projectile:update(dt)
	self.x, self.y = self.body:getPosition()
	self:timerUpdate(dt)
    self:particlerUpdate(dt)

    if self.sticked then self.body:setLinearVelocity(0, 0) end

    if self.x < 50 then 
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(-vx, vy)
    end

    if self.x > 1950 then
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(-vx, vy)
    end
end

function Projectile:draw()
	love.graphics.setColor(244, 244, 244)
	love.graphics.circle('fill', self.x, self.y, self.r + math.random(0, 0.55), 360)
    self:particlerDraw()
	self:physicsCircleDraw()	
end

function Projectile:handleCollisions(type, object, nx, ny, contact)
    if type == 'enter' then
        if object.class.name == 'Solid' then
            if self.world.player.sticky_light then
                self.sticked = true
            end
        end
    end
end

collision_table['Projectile'] = {
    c('enter', 'Solid'),
}
