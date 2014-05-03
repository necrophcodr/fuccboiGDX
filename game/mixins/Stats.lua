Stats = {
    statsInit = function(self, stats_table)
        for k, v in pairs(stats_table) do
            self[k] = v
        end
        self.max_hp = self.hp
    end,

    statsHp = function(self, damage)
        if not self.hp then return end
        self.hp = self.hp + damage
        if self.class.name == 'Player' then ui.hp_bar:changeHp() end
        if self.hp <= 0 then 
            self.hp = 0
            if self.die then self:die()
            else self.dead = true end
        elseif self.hp >= self.max_hp then
            self.hp = self.max_hp
        end
    end,

    statsDraw = function(self)
        if equalsAny(self.class.name, {'Blaster', 'Pumper', 'Roller', 'Bomber'}) then
            local angle = self.visual_angle 
            if not angle then angle = self.body:getAngle() end
            local x, y = self.body:getPosition()
            local sx, sy = 1, 1
            if self.class.name == 'Bomber' then angle = angle + math.pi/2 end
            pushRotateScale(x, y, angle, sx, sy)
            if self.class.name == 'Blaster' then
                x, y = x - 12*math.cos(angle) + 8*math.sin(angle), y - 24
            elseif self.class.name == 'Roller' then
                x, y = x - 12*math.cos(angle) + 3*math.sin(angle), y - 22
            elseif self.class.name == 'Pumper' then
                x, y = x - 12*math.cos(angle), y - 22
            elseif self.class.name == 'Bomber' then
                x, y = x - 12, y + 14
            end
            love.graphics.setColor(32, 32, 32, 255)
            love.graphics.rectangle('fill', x, y, 24, 4)
            love.graphics.setColor(160, 48, 48, 255)
            if self.class.name == 'Bomber' then
                love.graphics.rectangle('fill', x + (24 - 24*(self.hp/self.max_hp)), y, 24*(self.hp/self.max_hp), 4)
            else love.graphics.rectangle('fill', x, y, 24*(self.hp/self.max_hp), 4) end
            love.graphics.setColor(0, 0, 0, 255)
            love.graphics.rectangle('line', x, y, 24, 4)
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.pop()
        end
    end
}
