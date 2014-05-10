mogamett_path = string.sub(..., 1, -10)

local mm = {}

-- hump
mm.Timer = require (mogamett_path .. '/libraries/hump/timer')
mm.Camera = require (mogamett_path .. '/libraries/hump/camera')
mm.Vector = require (mogamett_path .. '/libraries/hump/vector')

-- AnAL
mm.Animation = require (mogamett_path .. '/libraries/anal/AnAL')

-- struct
mm.Struct = require (mogamett_path .. '/libraries/struct/struct')

-- middleclass 
mm._class = require (mogamett_path .. '/libraries/middleclass/middleclass')
-- holds all classes created with the mm.class call
mm.classes = {}
mm.class = function(class_name, ...)
    mm.classes[class_name] = mm._class(class_name, ...)
    return mm.classes[class_name]
end

-- lovebird
mm.lovebird = require (mogamett_path .. '/libraries/lovebird/lovebird')

-- input
mm.Input = require (mogamett_path .. '/libraries/mogamett/input')
mm.input = mm.Input()
mm.keypressed = function(key) mm.input:keypressed(key) end
mm.keyreleased = function(key) mm.input:keyreleased(key) end
mm.mousepressed = function(button) mm.input:mousepressed(button) end
mm.mousereleased = function(button) mm.input:mousereleased(button) end

-- collision, holds global collision data (mostly who should ignore who and callback settings)
mm.Collision = require (mogamett_path .. '/libraries/mogamett/collision')(mm)

-- utils
mm.utils = {}
-- graphics
mm.utils.graphics = {}
mm.utils.graphics.pushRotate = function(x, y, angle)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle or 0)
    love.graphics.translate(-x, -y)
end
mm.utils.graphics.pushRotateScale = function(x, y, angle, scale_x, scale_y)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle or 0)
    love.graphics.scale(scale_x or 1, scale_y or scale_x or 1)
    love.graphics.translate(-x, -y)
end
-- logic
mm.utils.logic = {}
mm.utils.logic.equalsAny = function(v, values)
    for _, value in ipairs(values) do
        if value == v then return true end
    end
    return false
end
mm.utils.logic.equalsAll = function(v, values)
    for _, value in ipairs(values) do
        if value ~= v then return false end
    end
    return true
end
-- table
mm.utils.table = {}
mm.utils.table.toString = function(t)
    local str = "{"
    for k, v in pairs(t) do
        if type(k) ~= "number" then str = str .. k .. " = " end
        if type(v) == "number" or type(v) == "boolean" then str = str .. tostring(v) .. ", "
        elseif type(v) == "string" then str = str .. "'" .. v .. "'" .. ", "
        elseif type(v) == "table" then str = str .. mm.utils.table.toString(v) .. ", " end
    end
    if #table > 0 then str = string.sub(str, 1, -3) end
    str = str .. "}"
    return str
end
mm.utils.table.random = function(t)
    return t[math.random(1, #t)]
end
mm.utils.table.contains = function(t, value)
    for k, v in pairs(t) do
        if v == value then return true end
    end
    return false
end
mm.utils.table.copy = function(t)
    local copy
    if type(t) == 'table' then
        copy = {}
        for k, v in next, t, nil do
            copy[table.copy(k)] = table.copy(v)
        end
        setmetatable(copy, table.copy(getmetatable(t)))
    else copy = t end
    return copy
end
-- math
mm.utils.math = {}
mm.utils.math.isBetween = function(v, min, max)
    return v >= min and v <= max
end
mm.utils.math.clamp = function(v, min, max)
    return v < min and min or (v > max and max or v)
end
mm.utils.math.random = function(min, max)
    return math.random()*max+min
end
mm.utils.math.round = function(n, p)
    local m = math.power(10, p or 0)
    return math.floor(n*m+0.5)/m
end
-- misc
mm.utils.chooseWithProbability = function(choices, chances)
    local r = math.random(1, 1000)
    local intervals = {}
    -- Creates a table with appropriate intervals: 
    -- chances = {0.5, 0.25, 0.25} -> intervals = {500, 750, 1000}
    for i = 1, #chances do 
        if i > 1 then table.insert(intervals, intervals[i-1]+chances[i]*1000) 
        else table.insert(intervals, chances[i]*1000) end
    end
    -- Figures out which one of the intervals was chosen based on 
    -- the intervals table and the value r.
    -- r = 250, intervals = {500, 750, 1000} should return 1, since r <= intervals[1]
    -- r = 800, intervals = {500, 750, 1000} should return 3, since r >= intervals[2] 
    -- and r <= intervals[3]
    for i = 1, #intervals do
        if i > 1 then 
            if r >= intervals[i-1] and r <= intervals[i] then return choices[i] end
        else
            if r <= intervals[i] then return choices[i] end
        end
    end
end
mm.utils.angleToDirection4 = function(angle)
    local pi = math.pi
    if angle >= pi/4 then angle = -2*pi+angle end
    if angle <     pi/4 and angle >=  -1*pi/4 then return 'right' end
    if angle <  -1*pi/4 and angle >=  -3*pi/4 then return 'up' end
    if angle <  -3*pi/4 and angle >=  -5*pi/4 then return 'left' end
    if angle <  -5*pi/4 and angle >=  -7*pi/4 then return 'down' end
end
mm.utils.directionToAngle4 = function(direction)
    if direction == 'right' then return 0 end
    if direction == 'up' then return -math.pi/2 end
    if direction == 'left' then return math.pi end
    if direction == 'down' then return math.pi/2 end
end
mm.utils.findIndexById = function(t, id)
    for i, object in ipairs(t) do
        if object.id == id then 
            return i 
        end
    end
end

-- global
mm.getUID = function()
    mm.uid = mm.uid + 1
    return mm.uid
end

mm.uid = 0
mm.path = nil
mm.zoom = 1
mm.debug_draw = true
mm.lovebird_enabled = false
mm.screen_width = love.window.getWidth()
mm.screen_height = love.window.getHeight()

-- init
mm.init = function()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    mm.world = mm.World(mm)
    mm.Collision:generateCategoriesMasks()
end

-- world
mm.World = require (mogamett_path .. '/world/World')

-- entity
mm.Entity = require (mogamett_path .. '/entities/Entity')

-- mixin
mm.PhysicsBody = require (mogamett_path .. '/mixins/PhysicsBody')

mm.update = function(dt)
    if mm.lovebird_enabled then mm.lovebird.update() end
    mm.input:update(dt)
    mm.world:update(dt)
end

mm.draw = function()
    mm.world:draw()
end

return mm
