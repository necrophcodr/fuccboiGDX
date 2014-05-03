Entity = class('Entity')

function Entity:init(world, x, y, settings)
    if settings then
        if settings.name then self.id = tonumber(settings.name)
        else self.id = getUID() end
    else self.id = getUID() end
    self.dead = false
    self.world = world
    self.x = x
    self.y = y
    self.probability_conditionals = {}
    self.cond_lines = {}
    self.spawn_probability = 0
    self.selected = false
    if settings then
        if not settings.name then self.name = tostring(self.id) end
        for k, v in pairs(settings) do self[k] = v end
    end
end

function Entity:addConditionalEntity(entity_name, condition_type, jump_add)
    if not jump_add then
        table.insert(self.probability_conditionals, {entity_name = entity_name, type = condition_type})
    end
    local entity = self.world:getEntityByName(entity_name)
    if entity then
        local points = {}
        for i = 1, 10 do
             table.insert(points, {x = self.x + 0.1*(i-1)*(entity.x - self.x), y = self.y + 0.1*(i-1)*(entity.y - self.y), 
                                   add_u = 0, alpha = 0, alpha_tweening = false}) 
        end
        local color = {}
        if condition_type == 'live->live' then color = {128, 222, 160}
        elseif condition_type == 'live->dead' then color = {222, 222, 160}
        elseif condition_type == 'dead->live' then color = {128, 160, 222}
        elseif condition_type == 'dead->dead' then color = {222, 160, 128} end

        table.insert(self.cond_lines, {x1 = self.x, y1 = self.y, x2 = entity.x, y2 = entity.y, points = points, other = entity,
                                      type = condition_type, text = Text((self.x+entity.x)/2, (self.y+entity.y)/2 - 10, 
                                      condition_type, color)}) 
        for _, point in ipairs(self.cond_lines[#self.cond_lines].points) do
            point.alpha_tweening = true
            timer:tween(0.25, point, {alpha = 255}, 'in-out-cubic')
            timer:after(0.25, function() point.alpha_tweening = false end)
        end
    end
end

function Entity:conditionalLineUpdate(dt)
    if not editor.play_mode then
        for i = #self.probability_conditionals, 1, -1 do
            local e = self.world:getEntityByName(self.probability_conditionals[i].entity_name)
            if not e then 
                table.remove(self.probability_conditionals, i)
                table.remove(self.cond_lines, i)
            end
        end
    end

    for _, cond_line in ipairs(self.cond_lines) do
        cond_line.x1 = self.x
        cond_line.x2 = cond_line.other.x
        cond_line.y1 = self.y
        cond_line.y2 = cond_line.other.y
        for i, point in ipairs(cond_line.points) do
            point.add_u = point.add_u + 0.1*dt
            point.x = self.x + ((0.1)*(i-1) + point.add_u)*(cond_line.other.x - self.x)
            point.y = self.y + ((0.1)*(i-1) + point.add_u)*(cond_line.other.y - self.y)
        end
        for i = #cond_line.points, 1, -1 do
            if ((0.1)*(i-1) + cond_line.points[i].add_u) > 0.9375 then
                if not cond_line.points[i].alpha_tweening then 
                    cond_line.points[i].alpha_tweening = true
                    timer:tween(0.5, cond_line.points[i], {alpha = 0}, 'in-out-cubic')
                    timer:after(0.5, function() 
                        table.remove(cond_line.points, i) 
                        table.insert(cond_line.points, 1, {x = self.x, y = self.y, add_u = 0.0875, alpha_tweening = false, alpha = 0})     
                        timer:tween(0.5, cond_line.points[1], {alpha = 255}, 'in-out-cubic')
                        for _, point in ipairs(cond_line.points) do
                            point.add_u = point.add_u - 0.1
                        end
                    end)
                end
            end
        end
    end
end

function Entity:conditionalLineDraw()
    local color1, color2 = {}, {}
    for _, cond_line in ipairs(self.cond_lines) do
        if cond_line.type == 'live->live' then
            color1 = {96, 170, 128}
            color2 = {128, 222, 160}
        elseif cond_line.type == 'live->dead' then
            color1 = {170, 170, 96}
            color2 = {222, 222, 160}
        elseif cond_line.type == 'dead->live' then
            color1 = {96, 128, 170}
            color2 = {128, 160, 222}
        elseif cond_line.type == 'dead->dead' then
            color1 = {170, 128, 96}
            color2 = {222, 160, 128}
        end
        for i, point in ipairs(cond_line.points) do
            pushRotateScale(point.x, point.y, Vector(cond_line.x2 - cond_line.x1, cond_line.y2 - cond_line.y1):angle())
            love.graphics.setColor(color1[1], color1[2], color1[3], point.alpha/1.5)
            local r1x, r1y = math.prandom(5.5, 6.5), math.prandom(1.5, 2.5)
            love.graphics.rectangle('fill', point.x - r1x, point.y - r1y, 2*r1x, 2*r1y)
            love.graphics.setColor(color2[1], color2[2], color2[3], point.alpha)
            local r2x, r2y = math.prandom(3.5, 4.5), math.prandom(0.75, 1.25)
            love.graphics.rectangle('fill', point.x - r2x, point.y - r2y, 2*r2x, 2*r2y)
            love.graphics.pop()
        end
        love.graphics.setColor(color1[1], color1[2], color1[3], 80) 
        local r1x, r1y = math.prandom(5.5, 6.5), math.prandom(1.5, 2.5)
        love.graphics.circle('fill', cond_line.x1, cond_line.y1, 2*r1x)
        local r1x, r1y = math.prandom(5.5, 6.5), math.prandom(1.5, 2.5)
        love.graphics.circle('fill', cond_line.x2, cond_line.y2, 2*r1x)
        love.graphics.setColor(color2[1], color2[2], color2[3], 160)
        local r2x, r2y = math.prandom(3.5, 4.5), math.prandom(0.75, 1.25)
        love.graphics.circle('fill', cond_line.x1, cond_line.y1, 2*r2x)
        local r2x, r2y = math.prandom(3.5, 4.5), math.prandom(0.75, 1.25)
        love.graphics.circle('fill', cond_line.x2, cond_line.y2, 2*r2x)
        self.world:renderDetach()
        local cx, cy = self.world.camera:cameraCoords((cond_line.x1+cond_line.x2)/2, ((cond_line.y1+cond_line.y2)/2 - 10))
        cond_line.text.x = cx
        cond_line.text.y = cy
        pushRotateScale(cx, cy, Vector(cond_line.x2 - cond_line.x1, cond_line.y2 - cond_line.y1):angle())
        cond_line.text:draw()
        love.graphics.pop()
        self.world:renderAttach()
    end
end

function Entity:editorSettings(settings)
    self.editor_frame = loveframes.Create('frame')
    self.editor_frame:SetPos(settings.x, settings.y)
    self.editor_frame:SetSize(240, 40+35*#settings.rows)
    self.editor_frame:SetName('[' .. self.name .. '] ' .. settings.type .. "'s properties")
    self.editor_frame:SetVisible(false)
    self.editor_frame.OnClose = function(object) 
        self.editor_panel:Remove()
        self.editor_panel = nil
        object:Remove() 
        self.editor_frame = nil
    end
    self.editor_frame.alpha = 0 
    self.editor_panel = loveframes.Create('panel', self.editor_frame)
    self.editor_panel:SetPos(5, 30)
    self.editor_panel:SetSize(230, 5+35*#settings.rows)
    local font = love.graphics.newFont(bitstream_vera, 11)
    for i, r in ipairs(settings.rows) do
        if r[1] == 'checkbox' then
            local checkbox = loveframes.Create('checkbox', self.editor_panel)
            checkbox:SetFont(love.graphics.newFont(bitstream_vera, 11))
            checkbox:SetPos(5, 5+(i-1)*35+5)
            checkbox:SetText(r[2])
            checkbox:SetChecked(self[r[2]])
            checkbox.OnChanged = function(object, checked) self[r[2]] = checked end

        elseif r[1] == 'numberbox' then
            local button = loveframes.Create('button', self.editor_panel)
            button:SetPos(5, 5+(i-1)*35)
            local w = font:getWidth(r[2])
            button:SetSize(w+10, 30)
            button:SetText(r[2])
            button:SetClickable(false)
            local numberbox = loveframes.Create('numberbox', self.editor_panel)
            numberbox:SetPos(5+w+10, 5+(i-1)*35)
            numberbox:SetSize(230-5-w-10-5, 30)
            numberbox:SetLimit(5)
            numberbox:SetValue(self[r[2]])
            numberbox:SetMinMax(-99999, 99999)
            numberbox.OnValueChanged = function(object, value) self[r[2]] = value end

        elseif r[1] == 'textinput' then
            local button = loveframes.Create('button', self.editor_panel)
            button:SetPos(5, 5+(i-1)*35)
            local w = font:getWidth(r[2])
            button:SetSize(w+10, 30)
            button:SetText(r[2])
            button:SetClickable(false)
            local textinput = loveframes.Create('textinput', self.editor_panel)
            textinput:SetPos(5+w+10, 5+(i-1)*35)
            textinput:SetFont(love.graphics.newFont(bitstrema_vera, 11))
            textinput:SetRepeatDelay(0.2)
            textinput:SetSize(230-5-w-10-5, 30)
            textinput:SetText(self[r[2]])
            textinput.OnTextChanged = function(object, text) self[r[2]] = object:GetText() end
        
        elseif r[1] == 'multichoice' then
            local button = loveframes.Create('button', self.editor_panel)
            button:SetPos(5, 5+(i-1)*35)
            local w = font:getWidth(r[2])
            button:SetSize(w+10, 30)
            button:SetText(r[2])
            button:SetClickable(false)
            local multichoice = loveframes.Create('multichoice', self.editor_panel)
            multichoice:SetPos(5+w+10, 5+(i-1)*35)
            multichoice:SetSize(230-5-w-10-5, 30)
            for _, choice in ipairs(r[3]) do multichoice:AddChoice(choice) end
            multichoice:SetChoice(self[r[2]])
            multichoice.OnChoiceSelected = function(object, choice) 
                self[r[2]] = choice 
                if self.class.name == 'MovingWall' then self:createSpikes() end
            end

        elseif r[1] == 'button' then
            local button = loveframes.Create('button', self.editor_panel)
            button:SetPos(5, 5+(i-1)*35)
            button:SetSize(220, 30)
            button:SetText(r[2])
            button.OnClick = function(object) 
                if r[2] == 'Activate' then
                    if self.class.name == 'MovingWall' then
                        self:trigger() 
                    end
                end
            end
        end
    end

    self.editor_frame:SetVisible(true)
    timer:tween(0.25, self.editor_frame, {alpha = 255}, 'linear')
end
