local input = {}
input.__index = input

local mappings = love.filesystem.read(mogamett_path .. '/resources/gamecontrollerdb.txt')
love.joystick.loadGamepadMappings(mappings)

local function new()
    return setmetatable({prev_state = {}, state = {}, binds = {}, joysticks = love.joystick.getJoysticks()}, input)
end

function input:bind(key, action)
    if not self.binds[action] then self.binds[action] = {} end
    table.insert(self.binds[action], key)
end

function input:pressed(action)
    for _, key in ipairs(self.binds[action]) do
        if self.state[key] and not self.prev_state[key] then
            return true
        end
    end
end

function input:released(action)
    for _, key in ipairs(self.binds[action]) do
        if self.prev_state[key] and not self.state[key] then
            return true
        end
    end
end

local key_to_button = {mouse1 = 'l', mouse2 = 'r', mouse3 = 'm', wheelup = 'wu', wheeldown = 'wd', mouse4 = 'x1', mouse5 = 'x2'}
local gamepad_to_button = {fdown = 'a', fup = 'y', fleft = 'x', fright = 'b', back = 'back', guide = 'guide', start = 'start',
                           leftstick = 'leftstick', rightstick = 'rightstick', l1 = 'leftshoulder', r1 = 'rightshoulder',
                           dpup = 'dpup', dpdown = 'dpdown', dpleft = 'dpleft', dpright = 'dpright'}
local axis_to_button = {leftx = 'leftx', lefty = 'lefty', rightx = 'rightx', righty = 'righty', l2 = 'triggerleft', r2 = 'triggerright'}

function input:down(action)
    for _, key in ipairs(self.binds[action]) do
        if (love.keyboard.isDown(key) or love.mouse.isDown(key_to_button[key] or '')) then
            return true
        end
        if self.joysticks[1] then
            if axis_to_button[key] then
                return self.state[key]
            elseif gamepad_to_button[key] then
                if self.joysticks[1]:isGamepadDown(gamepad_to_button[key]) then
                    return true
                end
            end
        end
    end
end

function input:unbind(key)
    for action, keys in pairs(self.binds) do
        for i = #keys, 1, -1 do
            if key == self.binds[action][i] then
                table.remove(self.binds[action], i)
            end
        end
    end
end

function input:unbindAll()
    self.binds = {}
end

local copy = function(t1)
    local out = {}
    for k, v in pairs(t1) do out[k] = v end
    return out
end

function input:update(dt)
    self.prev_state = copy(self.state)
    self.state['wheelup'] = false
    self.state['wheeldown'] = false
end

function input:keypressed(key)
    self.state[key] = true
end

function input:keyreleased(key)
    self.state[key] = false
end

local button_to_key = {l = 'mouse1', r = 'mouse2', m = 'mouse3', wu = 'wheelup', wd = 'wheeldown', x1 = 'mouse4', x2 = 'mouse5'}

function input:mousepressed(button)
    self.state[button_to_key[button]] = true
end

function input:mousereleased(button)
    self.state[button_to_key[button]] = false
end

local button_to_gamepad = {a = 'fdown', y = 'fup', x = 'fleft', b = 'fright', back = 'back', guide = 'guide', start = 'start',
                           leftstick = 'leftstick', rightstick = 'rightstick', leftshoulder = 'l1', rightshoulder = 'r1',
                           dpup = 'dpup', dpdown = 'dpdown', dpleft = 'dpleft', dpright = 'dpright'}

function input:gamepadpressed(joystick, button)
    self.state[button_to_gamepad[button]] = true 
end

function input:gamepadreleased(joystick, button)
    self.state[button_to_gamepad[button]] = false
end

local button_to_axis = {leftx = 'leftx', lefty = 'lefty', rightx = 'rightx', righty = 'righty', triggerleft = 'l2', triggerright = 'r2'}

function input:gamepadaxis(joystick, axis, newvalue)
    self.state[button_to_axis[axis]] = newvalue
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
