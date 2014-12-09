require("loveframes")

function love.load()
    -- YOUR SAVE FOLDER HERE
    save_folder = "C:/Users/Waffles/dev/mogamett/tutorials/Pong/mogamett/resources/particles/sperm/"

    images = {}
    premultiplied_images = {}
    image_names = {}
    loads = {}
    load_names = {}
    getImages()
    getLoads()
    for i, image in ipairs(image_names) do images[image] = love.graphics.newImage(image) end
    for i, image in ipairs(image_names) do
        local data = love.image.newImageData(image)
        data:mapPixel(function(x, y, r, g, b, a) return (r*a)/255, (g*a)/255, (b*a)/255, a end)
        premultiplied_images[image] = love.graphics.newImage(data)
    end
    particle_systems = {}
    particle_frames = {}
    particle_settings = {}
    particle_positions = {}
    particle_x = love.window:getWidth()/2
    particle_y = love.window.getHeight()/2
    current_particle_s = 1
    hide_ui = false
    bg = {0, 0, 0, 0}
    blend_mode = 'alpha'
    -- top_panel = createTopPanel(5, 5)
    blend_panel = createBlendPanel(love.window:getWidth()-405, 5)
    color_panel = createColorPanel(love.window:getWidth()-325, 45)
    -- s_panel = createSPanel(love.window:getWidth()-405, 45)
    start()
end

function saveParticleSystem(n)
    if particle_settings[n]["name"] == "" then return end
    local file = assert(io.open(save_folder .. particle_settings[n]["name"] .. ".lua", "w"))
    local write_str = "return {"
    for k, v in pairs(particle_settings[n]) do
        if k == "colors" then
            local colors = {}
            for i = 1, #particle_settings[n]["colors"] do
                table.insert(colors, particle_settings[n]["colors"][i][1]) 
                table.insert(colors, particle_settings[n]["colors"][i][2]) 
                table.insert(colors, particle_settings[n]["colors"][i][3]) 
                table.insert(colors, particle_settings[n]["colors"][i][4]) 
            end
            write_str = write_str .. k .. " = " .. "{"
            for _, color in ipairs(colors) do write_str = write_str .. tostring(color) .. ", " end
            write_str = write_str .. "}, "
        elseif k == "sizes" then
            local sizes = {}
            for i = 1, #particle_settings[n]["sizes"] do
                table.insert(sizes, particle_settings[n]["sizes"][i])
            end
            write_str = write_str .. k .. " = " .. "{"
            for _, size in ipairs(sizes) do write_str = write_str .. tostring(size) .. ", " end
            write_str = write_str .. "}, "
        else 
            if type(v) == "string" then
                write_str = write_str .. k .. " = " .. '"' .. tostring(v) .. '", '
            else write_str = write_str .. k .. " = " .. tostring(v) .. ", " end
        end
    end
    write_str = write_str .. "}"
    file:write(write_str)
    file:close() 
end

function loadParticleSystem(n)
    if particle_settings[n]["load"] == "" or not particle_settings[n]["load"] then return end
    local name = particle_settings[n]["load"]
    local ps_data = require(string.sub(name, 1, -5))
    for k, v in pairs(ps_data) do 
        if k == "colors" then
            local j = 1
            for i = 1, #v, 4 do
                local color = {v[i], v[i+1], v[i+2], v[i+3]}
                particle_settings[n]["colors"][j] = color
                j = j + 1
            end
        elseif k == "sizes" then
            for i = 1, #v do
                particle_settings[n]["sizes"][i] = v[i]
            end
        else particle_settings[n][k] = v end
    end
    local panels = particle_frames[n]:GetChildren()[1]:GetChildren()
    panels[1]:GetChildren()[2]:SetText(particle_settings[n]["name"])
    panels[2]:GetChildren()[2]:SetChoice(particle_settings[n]["image"])
    panels[3]:GetChildren()[2]:SetChoice(particle_settings[n]["area_spread_distribution"])
    panels[3]:GetChildren()[3]:SetValue(particle_settings[n]["area_spread_dx"])
    panels[3]:GetChildren()[4]:SetValue(particle_settings[n]["area_spread_dy"])
    panels[4]:GetChildren()[2]:SetValue(particle_settings[n]["buffer_size"])
    panels[4]:GetChildren()[4]:SetValue(particle_settings[n]["direction"])
    local colors = panels[5]:GetChildren()[2]:GetChildren()
    for i = 1, #particle_settings[n]["colors"] do
        colors[i]:GetChildren()[1]:SetValue(particle_settings[n]["colors"][i][1])
        colors[i]:GetChildren()[2]:SetValue(particle_settings[n]["colors"][i][2])
        colors[i]:GetChildren()[3]:SetValue(particle_settings[n]["colors"][i][3])
        colors[i]:GetChildren()[4]:SetValue(particle_settings[n]["colors"][i][4])
    end
    panels[6]:GetChildren()[2]:SetValue(particle_settings[n]["emission_rate"])
    panels[6]:GetChildren()[4]:SetValue(particle_settings[n]["emission_lifetime"])
    panels[7]:GetChildren()[2]:SetChoice(particle_settings[n]["insert_mode"])
    panels[7]:GetChildren()[4]:SetValue(particle_settings[n]["spread"])
    panels[8]:GetChildren()[2]:SetValue(particle_settings[n]["linear_acceleration_xmin"])
    panels[8]:GetChildren()[3]:SetValue(particle_settings[n]["linear_acceleration_ymin"])
    panels[8]:GetChildren()[4]:SetValue(particle_settings[n]["linear_acceleration_xmax"])
    panels[8]:GetChildren()[5]:SetValue(particle_settings[n]["linear_acceleration_ymax"])
    panels[9]:GetChildren()[2]:SetValue(particle_settings[n]["offsetx"])
    panels[9]:GetChildren()[3]:SetValue(particle_settings[n]["offsety"])
    panels[10]:GetChildren()[2]:SetValue(particle_settings[n]["plifetime_min"])
    panels[10]:GetChildren()[3]:SetValue(particle_settings[n]["plifetime_max"])
    panels[11]:GetChildren()[2]:SetValue(particle_settings[n]["radialacc_min"])
    panels[11]:GetChildren()[3]:SetValue(particle_settings[n]["radialacc_max"])
    panels[12]:GetChildren()[2]:SetValue(particle_settings[n]["rotation_min"])
    panels[12]:GetChildren()[3]:SetValue(particle_settings[n]["rotation_max"])
    panels[13]:GetChildren()[2]:SetValue(particle_settings[n]["size_variation"])
    panels[13]:GetChildren()[4]:SetValue(particle_settings[n]["spin_variation"])
    local sizes = panels[14]:GetChildren()[2]:GetChildren()
    for i = 1, #particle_settings[n]["sizes"] do
        sizes[i]:GetChildren()[1]:SetValue(particle_settings[n]["sizes"][i])
    end
    panels[15]:GetChildren()[2]:SetValue(particle_settings[n]["spin_min"])
    panels[15]:GetChildren()[3]:SetValue(particle_settings[n]["spin_max"])
    panels[16]:GetChildren()[2]:SetValue(particle_settings[n]["speed_min"])
    panels[16]:GetChildren()[3]:SetValue(particle_settings[n]["speed_max"])
    panels[17]:GetChildren()[2]:SetValue(particle_settings[n]["tangential_acceleration_min"])
    panels[17]:GetChildren()[3]:SetValue(particle_settings[n]["tangential_acceleration_max"])
