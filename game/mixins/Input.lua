Input = {
    inputInit = function(self, in_action_struct)
        self.action_struct = in_action_struct
    end,

    inputUpdate = function(self, dt)
        for action, a_table in pairs(self.action_struct) do
            if a_table.down then
                for _, key in ipairs(a_table.keys) do
                    if key == 'space' then key = ' ' end
                    if love.keyboard.isDown(key) then
                        if action == 'move_left' then self:moveLeft()
                        elseif action == 'move_right' then self:moveRight() end
                    end
                end
            end
        end
    end,

    inputKeypressed = function(self, in_key)
        for action, a_table in pairs(self.action_struct) do
            if a_table.press then
                for _, key in ipairs(a_table.keys) do
                    if key == 'space' then key = ' ' end
                    if in_key == key then
                        if equalsAny(action, {'move_right', 'move_left'}) then self:movePressed(action)
                        elseif action == 'jump' then self:jumpPressed() end
                    end
                end
            end
        end
    end,

    inputKeyreleased = function(self, in_key)
        for action, a_table in pairs(self.action_struct) do
            if a_table.release then
                for _, key in ipairs(a_table.keys) do
                    if key == 'space' then key = ' ' end
                    if in_key == key then
                        if equalsAny(action, {'move_right', 'move_left'}) then self:moveReleased()
                        elseif action == 'jump' then self:jumpReleased() end
                    end
                end
            end
        end
    end
}
