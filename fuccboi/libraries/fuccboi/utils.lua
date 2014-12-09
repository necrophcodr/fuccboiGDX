local utils = {}

-- Graphics
utils.graphics = {}

utils.graphics.pushRotate = function(x, y, angle)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle or 0)
    love.graphics.translate(-x, -y)
end

utils.graphics.pushRotateScale = function(x, y, angle, scale_x, scale_y)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle or 0)
    love.graphics.scale(scale_x or 1, scale_y or scale_x or 1)
    love.graphics.translate(-x, -y)
end

utils.graphics.roundedRectangle = function(mode, x, y, width, height, xround, yround)
    local points = {}
    local precision = (xround + yround) * .1
    local tI, hP = table.insert, .5*math.pi
    if xround > width*.5 then xround = width*.5 end
    if yround > height*.5 then yround = height*.5 end
    local X1, Y1, X2, Y2 = x + xround, y + yround, x + width - xround, y + height - yround
    local sin, cos = math.sin, math.cos
    for i = 0, precision do
        local a = (i/precision-1)*hP
        tI(points, X2 + xround*cos(a))
        tI(points, Y1 + yround*sin(a))
    end
    for i = 0, precision do
        local a = (i/precision)*hP
        tI(points, X2 + xround*cos(a))
        tI(points, Y2 + yround*sin(a))
    end
    for i = 0, precision do
        local a = (i/precision+1)*hP
        tI(points, X1 + xround*cos(a))
        tI(points, Y2 + yround*sin(a))
    end
    for i = 0, precision do
        local a = (i/precision+2)*hP
        tI(points, X1 + xround*cos(a))
        tI(points, Y1 + yround*sin(a))
    end
    love.graphics.polygon(mode, points)
end

-- Table
utils.table = {}

utils.table.toString = function(t)
    local str = "{"
    for k, v in pairs(t) do
        if type(k) ~= "number" then str = str .. k .. " = " end
        if type(v) == "number" or type(v) == "boolean" then str = str .. tostring(v) .. ", "
        elseif type(v) == "string" then str = str .. "'" .. v .. "'" .. ", "
        elseif type(v) == "table" then str = str .. utils.table.toString(v) .. ", " end
    end
    if #table > 0 then str = string.sub(str, 1, -3) end
    str = str .. "}"
    return str
end

utils.table.random = function(t)
    return t[math.random(1, #t)]
end

utils.table.copy = function(t)
    local copy
    if type(t) == 'table' then
        copy = {}
        for k, v in next, t, nil do
            copy[utils.table.copy(k)] = utils.table.copy(v)
        end
        setmetatable(copy, utils.table.copy(getmetatable(t)))
    else copy = t end
    return copy
end

-- Math
utils.math = {}

utils.math.isBetween = function(v, min, max)
    return v >= min and v <= max
end

utils.math.clamp = function(v, min, max)
    return v < min and min or (v > max and max or v)
end

utils.math.random = function(min, max)
    return (min > max and (math.random()*(min - max) + max)) or (math.random()*(max - min) + min)
end

utils.math.round = function(n, p)
    local m = math.pow(10, p or 0)
    return math.floor(n*m+0.5)/m
end

utils.math.chooseWithProbability = function(choices, chances)
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

-- Converts old_value that is between old_min and old_max to a new_value that is contained
-- within new_min and new_max while maintaining their ratio.
-- Ex.: print(convertRange(2, 1, 3, 0, 1)) --> 0.5
-- new_min and new_max defaults to 0 and 1 if omitted
utils.math.convertRange = function(old_value, old_min, old_max, new_min, new_max)
    local new_min = new_min or 0
    local new_max = new_max or 1
    local new_value = 0
    local old_range = old_max - old_min
    if old_range == 0 then new_value = new_min 
    else
        local new_range = new_max - new_min
        new_value = (((old_value - old_min)*new_range)/old_range) + new_min
    end
    return new_value
end

-- Miscellaneous
utils.angleToDirection2 = function(angle)
    angle = math.abs(angle)
    if angle < math.pi/2 and angle >= 3*math.pi/2 then return 'right' end
    if angle >= math.pi/2 and angle < 3*math.pi/2 then return 'left' end
end

utils.angleToDirection4 = function(angle)
    local pi = math.pi
    if angle >= pi/4 then angle = -2*pi+angle end
    if angle <     pi/4 and angle >=  -1*pi/4 then return 'right' end
    if angle <  -1*pi/4 and angle >=  -3*pi/4 then return 'up' end
    if angle <  -3*pi/4 and angle >=  -5*pi/4 then return 'left' end
    if angle <  -5*pi/4 and angle >=  -7*pi/4 then return 'down' end
end

utils.directionToAngle4 = function(direction)
    if direction == 'right' then return 0 end
    if direction == 'up' then return -math.pi/2 end
    if direction == 'left' then return math.pi end
    if direction == 'down' then return math.pi/2 end
end

return utils
