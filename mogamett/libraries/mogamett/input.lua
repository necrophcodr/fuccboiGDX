local input = {}
input.__index = input

local function new()
    return setmetatable({prev_state = {}, state = {}, binds = {}}, input)
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

local key_to_button = {mouse1 = 'l', mouse2 = 'r', mouse3 = 'm', wheelup = 'wd', wheeldown = 'wd', mouse4 = 'x1', mouse5 = 'x2'}

function input:down(action)
    for _, key in ipairs(self.binds[action]) do
        if (love.keyboard.isDown(key) or love.mouse.isDown(key_to_button[key] or '')) then
            return true
        end
    end
end

local copy = function(t1)
    local out = {}
    for k, v in pairs(t1) do out[k] = v end
    return out
end

function input:update(dt)
    self.prev_state = copy(self.state)
end

function input:keypressed(key)
    self.state[key] = true
end

function input:keyreleased(key)
    self.state[key] = false
end

local button_to_key = {l = 'mouse1', r = 'mouse2', m = 'mouse3', wd = 'wheelup', wu = 'wheeldown', x1 = 'mouse4', x2 = 'mouse5'}

function input:mousepressed(button)
    self.state[button_to_key[button]] = true
end

function input:mousereleased(button)
    self.state[button_to_key[button]] = false
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