end

function createParticleSystem(n)
    local ps = nil
    if particle_settings[n]["buffer_size"] == 0 then particle_settings[n]["buffer_size"] = 1 end
    if blend_mode == 'premultiplied' then
        ps = love.graphics.newParticleSystem(premultiplied_images[particle_settings[n]["image"]], particle_settings[n]["buffer_size"])
    else ps = love.graphics.newParticleSystem(images[particle_settings[n]["image"]], particle_settings[n]["buffer_size"]) end
    ps:setAreaSpread(string.lower(particle_settings[n]["area_spread_distribution"]), particle_settings[n]["area_spread_dx"] or 0, particle_settings[n]["area_spread_dy"] or 0)
    ps:setBufferSize(particle_settings[n]["buffer_size"] or 1)
    local colors = {}
    for i = 1, 8 do 
        if particle_settings[n]["colors"][i][1] ~= 0 or particle_settings[n]["colors"][i][2] ~= 0 or particle_settings[n]["colors"][i][3] ~= 0 or particle_settings[n]["colors"][i][4] ~= 0 then
            table.insert(colors, particle_settings[n]["colors"][i][1] or 0)
            table.insert(colors, particle_settings[n]["colors"][i][2] or 0)
            table.insert(colors, particle_settings[n]["colors"][i][3] or 0)
            table.insert(colors, particle_settings[n]["colors"][i][4] or 0)
        end
    end
    ps:setColors(unpack(colors))
    ps:setDirection(math.rad(particle_settings[n]["direction"] or 0))
    ps:setEmissionRate(particle_settings[n]["emission_rate"] or 0)
    ps:setEmitterLifetime(particle_settings[n]["emitter_lifetime"] or 0)
    ps:setInsertMode(string.lower(particle_settings[n]["insert_mode"]))
    ps:setLinearAcceleration(particle_settings[n]["linear_acceleration_xmin"] or 0, particle_settings[n]["linear_acceleration_ymin"] or 0, 
                             particle_settings[n]["linear_acceleration_xmax"] or 0, particle_settings[n]["linear_acceleration_ymax"] or 0)
    if particle_settings[n]["offsetx"] ~= 0 or particle_settings[n]["offsety"] ~= 0 then
        ps:setOffset(particle_settings[n]["offsetx"], particle_settings[n]["offsety"])
    end
    ps:setParticleLifetime(particle_settings[n]["plifetime_min"] or 0, particle_settings[n]["plifetime_max"] or 0)
    ps:setRadialAcceleration(particle_settings[n]["radialacc_min"] or 0, particle_settings[n]["radialacc_max"] or 0)
    ps:setRotation(math.rad(particle_settings[n]["rotation_min"] or 0), math.rad(particle_settings[n]["rotation_max"] or 0))
    ps:setSizeVariation(particle_settings[n]["size_variation"] or 0)
    local sizes = {}
    local sizes_i = 1 
    for i = 1, 8 do 
        if particle_settings[n]["sizes"][i] == 0 then
            if i < 8 and particle_settings[n]["sizes"][i+1] == 0 then
                sizes_i = i
                break
            end
        end
    end
    if sizes_i > 1 then
        for i = 1, sizes_i do table.insert(sizes, particle_settings[n]["sizes"][i] or 0) end
        ps:setSizes(unpack(sizes))
    end
    ps:setSpeed(particle_settings[n]["speed_min"] or 0, particle_settings[n]["speed_max"] or 0)
    ps:setSpin(math.rad(particle_settings[n]["spin_min"] or 0), math.rad(particle_settings[n]["spin_max"] or 0))
    ps:setSpinVariation(particle_settings[n]["spin_variation"] or 0)
    ps:setSpread(math.rad(particle_settings[n]["spread"] or 0))
    ps:setTangentialAcceleration(particle_settings[n]["tangential_acceleration_min"] or 0, particle_settings[n]["tangential_acceleration_max"] or 0)

    ps:setPosition(particle_positions[n].x, particle_positions[n].y)
    ps:start()
    particle_systems[n] = ps
    return ps
end

function createSPanel(x, y)
    local panel = loveframes.Create('panel')
    panel:SetPos(x, y)
    panel:SetSize(75, 40)
    local s = loveframes.Create('button', panel)
    s:SetPos(5, 5)
    s:SetSize(65, 30)
    s:SetText(tostring(current_particle_s))
    s:SetClickable(false)
    return panel
end

