Element = mg.Class:extend('Element')

function Element:new(settings)
    local settings = settings or {}
    for k, v in pairs(settings) do self[k] = v end

end

function Element:update(dt)

end

function Element:draw()

end
