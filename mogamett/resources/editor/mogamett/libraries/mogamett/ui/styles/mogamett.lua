local s = {}

s.gray_light = {36, 39, 42}
s.gray_light_down = {46, 49, 52}
s.gray_light_hover = {66, 69, 72}
s.gray_light_disabled = {96, 99, 102}
s.gray_lighter = {136, 139, 142}
s.gray_dark = {17, 17, 17}
s.gray_darker = {9, 9, 9}
s.white = {238, 238, 238}
s.white_hover = {178, 178, 178}
s.white_disabled = {128, 128, 128}
s.yellow = {238, 208, 119}
s.blue = {80, 128, 222}

-- Textfield:
--
-- States:
--      .hot: when the mouse is hovering over or not
--      .selected: when selected with the keyboard (tab)
--      .enabled: when the checkbox is enabled or not
--
-- Relevant attributes:
--      .x, .y, .w, .h: textfield dimensions
--      .text: textfield text
--
s.textfieldDraw = function(textfield)
    if textfield.enabled then
        if textfield.hot or textfield.selected then
            love.graphics.setColor(unpack(s.gray_light_hover))
            love.graphics.rectangle('fill', textfield.x, textfield.y, textfield.w, textfield.h)
        else
            love.graphics.setColor(unpack(s.gray_light))
            love.graphics.rectangle('fill', textfield.x, textfield.y, textfield.w, textfield.h)
        end

        if textfield.selected then
            love.graphics.setColor(unpack(s.blue))
            love.graphics.rectangle('line', textfield.x, textfield.y, textfield.w, textfield.h)
        end

        if textfield.focused or textfield.selected then
            if textfield.cursor_visible then
                love.graphics.setColor(unpack(s.white))
                love.graphics.line(textfield.x + 5, textfield.y + 5, textfield.x + 5, textfield.y + textfield.h - 5)
            end
        end
    else
        love.graphics.setColor(unpack(s.gray_light_disabled))
        love.graphics.rectangle('fill', textfield.x, textfield.y, textfield.w, textfield.h)
    end

    -- Text
    love.graphics.setColor(unpack(s.white))
    if not textfield.enabled then love.graphics.setColor(unpack(s.white_disabled)) end

    love.graphics.setColor(255, 255, 255)
end

-- Checkbox:
--
-- States:
--      .hot: when the mouse is hovering over or not
--      .selected: when selected with the keyboard (tab)
--      .down: when the checkbox is pressed or not
--      .enabled: when the checkbox is enabled or not
--      .checked: when the checkbox is checked or not
--      
-- Relevant attributes:
--      .x, .y, .w, .h: window dimensions
--      .text: checkbox text
--
s.checkboxDraw = function(checkbox)
    if checkbox.enabled then
        if checkbox.hot or checkbox.selected then
            if checkbox.down then
                love.graphics.setColor(unpack(s.gray_light_down))
                love.graphics.rectangle('fill', checkbox.x + 5, checkbox.y + checkbox.h/4, checkbox.h/2, checkbox.h/2)
            else
                love.graphics.setColor(unpack(s.gray_light_hover))
                love.graphics.rectangle('fill', checkbox.x + 5, checkbox.y + checkbox.h/4, checkbox.h/2, checkbox.h/2)
            end
        else
            love.graphics.setColor(unpack(s.gray_light))
            love.graphics.rectangle('fill', checkbox.x + 5, checkbox.y + checkbox.h/4, checkbox.h/2, checkbox.h/2)
        end

        if checkbox.selected then
            love.graphics.setColor(unpack(s.blue))
            love.graphics.rectangle('line', checkbox.x + 5, checkbox.y + checkbox.h/4, checkbox.h/2, checkbox.h/2)
        end
    else
        love.graphics.setColor(unpack(s.gray_light_disabled))
        love.graphics.rectangle('fill', checkbox.x + 5, checkbox.y + checkbox.h/4, checkbox.h/2, checkbox.h/2)
    end

    -- Checked
    if checkbox.checked then
        love.graphics.setColor(unpack(s.gray_lighter))
        love.graphics.rectangle('fill', checkbox.x + 5 + (checkbox.h/2 - checkbox.h/3)/2, 
                                checkbox.y + checkbox.h/4 + (checkbox.h/2 - checkbox.h/3)/2, checkbox.h/3, checkbox.h/3)
    end

    -- Text
    if checkbox.down then love.graphics.setColor(unpack(s.white_hover))
    else love.graphics.setColor(unpack(s.white)) end
    if not checkbox.enabled then love.graphics.setColor(unpack(s.white_disabled)) end
    checkbox.text:draw(checkbox.x + 10 + checkbox.h/2, checkbox.y + checkbox.h/2 - checkbox.text.font:getHeight()/8)

    love.graphics.setColor(255, 255, 255)
end

-- Frame:
--
-- States: 
--      .hot: when the mouse is hovering over or not
--      .selected: when selected with the keyboard (tab)
--      .down: when the frame is pressed or not
--      .enabled: when the frame is enabled or not
--
-- Relevant attributes:
--      .x, .y, .w, .h: window dimensions
--      .title_bar_height: height of the title bar
--      .title_bar_text: title bar text
--
s.frameDraw = function(frame)
    love.graphics.setColor(unpack(s.gray_dark))
    love.graphics.rectangle('fill', frame.x, frame.y, frame.w, frame.h)

    -- Title bar
    love.graphics.setColor(unpack(s.gray_darker))
    love.graphics.rectangle('fill', frame.x, frame.y, frame.w, frame.title_bar_height)

    -- Text
    love.graphics.setColor(unpack(s.white))
    frame.title_bar_text:draw(frame.x + 5, frame.y + 2 + frame.title_bar_text.font:getHeight()/2)

    if frame.selected then
        love.graphics.setColor(unpack(s.blue))
        love.graphics.rectangle('line', frame.x, frame.y, frame.w, frame.h)
    end

    love.graphics.setColor(255, 255, 255)
end

-- Element:
--
-- States:
--      .hot: when the mouse is hovering over or not
--      .selected: when selected with the keyboard (tab)
--      .down: when the element is being dragged or not
--
-- Relevant Attributes:
--      .x, .y, .w, .h: element dimensions
--
s.elementDraw = function(element)
    love.graphics.setColor(unpack(s.gray_dark))
    love.graphics.rectangle('fill', element.x, element.y, element.w, element.h)

    if element.selected then
        love.graphics.setColor(unpack(s.blue))
        love.graphics.rectangle('line', element.x, element.y, element.w, element.h)
    end

    love.graphics.setColor(255, 255, 255)
end

-- Button:
--
-- States: 
--      .hot: when the mouse is hovering over or not
--      .selected: when selected with the keyboard (tab)
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
        if button.hot or button.selected then
            if button.down then
                love.graphics.setColor(unpack(s.gray_light_down))
                love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
            else
                love.graphics.setColor(unpack(s.gray_light_hover))
                love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
            end
        else
            love.graphics.setColor(unpack(s.gray_light))
            love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
        end

        if button.selected then
            love.graphics.setColor(unpack(s.blue))
            love.graphics.rectangle('line', button.x, button.y, button.w, button.h)
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
