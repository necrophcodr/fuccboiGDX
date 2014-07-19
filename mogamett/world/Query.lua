local test2DLineLine = function(x1, y1, x2, y2, x3, y3, x4, y4)
    local denom = ((y4 - y3) * (x2 - x1)) - ((x4 - x3) * (y2 - y1))
    if denom == 0 then return nil, nil 
    else
        local ua = (((x4 - x3) * (y1 - y3)) - ((y4 - y3) * (x1 - x3)))/denom  
        local ub = (((x2 - x1) * (y1 - y3)) - ((y2 - y1) * (x1 - x3)))/denom
        if (ua < 0) or (ua > 1) or (ub < 0) or (ub > 1) then return nil, nil end
        return x1 + ua*(x2 - x1), y1 + ua*(y2 - y1)
    end
end

local test2DLineCircle = function(x1, y1, x2, y2, cx, cy, r)
    local p1x, p1y = x1 - cx, y1 - cy
    local p2x, p2y = x2 - cx, y2 - cx
    local pmx, pmy = x2 - x1, y2 - y1
    local a = pmx*pmx + pmy+pmy
    local b = 2*((pmx*p1x) + (pmy*p1y))
    local c = (p1x*p1x) + (p1y*p1y) - (r*r)
    delta = b*b - (4*a*c)
    if delta < 0 then return nil, nil, nil, nil
    elseif delta == 0 then
        local u = -b/(2*a)
        return x1 + (u*pmx), y1 + (u*pmy), x1 + (u*pmx), y1 + (u*pmy)
    elseif delta > 0 then
        local sqrtd = math.sqrt(delta)
        local u1 = (-b + sqrtd)/(2*a)
        local u2 = (-b - sqrtd)/(2*a)
        return x1 + (u1*pmx), y1 + (u1*pmy), x1 + (u2*pmx), y1 + (u2*pmy)
    end
end

local testPointInPolygon = function(point_x, point_y, polygon_points)
    local c = false
    local nvert = #polygon_points/2

    local i, j, c = 1, nvert, false

    while i <= nvert do
        if (((polygon_points[i+1] > point_y) ~= (polygon_points[j+1] > point_y)) and
           (point_x < (polygon_points[j] - polygon_points[i])*(point_y - polygon_points[i+1])/(polygon_points[j+1] - polygon_points[i+1]) + polygon_points[i])) then
           c = not c
        end
        j = i
        i = i + 1
    end

    return c
end

local Class = require (mogamett_path .. '/libraries/classic/classic')
local Query = Class:extend()

function Query:queryNew()

end

function Query:queryId(id, type)
    for _, group in ipairs(self.groups) do
        if group.name == type then
            for _, object in ipairs(group:getEntities()) do
                if object.id == id then
                    return object
                end
            end
        end
    end
end

function Query:queryClosestAreaCircle(ids, position, radius, object_types)
    local out_object = nil
    local min_distance = 100000
    for _, type in ipairs(object_types) do
        for _, group in ipairs(self.groups) do
            if group.name == type then
                for _, object in ipairs(group:getEntities()) do
                    if not table.contains(ids, object.id) then
                        local x, y = object.body:getPosition()
                        local dx, dy = math.abs(position.x - x), math.abs(position.y - y)
                        local distance = math.sqrt(dx*dx + dy*dy)
                        if distance < min_distance and distance < radius then 
                            min_distance = distance 
                            out_object = object
                        end
                    end
                end
            end
        end
    end
    return out_object
end

function Query:queryAreaCircle(x, y, radius, object_types)
    local objects = {}
    for _, type in ipairs(object_types) do
        for _, group in ipairs(self.groups) do
            if group.name == type then
                for _, object in ipairs(group:getEntities()) do
                    local _x, _y = object.x, object.y
                    local dx, dy = math.abs(x - _x), math.abs(y - _y)
                    local distance = math.sqrt(dx*dx + dy*dy)
                    if distance < radius then 
                        table.insert(objects, object)
                    end
                end
            end
        end
    end
    return objects
end

