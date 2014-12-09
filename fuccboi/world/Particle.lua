local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Particle = Class:extend()

function Particle:particleNew()
    self.image = love.graphics.newImage(fuccboi_path .. '/resources/particles/sperm/square.png')
    self.particle_systems = {}
    self.template_particle_systems = {}
    self.to_be_removed = {}

    local sperm_files = love.filesystem.getDirectoryItems(fuccboi_path .. '/resources/particles/sperm')
    local names = {}
    for _, file in ipairs(sperm_files) do
        if file ~= 'main.lua' and file ~= 'conf.lua' and string.sub(file, -3) ~= 'png' and string.sub(file, -3) == 'lua' then
            table.insert(names, string.sub(file, 1, -5))
        end
    end
    for _, name in ipairs(names) do
        self.template_particle_systems[name] = {}
        for i = 1, 100 do 
            table.insert(self.template_particle_systems[name], 
                        {id = self.fg.getUID(), name = name, last_get_time = 0, in_use = false, ps = self:_getPS(name)}) 
        end
    end
end

function Particle:_particleSpawn(name, x, y, image)
    for i = 1, 100 do
        if not self.template_particle_systems[name][i].in_use then
            self.template_particle_systems[name][i].name = name
            self.template_particle_systems[name][i].in_use = true
            self.template_particle_systems[name][i].last_get_time = love.timer.getTime()
            self.template_particle_systems[name][i].ps:setImage(image or self.image) 
            self.template_particle_systems[name][i].ps:setPosition(x, y)
            self.template_particle_systems[name][i].ps:start()
            return self.template_particle_systems[name][i]
        end
    end
end

function Particle:spawnParticles(name, x, y, settings)
    settings = settings or {}
    local ps = {ps = self:_particleSpawn(name, x, y, settings.image)}
    for k, v in pairs(settings) do ps[k] = v end
    ps.draw = function(ps)
        local x, y = ps.ps.ps:getPosition()
        love.graphics.draw(ps.ps.ps, 0, 0) 
    end
    self:addToLayer(settings.layer or 'Default', ps)
    table.insert(self.particle_systems, ps)
end

function Particle:particleUpdate(dt)
    for i = #self.particle_systems, 1, -1 do
        if not self.particle_systems[i].ps then return end
        if not self.particle_systems[i].ps.ps then return end
        if self.particle_systems[i].ps.ps then
            self.particle_systems[i].ps.ps:update(dt)
        end

        if self.particle_systems[i].follow_target then
            if not self.particle_systems[i].follow_target.dead then
                self.particle_systems[i].ps.ps:setPosition(self.particle_systems[i].follow_target.x, self.particle_systems[i].follow_target.y)
            end
        end

        if self.particle_systems[i].rotation then
            self.particle_systems[i].ps.ps:setDirection(self.particle_systems[i].rotation)
        end

        -- Kill particle system if parent is dead
        if self.particle_systems[i].ps.parent then
            if self.particle_systems[i].ps.parent.dead then
                self:_particleFree(self.particle_systems[i].ps.name, self.particle_systems[i].ps.id)
                table.remove(self.particle_systems, i) 
            end
        end

        -- Emitters that are time based should be removed once their time is up
        local lifetime = self.particle_systems[i].ps.ps:getEmitterLifetime()
        if lifetime > 0 then
            local t = love.timer.getTime() - self.particle_systems[i].ps.last_get_time
            -- if t > lifetime then self.particle_systems[i].ps.ps:stop() end
            if t > lifetime then
                self:_particleFree(self.particle_systems[i].ps.name, self.particle_systems[i].ps.id)
                table.remove(self.particle_systems, i) 
            end
        end
    end
end

function Particle:_particleFree(name, id)
    for i = 1, 100 do
        if self.template_particle_systems[name][i].id == id then
            self.template_particle_systems[name][i].in_use = false
            self.template_particle_systems[name][i].last_get_time = 0
            self.template_particle_systems[name][i].ps:setPosition(-100, -100)
            self.template_particle_systems[name][i].ps:stop()
            return
        end
    end
