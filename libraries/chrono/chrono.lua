local struct = require 'libraries/chrono/struct'
local Action = struct('type', 'n', 'c', 'action', 'counter', 'parameters')

local function add(self, action)
    table.insert(self.actions, action)
end

local function remove(self, id)
    for i, c_action in ipairs(self.actions) do
        if c_action.id == id then 
            table.remove(self.actions, i)
            return
        end
    end
end

local function type_check(n, action)
    if type(n) ~= "number" then error("First argument must be a number.") end
    if type(action) ~= "function" then error("Action must be a function.") end
end

local function run_after(self, action_struct)
    if action_struct.counter >= action_struct.n then
        action_struct.action(action_struct.parameters)
        table.remove(self.actions, 1)
    end
end

local function run_every(self, action_struct)
    if action_struct.counter >= action_struct.n then
        if not action_struct.c then
            action_struct.action(action_struct.parameters)
        else 
            if action_struct.c >= 1 then
                action_struct.action(action_struct.parameters) 
                action_struct.c = action_struct.c - 1
            else table.remove(self.actions, 1) end
        end
        action_struct.counter = 0
    end
end

local function run_do_for(self, action_struct)
    if action_struct.counter < action_struct.n then
        action_struct.action(action_struct.parameters)
    else table.remove(self.actions, 1) end
end

CompositeAction = {}
CompositeAction.__index = CompositeAction

function CompositeAction.new(id)
    return setmetatable({id = id, actions = {}, t = 0, current_action = ''}, CompositeAction)
end

function CompositeAction:update(dt)
    local current_action_struct = self.actions[1]
    if current_action_struct then
        self.t = self.t + dt
        self.current_action = current_action_struct.type
        current_action_struct.counter = current_action_struct.counter + dt
        if current_action_struct.type == 'after' then 
            run_after(self, current_action_struct)
        elseif current_action_struct.type == 'every' then
            run_every(self, current_action_struct)
        else run_do_for(self, current_action_struct) end
    end
end

function CompositeAction:after(n, action, ...)
    type_check(n, action)
    add(self, Action('after', n, nil, action, 0, ...))
    return self
end

function CompositeAction:every(n, c, action, ...)
    local new_action, params
    if type(c) == 'function' then new_action = c; c = nil; params = {action, ...}
    else new_action = action; params = {...} end
    type_check(n, new_action)

    add(self, Action('every', n, c, new_action, 0, unpack(params))) 
    return self
end

function CompositeAction:do_for(n, action, ...)
    type_check(n, action)
    add(self, Action('do_for', n, nil, action, 0, ...))
    return self
end

setmetatable(CompositeAction, {__call = function(_, ...) return CompositeAction.new(...) end})

Chrono = {}
Chrono.__index = Chrono

function Chrono.new()
    return setmetatable({uid = 0, actions = {}}, Chrono)
end

function Chrono:update(dt)
    for _, c_action in ipairs(self.actions) do 
        c_action:update(dt) 
        if #c_action.actions == 0 then remove(self, c_action.id) end
    end
end

function Chrono:after(n, action, ...)
    type_check(n, action)
    self.uid = self.uid + 1
    local c_action = CompositeAction(self.uid):after(n, action, ...)
    add(self, c_action)
    return c_action 
end

function Chrono:every(n, c, action, ...)
    local new_action, params
    if type(c) == 'function' then new_action = c; c = nil; params = {action, ...}
    else new_action = action; params = {...} end
    type_check(n, new_action)

    self.uid = self.uid + 1
    local c_action = CompositeAction(self.uid):every(n, c, new_action, unpack(params))
    add(self, c_action)
    return c_action 
end

function Chrono:do_for(n, action, ...)
    type_check(n, action)
    self.uid = self.uid + 1
    local c_action = CompositeAction(self.uid):do_for(n, action, ...)
    add(self, c_action)
    return c_action 
end

function Chrono:cancel(id)
    remove(self, id)
end

setmetatable(Chrono, {__call = function() return Chrono.new() end})
