local CameraShake = {
    cameraShakeInit = function(self)
        self.uid = 0
        self.p = Vector(self.camera:pos())
        self.v = Vector(0, 0)
        self.a = Vector(0, 0)
        self.shakes = {}
        self.shake_intensity = 0
        self.max_intensity = 15
    end,

    cameraShakeUpdate = function(self, dt)
        self.shake_intensity = 0
        self.p = Vector(self.camera:pos())
        for _, shake in ipairs(self.shakes) do
            if love.timer.getTime() > shake.creation_time + shake.duration then
                self:cameraShakeRemove(shake.id)
            else 
                if self.shake_intensity + shake.intensity < self.max_intensity then
                    self.shake_intensity = self.shake_intensity + shake.intensity
                end
            end
        end

        --[[
        self.shake_intensity = math.min(self.shake_intensity, 10)
        self.camera:lookAt(self.p.x + math.prandom(-self.shake_intensity, self.shake_intensity),
                           self.p.y + math.prandom(-self.shake_intensity, self.shake_intensity))
        if self.shake_intensity == 0 then self.camera:lookAt(self.p.x, self.p.y) end
        ]]--

        self.v = Vector(math.prandom(-self.shake_intensity, self.shake_intensity), math.prandom(-self.shake_intensity, self.shake_intensity))
        self.camera:move(self.v.x, self.v.y)
        if self.shake_intensity == 0 then self.camera:lookAt(self.p.x, self.p.y) end
    end,

    cameraShakeAdd = function(self, intensity, duration)
        self.uid = self.uid + 1
        table.insert(self.shakes, {creation_time = love.timer.getTime(), id = self.uid, intensity = intensity, duration = duration})
    end,

    cameraShakeAddPos = function(self, x, y, intensity, duration)
        local d = Vector.distance(Vector(x, y), Vector(self.player.x, self.player.y))
        self:cameraShakeAdd(math.max(intensity - intensity*d/512, 0), duration)
    end,

    cameraShakeRemove = function(self, id)
        table.remove(self.shakes, findIndexByID(self.shakes, id))
    end
}

return CameraShake
