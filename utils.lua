-- Visual

function pushRotate(x, y, angle)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    love.graphics.translate(-x, -y)
end

function pushRotateScale(x, y, angle, scale_x, scale_y)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    love.graphics.scale(scale_x or 1, scale_y or scale_x or 1)
    love.graphics.translate(-x, -y)
end

-- Logic

function equalsAny(v, values)
    for _, value in ipairs(values) do
        if value == v then return true end
    end
    return false
end

function equalsAll(v, values)
    for _, value in ipairs(values) do
        if value ~= v then return false end
    end
    return true
end

-- Tables
--
function tableToString(table)
    local str = "{"
    for k, v in pairs(table) do
        if type(k) ~= "number" then str = str .. k .. " = " end
        if type(v) == "number" or type(v) == "boolean" then str = str .. tostring(v) .. ", "
        elseif type(v) == "string" then str = str .. "'" .. v .. "'" .. ", "
        elseif type(v) == "table" then str = str .. tableToString(v) .. ", " end
    end
    if #table > 0 then str = string.sub(str, 1, -3) end
    str = str .. "}"
    return str
end

function tableStringToTable(string)
    
end

function table.prandomBetween(t)
    return math.prandom(t[1], t[2])   
end

function table.random(t)
    if type(t) == 'table' then return t[math.random(1, #t)]
    else return t end
end

function table.contains(t, value)
    for i, v in ipairs(t) do
        if v == value then return true end
    end
    return false
end

function table.containsByKey(t, key, value)
    for i, v in ipairs(t) do
        if v[key] == value then return true end
    end
    return false
end

function table.removeByValue(t, value)
    for i, v in ipairs(t) do
        if v == value then 
            table.remove(t, i) 
        end
    end
end

function table.copy(t)
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

-- findIndexByID({{id = 1, data = ...}, {id = 9, data = ...}, {id = 5, data = ...}}, 9) -> 2
-- findIndexByID({{id = 2, ...}, {id = 22, ...}, {id = 324, ...}, {id = 3, ...}}, 324) -> 3
function findIndexByID(t, id)
    for i, object in ipairs(t) do
        if object.id == id then 
            return i 
        end
    end
end

-- Math

function math.between(value, min, max)
    if value >= min and value <= max then return true
    else return false end
end

function math.bounds(value, min, max)
    return math.min(math.max(value, min), max)
end

-- Random with 3 digit precision
function math.prandom(min, max)
    return math.random(min*1000, max*1000)/1000
end

-- Random with 3 digit precision inside a circle of radius = radius and center = (x, y)
function math.prandomCircle(radius, x, y)
    return x + math.prandom(-radius, radius), y + math.prandom(-radius, radius)   
end

-- math.round(1.234, 2) -> 1.23
-- math.round(1.236, 2) -> 1.24
function math.round(n, p)
    local m = math.pow(10, p or 0)
    return math.floor(n*m+0.5)/m
end

-- Degrees to radians.
function degToRad(d)
    return d*math.pi/180
end

function queryLineFindMin(objects)
    local min = Vector(100000, 100000)
    for _, object in ipairs(objects) do
        if object.x and object.y then
            if Vector(object.x, object.y):len() < min:len() then
                min = Vector(object.x, object.y)
            end
        end
    end
    return min
end

-- chooseWithProb({'a', 'b', 'c'}, {0.5, 0.25, 0.25}) -> will choose 'a' with 0.5 prob, 
-- 'b' with 0.25 and 'c' with 0.25. Both tables should have the same amount of values and
-- the chances table should add up to 1. This is NOT checked at all, so wrong usage will
-- produce bugs.
function chooseWithProb(choices, chances)
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

-- Directional tiles (such as resources/tiles/directional_8.png) come in a particular order:
-- down, down right, left, left up, up, up right, right, right down
-- The getTileDataFromSheet function in data/visual.lua separates each of those tiles
-- in a normal array. Directional tile data will usually need to be accessed in terms 
-- of directions and not indexes, though. This function simply returns another version 
-- of the tile_data array with directions as keys.
function directionalTileDataToDirections(tile_data)
    local directional_tile_data = {}
    local directions = {'down', 'down right', 'left', 'left up', 
                        'up', 'up right', 'right', 'right down'}
    for i, image in ipairs(tile_data) do
        directional_tile_data[directions[i]] = image
    end
    return directional_tile_data
end

-- LÖVE uses a CLOCKWISE angle system, so math.pi/2 points south.
-- Each direction consists of 45 degrees or math.pi/4 rad around the main angle,
-- which means 22.5 degrees or math.pi/8 rad to both sides.
--
-- angleToDirection(math.pi/2) -> 'down'
-- angleToDirection(-math.pi/4) -> 'up right'
-- angleToDirection(math.pi) -> 'left'
-- angleToDirection(-math.pi/2 + math.pi/16) -> 'up'
-- angleToDirection(-math.pi/2 + math.pi/8 + math.pi/360) -> 'up right'
function angleToDirection(angle)
    local pi = math.pi
    if angle >= pi/4 then angle = -2*pi+angle end

    if angle <     pi/4 and angle >=  -1*pi/4 then return 'right' end
    if angle <  -1*pi/4 and angle >=  -3*pi/4 then return 'up' end
    if angle <  -3*pi/4 and angle >=  -5*pi/4 then return 'left' end
    if angle <  -5*pi/4 and angle >=  -7*pi/4 then return 'down' end
end

function directionToAngle(direction)
    if direction == 'right' then return 0 end
    if direction == 'up' then return -math.pi/2 end
    if direction == 'left' then return math.pi end
    if direction == 'down' then return math.pi/2 end
end

-- Global state

-- Called whenenver an Entity is created so that every entity has a Unique IDentifier.
function getUID()
    uid = uid + 1
    return uid
end