function createColorPanel(x, y)
    local panel = loveframes.Create('panel')
    panel:SetPos(x, y)
    panel:SetSize(320, 40)
    local bg_text = loveframes.Create('button', panel)
    bg_text:SetPos(5, 5)
    bg_text:SetSize(90, 30)
    bg_text:SetText("Background Color")
    bg_text:SetClickable(false)
    local r = loveframes.Create('numberbox', panel)
    r:SetPos(100, 5)
    r:SetSize(50, 30)
    r:SetValue(0)
    r:SetIncreaseAmount(10)
    r:SetDecreaseAmount(10)
    r:SetMinMax(0, 255)
    r:SetLimit(3)
    r.OnValueChanged = function(object, value) bg[1] = value end
    local g = loveframes.Create('numberbox', panel)
    g:SetPos(155, 5)
    g:SetSize(50, 30)
    g:SetValue(0)
    g:SetIncreaseAmount(10)
    g:SetDecreaseAmount(10)
    g:SetMinMax(0, 255)
    g:SetLimit(3)
    g.OnValueChanged = function(object, value) bg[2] = value end
    local b = loveframes.Create('numberbox', panel)
    b:SetPos(210, 5)
    b:SetSize(50, 30)
    b:SetValue(0)
    b:SetIncreaseAmount(10)
    b:SetDecreaseAmount(10)
    b:SetMinMax(0, 255)
    b:SetLimit(3)
    b.OnValueChanged = function(object, value) bg[3] = value end
    local a = loveframes.Create('numberbox', panel)
    a:SetPos(265, 5)
    a:SetSize(50, 30)
    a:SetValue(0)
    a:SetIncreaseAmount(10)
    a:SetDecreaseAmount(10)
    a:SetMinMax(0, 255)
    a:SetLimit(3)
    a.OnValueChanged = function(object, value) bg[4] = value end
    return panel
end

function createBlendPanel(x, y)
    blend_mode = 'alpha'

    local buttons = {}
    local panel = loveframes.Create('panel')
    panel:SetPos(x, y)
    panel:SetSize(400, 35) 
    local additive = loveframes.Create('button', panel)
    additive:SetPos(5, 5)
    additive:SetSize(50, 25)
    additive:SetText('Additive')
    buttons['additive'] = additive
    local alpha = loveframes.Create('button', panel)
    alpha:SetPos(60, 5)
    alpha:SetSize(50, 25)
    alpha:SetText('Alpha')
    alpha:SetClickable(false)
    buttons['alpha'] = alpha
    local subtractive = loveframes.Create('button', panel)
    subtractive:SetPos(115, 5)
    subtractive:SetSize(70, 25)
    subtractive:SetText('Subtractive')
    buttons['subtractive'] = subtractive
    local multiplicative = loveframes.Create('button', panel)
    multiplicative:SetPos(190, 5)
    multiplicative:SetSize(70, 25)
    multiplicative:SetText('Multiplicative')
    buttons['multiplicative'] = multiplicative
    local premultiplied = loveframes.Create('button', panel)
    premultiplied:SetPos(265, 5)
    premultiplied:SetSize(75, 25)
    premultiplied:SetText('Premultiplied')
    buttons['premultiplied'] = premultiplied
    local replace = loveframes.Create('button', panel)
    replace:SetPos(345, 5)
    replace:SetSize(50, 25)
    replace:SetText('Replace')
    buttons['replace'] = replace
    additive.OnClick = function(object) 
        blend_mode = 'additive' 
        for _, button in pairs(buttons) do button:SetClickable(true) end
        object:SetClickable(false)
        for i = 1, #particle_systems do createParticleSystem(i) end
    end
    alpha.OnClick = function(object) 
        blend_mode = 'alpha' 
        for _, button in pairs(buttons) do button:SetClickable(true) end
        object:SetClickable(false)
        for i = 1, #particle_systems do createParticleSystem(i) end
    end
    subtractive.OnClick = function(object) 
        blend_mode = 'subtractive' 
        for _, button in pairs(buttons) do button:SetClickable(true) end
        object:SetClickable(false)
        for i = 1, #particle_systems do createParticleSystem(i) end
    end
    multiplicative.OnClick = function(object) 
        blend_mode = 'multiplicative' 
        for _, button in pairs(buttons) do button:SetClickable(true) end
        object:SetClickable(false)
        for i = 1, #particle_systems do createParticleSystem(i) end
    end
    premultiplied.OnClick = function(object) 
        blend_mode = 'premultiplied' 
        for _, button in pairs(buttons) do button:SetClickable(true) end
        object:SetClickable(false)
        for i = 1, #particle_systems do createParticleSystem(i) end
    end
    replace.OnClick = function(object) 
        blend_mode = 'replace' 
        for _, button in pairs(buttons) do button:SetClickable(true) end
        object:SetClickable(false)
        for i = 1, #particle_systems do createParticleSystem(i) end
    end
    return panel
end

