local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Query = Class:extend()

function Query:queryNew()

end

function Query:getEntitiesBy(key, value, object_types)
    local entities = {} 
    for _, type in ipairs(object_types) do
        for _, group in ipairs(self.groups) do
            if group.name == type then
                for _, object in ipairs(group:getEntities()) do
                    if object[key] == value then
                        table.insert(entities, object)
                    end
                end
            end
        end
    end
    return entities
end

function Query:queryClosestAreaCircle(ids, x, y, radius, object_types)
    local out_object = nil
    local min_distance = 100000
    for _, type in ipairs(object_types) do
        for _, group in ipairs(self.groups) do
            if group.name == type then
                for _, object in ipairs(group:getEntities()) do
                    if not self.fg.fn.contains(ids, object.id) then
                        local _x, _y = object.body:getPosition()
                        local dx, dy = math.abs(x - _x), math.abs(y - _y)
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

function Query:queryAreaLine(x1, y1, x2, y2, object_types)
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
                        if self.fg.mlib.Polygon.LineIntersects(x1, y1, x2, y2, unpack(object_points)) then
                            table.insert(objects, object)
                        end
                    elseif object.shape_name == 'circle' then
                        local x, y = object.body:getPosition()
                        if self.fg.mlib.Circle.IsSegmentSecant(x, y, object.r, x1, y2, x2, y2) then
                            table.insert(objects, object)
                        end
                    end
                end
            end
        end
    end
    return objects
end

function Query:queryAreaPolygon(polygon_points, object_types)
    local objects = {}
    for _, type in ipairs(object_types) do
        for _, group in ipairs(self.groups) do
            if group.name == type then
                for _, object in ipairs(group:getEntities()) do
                    if object.shape_name == 'chain' or object.shape_name == 'bsgrectangle' or
                       object.shape_name == 'rectangle' or object.shape_name == 'polygon' then
                        local object_points = {object.body:getWorldPoints(object.shape:getPoints())}
                        if self.fg.mlib.Polygon.PolygonIntersects(polygon_points, object_points) then
                            table.insert(objects, object)
                        end
                    elseif object.shape_name == 'circle' then
                        if self.fg.mlib.Polygon.CircleIntersects(x, y, object.r, unpack(polygon_points)) then
                            table.insert(objects, object)
                        end
                    end
                end
            end
        end
    end
    return objects
end

function Query:applyAreaLine(x1, y1, x2, y2, object_types, action)
    local objects = self:queryLine(x1, y1, x2, y2, object_types)
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

function Query:applyAreaRectangle(x, y, w, h, object_types, action)
    local objects = self:queryAreaRectangle(x, y, w, h, object_types)
    if #objects > 0 then
        for _, object in ipairs(objects) do
            action(object)
        end
    end
end
    
return Query
