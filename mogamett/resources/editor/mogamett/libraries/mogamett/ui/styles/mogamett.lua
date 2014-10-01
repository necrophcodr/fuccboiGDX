local s = {}

s.gray_light = {36, 39, 42}
s.gray_light_down = {46, 49, 52}
s.gray_light_hover = {66, 69, 72}
s.gray_light_disabled = {96, 99, 102}
s.gray_dark = {17, 17, 17}
s.white = {238, 238, 238}
s.white_hover = {178, 178, 178}
s.white_disabled = {128, 128, 128}
s.yellow = {238, 208, 119}
s.blue = {80, 128, 222}

-- Element:
--
-- States:
--      .hot: when the mouse is hovering over or not
--      .down: when the element is being dragged or not
--
-- Relevant Attributes:
--      .x, .y, .w, .h: element dimensions
s.elementDraw = function(element)
    love.graphics.setColor(unpack(s.gray_dark))
    love.graphics.rectangle('fill', element.x, element.y, element.w, element.h)
end

-- Button:
--
-- States: 
--      .hot: when the mouse is hovering over or not
--      .selected: when selected with the keyboard (Tab)
--      .down: when the button is pressed or not
--      .enabled: when the button is enabled or not
--
-- Relevant attributes:
--      .x, .y, .w, .h: button dimensions
--      .text: button text
--
s.buttonDraw = function(button)
    -- Button
    if button.enabled then
        if button.hot then
            if button.down then
                love.graphics.setColor(unpack(s.gray_light_down))
                love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
            else
                love.graphics.setColor(unpack(s.gray_light))
                love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
                love.graphics.setColor(unpack(s.gray_light_hover))
                love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
            end
        else
            love.graphics.setColor(unpack(s.gray_light))
            love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
        end
    else
        love.graphics.setColor(unpack(s.gray_light_disabled))
        love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
    end

    -- Text
    if button.down then love.graphics.setColor(unpack(s.white_hover))
    else love.graphics.setColor(unpack(s.white)) end
    if not button.enabled then love.graphics.setColor(unpack(s.white_disabled)) end
    button.text:draw(button.x + button.w/2 - button.text.font:getWidth(button.text.text)/2, 
                     button.y + button.h/2 - button.text.font:getHeight()/8)

    love.graphics.setColor(255, 255, 255)
end

return s
