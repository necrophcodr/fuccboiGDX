return {
    mouseColliding = function(x, y, w, h)
        local mx, my = love.mouse.getPosition()
        if mx >= x and mx <= x + w and my >= y and my <= y + h then return true end
    end,
}