end

function Particle:particleDraw()

end

function Particle:_getPS(name)
    local ps_data = require (fuccboi_path .. '/resources/particles/sperm/' .. name)
    local particle_settings = {}
    particle_settings["colors"] = {}
    particle_settings["sizes"] = {}
    for k, v in pairs(ps_data) do
        if k == "colors" then
            local j = 1
            for i = 1, #v , 4 do
                local color = {v[i], v[i+1], v[i+2], v[i+3]}
                particle_settings["colors"][j] = color
                j = j + 1
            end
        elseif k == "sizes" then
            for i = 1, #v do particle_settings["sizes"][i] = v[i] end
        else particle_settings[k] = v end
    end
    local ps = love.graphics.newParticleSystem(self.image, particle_settings["buffer_size"])
    ps:setAreaSpread(string.lower(particle_settings["area_spread_distribution"]), particle_settings["area_spread_dx"] or 0, 
                     particle_settings["area_spread_dy"] or 0)
    ps:setBufferSize(particle_settings["buffer_size"] or 1)
    local colors = {}
    for i = 1, 8 do
        if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or 
           particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
            table.insert(colors, particle_settings["colors"][i][1] or 0)
            table.insert(colors, particle_settings["colors"][i][2] or 0)
            table.insert(colors, particle_settings["colors"][i][3] or 0)
            table.insert(colors, particle_settings["colors"][i][4] or 0)
        end
    end
    ps:setColors(unpack(colors))
    ps:setDirection(math.rad(particle_settings["direction"] or 0))
    ps:setEmissionRate(particle_settings["emission_rate"] or 0)
    ps:setEmitterLifetime(particle_settings["emitter_lifetime"] or 0)
    ps:setInsertMode(string.lower(particle_settings["insert_mode"]))
    ps:setLinearAcceleration(particle_settings["linear_acceleration_xmin"] or 0, particle_settings["linear_acceleration_ymin"] or 0,
                             particle_settings["linear_acceleration_xmax"] or 0, particle_settings["linear_acceleration_ymax"] or 0)
    if particle_settings["offsetx"] ~= 0 or particle_settings["offsety"] ~= 0 then
        ps:setOffset(particle_settings["offsetx"], particle_settings["offsety"])
    end
    ps:setParticleLifetime(particle_settings["plifetime_min"] or 0, particle_settings["plifetime_max"] or 0)
    ps:setRadialAcceleration(particle_settings["radialacc_min"] or 0, particle_settings["radialacc_max"] or 0)
    ps:setRotation(math.rad(particle_settings["rotation_min"] or 0), math.rad(particle_settings["rotation_max"] or 0))
    ps:setSizeVariation(particle_settings["size_variation"] or 0)
    local sizes = {}
    local sizes_i = 1
    for i = 1, 8 do
        if particle_settings["sizes"][i] == 0 then
            if i < 8 and particle_settings["sizes"][i+1] == 0 then
                sizes_i = i
                break
            end
        end
    end
    if sizes_i > 1 then
        for i = 1, sizes_i do table.insert(sizes, particle_settings["sizes"][i] or 0) end
        ps:setSizes(unpack(sizes))
    end
    ps:setSpeed(particle_settings["speed_min"] or 0, particle_settings["speed_max"] or 0)
    ps:setSpin(math.rad(particle_settings["spin_min"] or 0), math.rad(particle_settings["spin_max"] or 0))
    ps:setSpinVariation(particle_settings["spin_variation"] or 0)
    ps:setSpread(math.rad(particle_settings["spread"] or 0))
    ps:setTangentialAcceleration(particle_settings["tangential_acceleration_min"] or 0, 
                                 particle_settings["tangential_acceleration_max"] or 0)
    return ps
end

return Particle