function start()
    table.insert(particle_positions, {x = love.window.getWidth()/2, y = love.window.getHeight()/2})
    local frame = createParticleFrame(#particle_frames+1, "PS", 5 + 285*(#particle_frames), 5, 280, 795)
    table.insert(particle_frames, frame)
end

function createTopPanel(x, y)
    local structure = {}
    structure.n = 0
    structure.particle_buttons = {}

    local panel = loveframes.Create('panel')
    panel:SetPos(x, y)
    panel:SetWidth(40)
    panel:SetHeight(35)
    structure.panel = panel

    local add_button = loveframes.Create('button', panel)
    add_button:SetPos(5, 5)
    add_button:SetText('+')
    add_button:SetWidth(30)
    add_button.OnClick = function(object, x, y)
        structure.n = structure.n + 1
        panel:SetWidth(panel:GetWidth() + 55)
        add_button:SetX(add_button:GetX() + 50)

        table.insert(particle_positions, {x = love.window.getWidth()/2, y = love.window.getHeight()/2})
        local frame = createParticleFrame(#particle_frames+1, "PS" .. structure.n, 5 + 285*(#particle_frames), 45, 280, 795)
        table.insert(particle_frames, frame)

        local particle_button = loveframes.Create('button', panel)
        particle_button:SetWidth(50)
        particle_button:SetPos(5 + #structure.particle_buttons*55, 5)
        particle_button:SetText("PS" .. structure.n)
        particle_button.OnClick = function(object, x, y, button)
            local n = findIndexByObject(structure.particle_buttons, object)
            if button == "l" then
                if particle_frames[n]:GetVisible() then particle_frames[n]:SetVisible(false)
                else particle_frames[n]:SetVisible(true) end
            elseif button == "r" then
                object:Remove()
                table.remove(structure.particle_buttons, n)
                particle_frames[n]:Remove()
                table.remove(particle_frames, n)
                table.remove(particle_systems, n)
                for i, button in ipairs(structure.particle_buttons) do button:SetPos(5 + (i-1)*55, 5) end
                for i, particle_frame in ipairs(particle_frames) do particle_frame:SetPos(5 + (i-1)*285, 45) end
                panel:SetWidth(panel:GetWidth() - 55)
                add_button:SetX(add_button:GetX() - 60)
            end
        end
        table.insert(structure.particle_buttons, particle_button)
    end
    structure.add_button = add_button

    return structure 
end

function createParticleFrame(n, name, x, y, w, h)
    particle_settings[n] = {}

    local frame = loveframes.Create('frame')
    frame:SetName(name)
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetPos(x, y)
    frame:SetWidth(w)
    frame:SetHeight(h)

    local panel = loveframes.Create('panel', frame)
    panel:SetPos(5, 30)
    panel:SetWidth(w-10)
    panel:SetHeight(h-35)

    particle_settings[n]["name"] = ""
    local name_panel = loveframes.Create('panel', panel)
    name_panel:SetPos(5, 5)
    name_panel:SetSize(w-20, 30)
    local name_button = loveframes.Create('button', name_panel)
    name_button:SetPos(0, 0)
    name_button:SetSize(50, 30)
    name_button:SetText("Name")
    local name_textinput = loveframes.Create('textinput', name_panel)
    name_textinput:SetPos(50, 0)
    name_textinput:SetSize(w-20-50, 30)
    name_textinput:SetFont(love.graphics.newFont(12))
    name_textinput:SetRepeatDelay(0.2)
    name_textinput.OnTextChanged = function(object, text) particle_settings[n]["name"] = object:GetText() end
    name_button.OnClick = function(object, x, y) 
        name_textinput:Clear() 
        particle_settings[n]["name"] = ""
    end

    particle_settings[n]["image"] = image_names[1]
    local image_panel = loveframes.Create('panel', panel)
    image_panel:SetPos(5, 40)
    image_panel:SetSize(w-20, 30)
    local image_button = loveframes.Create('button', image_panel)
    image_button:SetPos(0, 0)
    image_button:SetSize(50, 30)
    image_button:SetText("Image")
    image_button:SetClickable(false)
    local image_multi = loveframes.Create('multichoice', image_panel)
    image_multi:SetPos(50, 0)
    image_multi:SetSize(w-20-50, 30)
    image_multi:SetChoice(image_names[1])
    for _, image_name in ipairs(image_names) do image_multi:AddChoice(image_name) end
    image_multi.OnChoiceSelected = function(object, choice) 
        particle_settings[n]["image"] = choice 
        createParticleSystem(n)
    end

    particle_settings[n]["area_spread_distribution"] = "None"
    particle_settings[n]["area_spread_dx"] = 0
    particle_settings[n]["area_spread_dy"] = 0
    local area_panel = loveframes.Create('panel', panel)
    area_panel:SetPos(5, 75)
    area_panel:SetSize(w-20, 30)
    local area_button = loveframes.Create('button', area_panel)
    area_button:SetPos(0, 0)
    area_button:SetSize(80, 30)
    area_button:SetText("Area Spread")
    local area_multi = loveframes.Create('multichoice', area_panel)
    area_multi:SetPos(80, 0)
    area_multi:SetSize(70, 30)
    area_multi:AddChoice("None")
    area_multi:AddChoice("Uniform")
    area_multi:AddChoice("Normal")
    area_multi:SetChoice("None")
    particle_settings[n]["area_spread_distribution"] = "None"
    area_multi.OnChoiceSelected = function(object, choice) 
        particle_settings[n]["area_spread_distribution"] = choice 
        createParticleSystem(n)
    end
    local area_dx = loveframes.Create('numberbox', area_panel)
    area_dx:SetPos(150, 0)
    area_dx:SetSize(55, 30)
    area_dx:SetMinMax(-999, 999)
    area_dx:SetIncreaseAmount(5)
    area_dx:SetDecreaseAmount(5)
    area_dx.OnValueChanged = function(object, value) 
        particle_settings[n]["area_spread_dx"] = value 
        createParticleSystem(n)
    end
    local area_dy = loveframes.Create('numberbox', area_panel)
    area_dy:SetPos(205, 0)
    area_dy:SetSize(55, 30)
    area_dy:SetMinMax(-999, 999)
    area_dy:SetIncreaseAmount(5)
    area_dy:SetDecreaseAmount(5)
    area_dy.OnValueChanged = function(object, value) 
        particle_settings[n]["area_spread_dy"] = value 
        createParticleSystem(n)
    end
    area_button.OnClick = function(object, x, y) 
        area_multi:SetChoice("None")
        particle_settings[n]["area_spread_distribution"] = "None"
        area_dx:SetValue(0)
        particle_settings[n]["area_spread_dx"] = 0
        area_dy:SetValue(0)
        particle_settings[n]["area_spread_dy"] = 0
        createParticleSystem(n)
    end

    particle_settings[n]["buffer_size"] = 1000
    particle_settings[n]["direction"] = 0
    local buffer_panel = loveframes.Create('panel', panel)
    buffer_panel:SetPos(5, 110)
    buffer_panel:SetSize(w-20, 30)
    local buffer_button = loveframes.Create('button', buffer_panel)
    buffer_button:SetPos(0, 0)
    buffer_button:SetSize(80, 30)
    buffer_button:SetText("Buffer Size")
    local buffer_size = loveframes.Create('numberbox', buffer_panel)
    buffer_size:SetPos(80, 0)
    buffer_size:SetSize(70, 30)
    buffer_size:SetMinMax(1, 9999999)
    buffer_size:SetLimit(7)
    buffer_size:SetValue(1000)
    buffer_size.OnValueChanged = function(object, value) 
        particle_settings[n]["buffer_size"] = value 
        createParticleSystem(n)
    end
    buffer_button.OnClick = function(object, x, y) 
        buffer_size:SetValue(1000)
        particle_settings[n]["buffer_size"] = 1000
        createParticleSystem(n)
    end
    local direction_button = loveframes.Create('button', buffer_panel)
    direction_button:SetPos(150, 0)
    direction_button:SetSize(55, 30)
    direction_button:SetText("Direction")
    local direction = loveframes.Create('numberbox', buffer_panel)
    direction:SetPos(205, 0)
    direction:SetSize(55, 30)
    direction:SetMinMax(-360, 360)
    direction:SetLimit(4)
    direction:SetIncreaseAmount(10)
    direction:SetDecreaseAmount(10)
    direction.OnValueChanged = function(object, value) 
        particle_settings[n]["direction"] = value 
        createParticleSystem(n)
    end
    direction_button.OnClick = function(object, x, y)
        direction:SetValue(0)
        particle_settings[n]["direction"] = 0
        createParticleSystem(n)
    end

    local colors_panel = loveframes.Create('panel', panel)
    colors_panel:SetPos(5, 145)
    colors_panel:SetSize(w-20, 60)
    local colors_color = loveframes.Create('panel', colors_panel)
    colors_color:SetPos(0, 0)
    colors_color:SetSize(50, 60)
    local colors_button = loveframes.Create('button', colors_color)
    colors_button:SetPos(0, 0)
    colors_button:SetSize(51, 18)
    colors_button:SetText("Colors")
    local colors_tabs = loveframes.Create('tabs', colors_panel)
    colors_tabs:SetPos(50, 0)
    colors_tabs:SetSize(w-20-50, 59)
    colors_tabs:SetTabHeight(18)
    particle_settings[n]["colors"] = {} 
    for i = 1, 8 do 
        if i == 1 then particle_settings[n]["colors"][i] = {255, 255, 255, 255}
        elseif i == 2 then particle_settings[n]["colors"][i] = {255, 255, 255, 0}
        else particle_settings[n]["colors"][i] = {0, 0, 0, 0} end
        local tab_panel = loveframes.Create('panel')
        local r = loveframes.Create('numberbox', tab_panel)
        r:SetPos(0, 0)
        r:SetSize(50, 31)
        r:SetMinMax(0, 255)
        r:SetIncreaseAmount(10)
        r:SetDecreaseAmount(10)
        r:SetLimit(3)
        if i == 1 then r:SetValue(255) end
        if i == 2 then r:SetValue(255) end
        r.OnValueChanged = function(object, value) 
            particle_settings[n]["colors"][i][1] = value 
            createParticleSystem(n)
        end
        local g = loveframes.Create('numberbox', tab_panel)
        g:SetPos(50, 0)
        g:SetSize(50, 31)
        g:SetMinMax(0, 255)
        g:SetIncreaseAmount(10)
        g:SetDecreaseAmount(10)
        g:SetLimit(3)
        if i == 1 then g:SetValue(255) end
        if i == 2 then g:SetValue(255) end
        g.OnValueChanged = function(object, value) 
            particle_settings[n]["colors"][i][2] = value 
            createParticleSystem(n)
        end
        local b = loveframes.Create('numberbox', tab_panel)
        b:SetPos(100, 0)
        b:SetSize(50, 31)
        b:SetMinMax(0, 255)
        b:SetIncreaseAmount(10)
        b:SetDecreaseAmount(10)
        b:SetLimit(3)
        if i == 1 then b:SetValue(255) end
        if i == 2 then b:SetValue(255) end
        b.OnValueChanged = function(object, value) 
            particle_settings[n]["colors"][i][3] = value 
            createParticleSystem(n)
        end
        local a = loveframes.Create('numberbox', tab_panel)
        a:SetPos(150, 0)
        a:SetSize(50, 31)
        a:SetMinMax(0, 255)
        a:SetIncreaseAmount(10)
        a:SetDecreaseAmount(10)
        a:SetLimit(3)
        if i == 1 then a:SetValue(255) end
        if i == 2 then a:SetValue(0) end
        a.OnValueChanged = function(object, value) 
            particle_settings[n]["colors"][i][4] = value 
            createParticleSystem(n)
        end
        colors_tabs:AddTab(i, tab_panel) 
    end
    colors_button.OnClick = function(object, x, y)
        for i = 1, 8 do 
            if i == 1 then particle_settings[n]["colors"][i] = {255, 255, 255, 255}
            elseif i == 2 then particle_settings[n]["colors"][i] = {255, 255, 255, 0}
            else particle_settings[n]["colors"][i] = {0, 0, 0, 0} end
        end
        for i = 1, 8 do
            if i == 1 then
                local numberboxes = colors_tabs:GetChildren()[i]:GetChildren()
                numberboxes[1]:SetValue(255)
                numberboxes[2]:SetValue(255)
                numberboxes[3]:SetValue(255)
                numberboxes[4]:SetValue(255)
            elseif i == 2 then
                local numberboxes = colors_tabs:GetChildren()[i]:GetChildren()
                numberboxes[1]:SetValue(255)
                numberboxes[2]:SetValue(255)
                numberboxes[3]:SetValue(255)
                numberboxes[4]:SetValue(0)
            else
                local numberboxes = colors_tabs:GetChildren()[i]:GetChildren()
                numberboxes[1]:SetValue(0)
                numberboxes[2]:SetValue(0)
                numberboxes[3]:SetValue(0)
                numberboxes[4]:SetValue(0)
            end
        end
        createParticleSystem(n)
    end
    colors_color.Draw = function(object)
        local i = colors_tabs:GetTabNumber()
        local r, g, b, a = particle_settings[n]["colors"][i][1], particle_settings[n]["colors"][i][2], particle_settings[n]["colors"][i][3], particle_settings[n]["colors"][i][4] 
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle('fill', 3 + object:GetX(), 3 + 17 + object:GetY(), 45, 37)
        love.graphics.setColor(255, 255, 255, 255)
    end

    particle_settings[n]["emission_rate"] = 100
    particle_settings[n]["emitter_lifetime"] = -1
    local emission_panel = loveframes.Create('panel', panel)
    emission_panel:SetPos(5, 210)
    emission_panel:SetSize(w-20, 30)
    local rate_button = loveframes.Create('button', emission_panel)
    rate_button:SetPos(0, 0)
    rate_button:SetSize(80, 30)
    rate_button:SetText("Emission Rate")
    local emission_rate = loveframes.Create('numberbox', emission_panel)
    emission_rate:SetPos(80, 0)
    emission_rate:SetSize(70, 30)
    emission_rate:SetMinMax(0, 9999999)
    emission_rate:SetLimit(7)
    emission_rate:SetValue(100)
    emission_rate.OnValueChanged = function(object, value) 
        particle_settings[n]["emission_rate"] = value 
        createParticleSystem(n)
    end
    rate_button.OnClick = function(object, x, y)
        particle_settings[n]["emission_rate"] = 100
        emission_rate:SetValue(100)
        createParticleSystem(n)
    end
    local elifetime_button = loveframes.Create('button', emission_panel)
    elifetime_button:SetPos(150, 0)
    elifetime_button:SetSize(55, 30)
    elifetime_button:SetText("ELifetime")
    local emitter_lifetime = loveframes.Create('numberbox', emission_panel)
    emitter_lifetime:SetPos(205, 0)
    emitter_lifetime:SetSize(55, 30)
    emitter_lifetime:SetMinMax(-1, 9999)
    emitter_lifetime:SetLimit(4)
    emitter_lifetime:SetValue(-1)
    emitter_lifetime.OnValueChanged = function(object, value) 
        particle_settings[n]["emitter_lifetime"] = value 
        createParticleSystem(n)
    end
    elifetime_button.OnClick = function(object, x, y)
        particle_settings[n]["emitter_lifetime"] = -1
        emitter_lifetime:SetValue(-1)
        createParticleSystem(n)
    end

    particle_settings[n]["insert_mode"] = "Top"
    particle_settings[n]["spread"] = 360
    local imode_panel = loveframes.Create('panel', panel)
    imode_panel:SetPos(5, 245)
    imode_panel:SetSize(w-20, 30)
    local imode_button = loveframes.Create('button', imode_panel)
    imode_button:SetPos(0, 0)
    imode_button:SetSize(80, 30)
    imode_button:SetClickable(false)
    imode_button:SetText("Insert Mode")
    local imode_multi = loveframes.Create('multichoice', imode_panel)
    imode_multi:SetPos(80, 0)
    imode_multi:SetSize(70, 30)
    imode_multi:AddChoice("Top")
    imode_multi:AddChoice("Bottom")
    imode_multi:AddChoice("Random")
    imode_multi:SetChoice("Top")
    particle_settings[n]["insert_mode"] = "Top"
    imode_multi.OnChoiceSelected = function(object, choice) 
        particle_settings[n]["insert_mode"] = choice 
        createParticleSystem(n)
    end
    local spread_button = loveframes.Create('button', imode_panel)
    spread_button:SetPos(150, 0)
    spread_button:SetSize(55, 30)
    spread_button:SetText("Spread")
    local spread = loveframes.Create('numberbox', imode_panel)
    spread:SetPos(205, 0)
    spread:SetSize(55, 30)
    spread:SetMinMax(-360, 360)
    spread:SetLimit(4)
    spread:SetIncreaseAmount(10)
    spread:SetDecreaseAmount(10)
    spread:SetValue(360)
    spread.OnValueChanged = function(object, value) 
        particle_settings[n]["spread"] = value 
        createParticleSystem(n)
    end
    spread.OnClick = function(object, x, y)
        particle_settings[n]["spread"] = 360
        spread:SetValue(360)
        createParticleSystem(n)
    end

    particle_settings[n]["linear_acceleration_xmin"] = 0
    particle_settings[n]["linear_acceleration_ymin"] = 0
    particle_settings[n]["linear_acceleration_xmax"] = 0
    particle_settings[n]["linear_acceleration_ymax"] = 0
    local lacc_panel = loveframes.Create('panel', panel)
    lacc_panel:SetPos(5, 280)
    lacc_panel:SetSize(w-20, 60)
    local lacc_button = loveframes.Create('button', lacc_panel)
    lacc_button:SetPos(0, 0)
    lacc_button:SetSize(100, 60)
    lacc_button:SetText("Linear Acceleration")
    local lacc_xmin = loveframes.Create('numberbox', lacc_panel)
    lacc_xmin:SetPos(100, 0)
    lacc_xmin:SetSize(80, 30)
    lacc_xmin:SetLimit(5)
    lacc_xmin:SetMinMax(-99999, 99999)
    lacc_xmin:SetIncreaseAmount(10)
    lacc_xmin:SetDecreaseAmount(10)
    lacc_xmin.OnValueChanged = function(object, value) 
        particle_settings[n]["linear_acceleration_xmin"] = value 
        createParticleSystem(n)
    end
    local lacc_ymin = loveframes.Create('numberbox', lacc_panel)
    lacc_ymin:SetPos(180, 0)
    lacc_ymin:SetSize(80, 30)
    lacc_ymin:SetLimit(8)
    lacc_ymin:SetMinMax(-99999, 99999)
    lacc_ymin:SetIncreaseAmount(10)
    lacc_ymin:SetDecreaseAmount(10)
    lacc_ymin.OnValueChanged = function(object, value) 
        particle_settings[n]["linear_acceleration_ymin"] = value 
        createParticleSystem(n)
    end
    local lacc_xmax = loveframes.Create('numberbox', lacc_panel)
    lacc_xmax:SetPos(100, 30)
    lacc_xmax:SetSize(80, 30)
    lacc_xmax:SetLimit(5)
    lacc_xmax:SetMinMax(-99999, 99999)
    lacc_xmax:SetIncreaseAmount(10)
    lacc_xmax:SetDecreaseAmount(10)
    lacc_xmax.OnValueChanged = function(object, value) 
        particle_settings[n]["linear_acceleration_xmax"] = value 
        createParticleSystem(n)
    end
    local lacc_ymax = loveframes.Create('numberbox', lacc_panel)
    lacc_ymax:SetPos(180, 30)
    lacc_ymax:SetSize(80, 30)
    lacc_ymax:SetLimit(8)
    lacc_ymax:SetMinMax(-99999, 99999)
    lacc_ymax:SetIncreaseAmount(10)
    lacc_ymax:SetDecreaseAmount(10)
    lacc_ymax.OnValueChanged = function(object, value) 
        particle_settings[n]["linear_acceleration_ymax"] = value 
        createParticleSystem(n)
    end
    lacc_button.OnClick = function(object, x, y)
        particle_settings[n]["linear_acceleration_xmin"] = 0
        particle_settings[n]["linear_acceleration_ymin"] = 0
        particle_settings[n]["linear_acceleration_xmax"] = 0
        particle_settings[n]["linear_acceleration_ymax"] = 0
        lacc_xmin:SetValue(0)
        lacc_ymin:SetValue(0)
        lacc_xmax:SetValue(0)
        lacc_ymax:SetValue(0)
        createParticleSystem(n)
    end

    local createDoubleNumberbox = function(py, bw, btext, n1w, n1l, n1min, n1max, n1ia, n1da, n1ps, n2ps, n1v, n2v)
        particle_settings[n][n1ps] = n1v or 0
        particle_settings[n][n2ps] = n2v or 0
        local ppanel = loveframes.Create('panel', panel)
        ppanel:SetPos(5, py)
        ppanel:SetSize(w-20, 30)
        local pbutton = loveframes.Create('button', ppanel)
        pbutton:SetPos(0, 0)
        pbutton:SetSize(bw, 30)
        pbutton:SetText(btext)
        local nb1 = loveframes.Create('numberbox', ppanel)
        nb1:SetPos(bw, 0)
        nb1:SetSize(n1w, 30)
        nb1:SetLimit(n1l)
        nb1:SetMinMax(n1min, n1max)
        nb1:SetIncreaseAmount(n1ia)
        nb1:SetDecreaseAmount(n1da)
        nb1:SetValue(n1v or 0)
        nb1.OnValueChanged = function(object, value) 
            particle_settings[n][n1ps] = value 
            createParticleSystem(n)
        end
        local nb2 = loveframes.Create('numberbox', ppanel)
        nb2:SetPos(bw+n1w, 0)
        nb2:SetSize(n1w, 30)
        nb2:SetLimit(n1l)
        nb2:SetMinMax(n1min, n1max)
        nb2:SetIncreaseAmount(n1ia)
        nb2:SetDecreaseAmount(n1da)
        nb2:SetValue(n2v or 0)
        nb2.OnValueChanged = function(object, value) 
            particle_settings[n][n2ps] = value 
            createParticleSystem(n)
        end
        pbutton.OnClick = function(object, x, y)
            particle_settings[n][n1ps] = n1v or 0
            particle_settings[n][n2ps] = n2v or 0
            nb1:SetValue(n1v or 0)
            nb2:SetValue(n2v or 0)
            createParticleSystem(n)
        end
    end

    createDoubleNumberbox(345, 100, "Offset", 80, 9, -999999, 999999, 10, 10, "offsetx", "offsety")
    createDoubleNumberbox(380, 100, "Particle Lifetime", 80, 9, 0, 999999, 1, 1, "plifetime_min", "plifetime_max", 0, 1)
    createDoubleNumberbox(415, 100, "Radial Acceleration", 80, 9, -999999, 999999, 10, 10, "radialacc_min", "radialacc_max")
    createDoubleNumberbox(450, 100, "Rotation", 80, 4, -360, 360, 10, 10, "rotation_min", "rotation_max")

    particle_settings[n]["size_variation"] = 0
    particle_settings[n]["spin_variation"] = 0
    local variation_panel = loveframes.Create('panel', panel)
    variation_panel:SetPos(5, 485)
    variation_panel:SetSize(w-20, 30)
    local size_button = loveframes.Create('button', variation_panel)
    size_button:SetPos(0, 0)
    size_button:SetSize(70, 30)
    size_button:SetText("Size Variation")
    local sizev = loveframes.Create('numberbox', variation_panel)
    sizev:SetPos(70, 0)
    sizev:SetSize(60, 30)
    sizev:SetLimit(5)
    sizev:SetMinMax(0, 1)
    sizev:SetIncreaseAmount(0.05)
    sizev:SetDecreaseAmount(0.05)
    sizev.OnValueChanged = function(object, value) 
        particle_settings[n]["size_variation"] = value 
        createParticleSystem(n)
    end
    size_button.OnClick = function(object, x, y)
        particle_settings[n]["size_variation"] = 0
        sizev:SetValue(0)
        createParticleSystem(n)
    end
    local spin_button = loveframes.Create('button', variation_panel)
    spin_button:SetPos(130, 0)
    spin_button:SetSize(73, 30)
    spin_button:SetText("Spin Variation")
    local spinv = loveframes.Create('numberbox', variation_panel)
    spinv:SetPos(203, 0)
    spinv:SetSize(57, 30)
    spinv:SetLimit(5)
    spinv:SetMinMax(0, 1)
    spinv:SetIncreaseAmount(0.05)
    spinv:SetDecreaseAmount(0.05)
    spinv.OnValueChanged = function(object, value) 
        particle_settings[n]["spin_variation"] = value 
        createParticleSystem(n)
    end
    spin_button.OnClick = function(object, x, y)
        particle_settings[n]["spin_variation"] = 0
        spinv:SetValue(0)
        createParticleSystem(n)
    end

    local sizes_panel = loveframes.Create('panel', panel)
    sizes_panel:SetPos(5, 520)
    sizes_panel:SetSize(w-20, 60)
    local sizes_button = loveframes.Create('button', sizes_panel)
    sizes_button:SetPos(0, 0)
    sizes_button:SetSize(50, 60)
    sizes_button:SetText("Sizes")
    local sizes_tabs = loveframes.Create('tabs', sizes_panel)
    sizes_tabs:SetPos(50, 0)
    sizes_tabs:SetSize(w-20-50, 59)
    sizes_tabs:SetTabHeight(18)
    particle_settings[n]["sizes"] = {}
    for i = 1, 8 do
        particle_settings[n]["sizes"][i] = 0
        local tab_panel = loveframes.Create('panel')
        local s = loveframes.Create('numberbox', tab_panel)
        s:SetPos(0, 0)
        s:SetSize(200, 31)
        s:SetMinMax(0, 9999)
        s:SetLimit(7)
        s:SetIncreaseAmount(0.05)
        s:SetDecreaseAmount(0.05)
        s.OnValueChanged = function(object, value) 
            particle_settings[n]["sizes"][i] = value 
            createParticleSystem(n)
        end
        sizes_tabs:AddTab(i, tab_panel)
    end
    sizes_button.OnClick = function(object, x, y)
        for i = 1, 8 do particle_settings[n]["sizes"][i] = 0 end
        for i = 1, 8 do sizes_tabs:GetChildren()[i]:GetChildren()[1]:SetValue(0) end
        createParticleSystem(n)
    end

    createDoubleNumberbox(585, 100, "Spin", 80, 9, -999999, 999999, 10, 10, "spin_min", "spin_max")
    createDoubleNumberbox(620, 100, "Speed", 80, 9, -999999, 999999, 10, 10, "speed_min", "speed_max", 0, 50)
    createDoubleNumberbox(655, 100, "Tang. Acceleration", 80, 9, -999999, 999999, 10, 10, "tangential_acceleration_min", "tangential_acceleration_max")

    local buttons_panel = loveframes.Create('panel', panel)
    buttons_panel:SetPos(5, 690)
    buttons_panel:SetSize(w-20, 30)
    local restart = loveframes.Create('button', buttons_panel)
    restart:SetPos(0, 0)
    restart:SetSize(130, 30)
    restart:SetText("Restart")
    restart.OnClick = function(object, x, y) createParticleSystem(n) end
    local save = loveframes.Create('button', buttons_panel)
    save:SetPos(130, 0)
    save:SetSize(130, 30)
    save:SetText("Save")

    local load_panel = loveframes.Create('panel', panel)
    load_panel:SetPos(5, 725)
    load_panel:SetSize(w-20, 30)
    local load_button = loveframes.Create('button', load_panel)
    load_button:SetPos(0, 0)
    load_button:SetSize(50, 30)
    load_button:SetText("Load")
    load_button.OnClick = function(object, x, y) loadParticleSystem(n) end
    local load_multi = loveframes.Create('multichoice', load_panel)
    load_multi:SetPos(50, 0)
    load_multi:SetSize(w-20-50, 30)
    load_multi:SetChoice(load_names[1])
    load_multi:SetChoice("")
    for _, load_name in ipairs(load_names) do load_multi:AddChoice(load_name) end
    load_multi.OnChoiceSelected = function(object, choice) 
        particle_settings[n]["load"] = choice 
    end
    save.OnClick = function(object, x, y) 
        saveParticleSystem(n) 
        getLoads()
        load_multi:AddChoice(particle_settings[n]["name"] .. ".lua")
    end

    return frame
end

function love.update(dt)
    loveframes.update(dt)
    for _, ps in ipairs(particle_systems) do ps:update(dt) end
    if love.mouse.isDown('l') then
        if love.keyboard.isDown('lctrl') then
            if #particle_systems >= 1 then
                if particle_systems[current_particle_s] then
                    particle_systems[current_particle_s]:setPosition(love.mouse.getPosition())
                end
            end
        end
    end
end

function love.draw()
    loveframes.draw() 
    love.graphics.setBackgroundColor(bg[1], bg[2], bg[3], bg[4])
    love.graphics.setBlendMode(blend_mode)
    for _, ps in ipairs(particle_systems) do love.graphics.draw(ps, 0, 0) end
    love.graphics.setBlendMode('alpha')
    love.graphics.setColor(255, 255, 255, 255)
end

function love.mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)    
end

function love.mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
    loveframes.keypressed(key, unicode)
    if key == 'f1' then
        hide_ui = not hide_ui
        if hide_ui then
            for _, frame in ipairs(particle_frames) do frame:SetVisible(false) end
            -- top_panel.panel:SetVisible(false)
            blend_panel:SetVisible(false)
            color_panel:SetVisible(false)
            -- s_panel:SetVisible(false)
        else
            for _, frame in ipairs(particle_frames) do frame:SetVisible(true) end
            -- top_panel.panel:SetVisible(true)
            blend_panel:SetVisible(true)
            color_panel:SetVisible(true)
            -- s_panel:SetVisible(true)
        end
    end
end

function love.keyreleased(key)
    loveframes.keyreleased(key)
end

function love.textinput(text)
    loveframes.textinput(text)
end

function getImages()
    local files = love.filesystem.getDirectoryItems("")
    for k, file in ipairs(files) do
        local ext = string.sub(file, -3)
        if ext == "png" or ext == "jpg" or ext == "peg" then table.insert(image_names, file) end
    end
end

function getLoads()
    local files = love.filesystem.getDirectoryItems("")
    for k, file in ipairs(files) do
        local ext = string.sub(file, -3)
        if ext == "lua" then
            if file ~= "main.lua" and file ~= "conf.lua" then table.insert(load_names, file) end
        end
    end
end

function findIndexByObject(tbl, object)
    for i, o in ipairs(tbl) do
        if object == o then return i end
    end
end
