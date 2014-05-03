Particler = {
    particlerInit = function(self)
        self.particle_systems = {}
    end,

    particlerSpawn = function(self, name, x, y, settings)
        local ps = {ps = self.world:particleSpawn(name, x, y)}
        if settings then
            for k, v in pairs(settings) do ps[k] = v end
        end
        table.insert(self.particle_systems, ps)
    end,

    particlerUpdate = function(self, dt)
        for i = #self.particle_systems, 1, -1 do
            if not self.particle_systems[i].ps then return end
            if not self.particle_systems[i].ps.ps then return end
            if self.particle_systems[i].ps.ps then
                self.particle_systems[i].ps.ps:update(dt)
            end

            if self.particle_systems[i].parent then
                if not self.particle_systems[i].parent.dead then
                    self.particle_systems[i].ps.ps:setPosition(self.particle_systems[i].parent.x, self.particle_systems[i].parent.y)
                end
            end

            if self.particle_systems[i].rotation then
                self.particle_systems[i].ps.ps:setDirection(self.particle_systems[i].rotation)
            end

            -- Emitters that are time based should be removed once their time is up
            local lifetime = self.particle_systems[i].ps.ps:getEmitterLifetime()
            if lifetime > 0 then
                local t = love.timer.getTime() - self.particle_systems[i].ps.last_get_time
                if t > lifetime then self.particle_systems[i].ps.ps:stop() end
                if t > 3*lifetime then
                    self.world:particleFree(self.particle_systems[i].ps.name, self.particle_systems[i].ps.id)
                    table.remove(self.particle_systems, i) 
                end
            end
        end
    end,

    particlerDraw = function(self)
        for _, ps in ipairs(self.particle_systems) do
            local x, y = ps.ps.ps:getPosition()
            love.graphics.draw(ps.ps.ps, 0, 0) 
        end
    end,
}