function Query:queryAreaRectangle(x, y, w, h, object_types)
    local objects = {}
    for _, type in ipairs(object_types) do
        for _, group in ipairs(self.groups) do
            if group.name == type then
                for _, object in ipairs(group:getEntities()) do
                    local _x, _y = object.x, object.y
                    local dx, dy = math.abs(x - _x), math.abs(y - _y)
                    if dx <= object.w/2 + w/2 and dy <= object.h/2 + h/2 then
                        table.insert(objects, object)
                    end
                end
            end
        end
    end
    return objects
end

-- NOT WORKING FIX LTERRR
function Query:queryPolygon(polygon_points, object_types)
    local objects = {}
    for _, type in ipairs(object_types) do
        for _, group in ipairs(self.groups) do
            if group.name == type then
                for _, object in ipairs(group:getEntities()) do
                    if object.shape_name == 'chain' or object.shape_name == 'bsgrectangle' or
                       object.shape_name == 'rectangle' or object.shape_name == 'polygon' then
                        -- Get object points
                        local object_points = {object.body:getWorldPoints(object.shape:getPoints())}
                        local colliding = false
                        for i = 1, #object_points, 2 do
                            colliding = colliding or testPointInPolygon(object_points[i], object_points[i+1], polygon_points)
                        end
                        -- Add segment tests later
                        if colliding then table.insert(objects, object) end
                    end
                end
            end
        end
    end
    return objects
end

function Query:applyAreaLine(x1, y1, x2, y2, object_types, action)
    local objects = self:queryAreaLine(x1, y1, x2, y2, object_types)
    if #objects > 0 then
        for _, object in ipairs(objects) do
            action(object)
        end
    end
end

function Query:queryLine(x1, y1, x2, y2, object_types)
    local objects = {}
    for _, type in ipairs(object_types) do
        for _, group in ipairs(self.groups) do
            if group.name == type then
                for _, object in ipairs(group:getEntities()) do
                    if object.shape_name == 'chain' or object.shape_name == 'bsgrectangle' or 
                       object.shape_name == 'rectangle' or object.shape_name == 'polygon' then
                        -- Get object lines
                        local object_lines = {}
                        local object_points = {object.body:getWorldPoints(object.shape:getPoints())}
                        for i = 1, #object_points, 2 do
                            if i < #object_points-1 then
                                table.insert(object_lines, {x1 = object_points[i], y1 = object_points[i+1], 
                                                            x2 = object_points[i+2], y2 = object_points[i+3]})
                            end
                            if i == #object_points-1 then
                                table.insert(object_lines, {x1 = object_points[i], y1 = object_points[i+1], 
                                                            x2 = object_points[1], y2 = object_points[2]})
                            end
                        end

                        -- Insersect input line with each object shape line, if intersects with any of them 
                        -- then input line is intersecting with object
                        local colliding = false
                        local x, y = nil, nil
                        for _, line in ipairs(object_lines) do
                            x, y = test2DLineLine(x1, y1, x2, y2, line.x1, line.y1, line.x2, line.y2)
                            if x and y then table.insert(objects, {x = x, y = y, object = object}) end
                        end
                    elseif object.shape_name == 'circle' then
                        local x, y = object.body:getPosition()
                        local ox1, oy1, ox2, oy2 = test2DLineCircle(x1, y1, x2, y2, x, y, object.r)
                        if ox1 and oy1 and ox2 and oy2 then
                            table.insert(objects, {x1 = ox1, y1 = oy1, x2 = ox2, y2 = oy2, object = object})
                        end
                    end
                end
            end
        end
    end
    return objects
end

function Query:applyAreaRectangle(x, y, w, h, object_types, action)
    local objects = self:queryAreaRectangle(x, y, w, h, object_types)
    if #objects > 0 then
        for _, object in ipairs(objects) do
            action(object)
        end
    end
end
    
function Query:applyAreaCircle(x, y, r, object_types, action)
    local objects = self:queryAreaCircle(x, y, r, object_types)
    if #objects > 0 then
        for _, object in ipairs(objects) do
            action(object)
        end
    end
end

function Query:applyAreaPolygon(polygon_points, object_types, action)
    local objects = self:queryPolygon(polygon_points, object_types)
    if #objects > 0 then
        for _, object in ipairs(objects) do
            action(object)
        end
    end
end

return Query
