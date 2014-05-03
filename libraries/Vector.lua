-- https://github.com/vrld/hump/blob/master/vector.lua
-- http://nova-fusion.com/2011/06/30/lua-metatables-tutorial/

local assert = assert
local sqrt, cos, sin, atan = math.sqrt, math.cos, math.sin, math.atan2

Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector)
end

local function isVector(v)
    return getmetatable(v) == Vector
end

function Vector:clone()
    return Vector.new(self.x, self.y)
end

function Vector:unpack()
    return self.x, self.y
end

function Vector:__tostring()
    return "(" .. tonumber(self.x) .. "," .. tonumber(self.y) .. ")"
end

function Vector.__add(a, b)
    if type(a) == "number" then return Vector.new(a + b.x, a + b.y)
    elseif type(b) == "number" then return Vector.new(a.x + b, a.y + b)
    else
        assert(isVector(a) and isVector(b), 
        "add: wrong argument types (<Vector> or <number> expected)")
        return Vector.new(a.x + b.x, a.y + b.y)
    end
end

function Vector.__sub(a, b)
    assert(isVector(a) and isVector(b), 
    "sub: wrong argument types (<Vector> expected)")
    return Vector.new(a.x - b.x, a.y - b.y)
end

function Vector.__mul(a, b)
    if type(a) == "number" then return Vector.new(a*b.x, a*b.y)
    elseif type(b) == "number" then return Vector.new(a.x*b, a.y*b)
    else
        assert(isVector(a) and isVector(b), 
        "mul: wrong argument types (<Vector> or <number> expected)")
        return Vector.new(a.x*b.x, a.y*b.y)
    end
end

function Vector.__div(a, b)
    assert(isVector(a) and type(b) == "number",
    "div: wrong argument types (expected <Vector> / <number>)")
    return Vector.new(a.x/b, a.y/b)
end

function Vector.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vector:len()
    return sqrt(self.x*self.x + self.y*self.y)
end

function Vector:len2()
    return self.x*self.x + self.y*self.y
end

function Vector.distance(a, b)
    assert(isVector(a) and isVector(b), 
    "dist: wrong argument types (<Vector> expected)")
    return (a - b):len()
end

function Vector.cross(a, b)
    assert(isVector(a) and isVector(b), 
    "cross: wrong argument types (<Vector> expected)")
    return (a.x*b.y) - (a.y*b.x) 
end

function Vector:normalize()
    local l = self:len()
    if l > 0 then self.x, self.y = self.x/l, self.y/l end
    return self
end

function Vector:normalized()
    return self:clone():normalize()
end

function Vector:perpendicular()
    return Vector.new(-self.y, self.x):normalize()
end

function Vector.dot(a, b)
    return a.x*b.x + a.y*b.y
end

function Vector:rotate(phi)
    local c, s = math.cos(phi), math.sin(phi)
    self.x, self.y = c*self.x - s*self.y, s*self.x + c*self.y
    return self
end

function Vector:rotated(phi)
    return self:clone():rotate(phi)
end

function Vector:min(max_length)
    assert(type(max_length) == "number", "min: wrong argument type (<number> expected)")
    local s = max_length/self:len()
    if s >= 1 then s = 1 end
    return Vector.new(self.x*s, self.y*s)
end

function Vector:angle() 
    return atan(self.y, self.x)
end

setmetatable(Vector, {__call = function(_, ...) return Vector.new(...) end})
