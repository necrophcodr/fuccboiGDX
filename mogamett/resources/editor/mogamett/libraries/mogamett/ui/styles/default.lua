local s = {}

s.gray_light = {36, 39, 42}
s.gray_light_hover = {66, 69, 72}
s.gray_dark = {17, 17, 17}
s.white = {238, 238, 238}
s.white_hover = {178, 178, 178}
s.yellow = {238, 208, 119}
s.blue = {80, 128, 222}

-- Button -- 
--
-- States: 
--      .hot: when selected with the keyboard or when mouse the mouse is hovering over
--      .down: when the button is pressed or not
--      .enabled: when the button is enabled or not
--
-- Relevant attributes:
--      .x, .y, .w, .h: button dimensions
--      .text: button text
--
s.buttonDraw = function(button)
    if button.enabled then
        if button.hot then
            if button.down then
                love.graphics.setColor(unpack(s.gray_dark))
                love.graphics.rectangle('fill', button.x, button.y + button.h/10, button.w, button.h)
            else
                love.graphics.setColor(unpack(s.gray_light))
                love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
                love.graphics.setColor(unpack(s.gray_light_hover))
                love.graphics.rectangle('fill', button.x, button.y, button.w, button.h - button.h/10)
            end
        else
            love.graphics.setColor(unpack(s.gray_light))
            love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
        end


        -- Text
        local y_offset = 0
        if button.down then 
            y_offset = button.h/10
            love.graphics.setColor(unpack(s.white_hover))
        else love.graphics.setColor(unpack(s.white)) end
        button.text:draw(button.x + button.w/2 - button.text.font:getWidth(button.text.text)/2, button.y + button.h/2 - button.text.font:getHeight()/8 + y_offset)

        love.graphics.setColor(255, 255, 255)
    else

    end
end

return s
