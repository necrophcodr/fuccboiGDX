function love.load()
    mg = require 'mogamett/mogamett'
    mg.init()

    require 'Paddle'
    require 'Ball'

    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)
    font = love.graphics.newFont('HelvetiPixel.ttf', 92)
    love.graphics.setFont(font)

    camera = mg.Camera()
    camera:follow({x = 400, y = 300}, {lerp = 1})
    camera:setDeadzone(0, 0, 0, 0)

    level = 1

    paddle1 = Paddle(50, 30)
    paddle2 = Paddle(750, 300, {ai = true})

    balls = {}
    table.insert(balls, Ball(400, 300))
    ball_trails = {}
    paddle_trails = {}

    canvas_1 = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    canvas_2 = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    canvas_3 = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    rgb = love.graphics.newShader('mogamett/resources/shaders/seperator.frag', 'mogamett/resources/shaders/default.vert')
    rgb:send('textureSize', {600, 600})
    phosphor = love.graphics.newShader('mogamett/resources/shaders/phosphor.frag', 'mogamett/resources/shaders/default.vert')
    phosphor:send('textureSize', {150, 150})
    heavybloom = love.graphics.newShader('mogamett/resources/shaders/heavybloom.frag', 'mogamett/resources/shaders/default.vert')
    heavybloom:send('textureSize', {400, 400})

    mg.input:bind('p', 'pause')
    paused = false

    love.window.setTitle('CurveMaster')
end

function love.update(dt)
    if mg.input:pressed('pause') then paused = not paused end
    if paused then return end
    mg.update(dt)

    camera:update(dt)
    paddle1:update(dt)
    paddle2:update(dt)
    for i = #balls, 1, -1 do
        balls[i]:update(dt)
        if balls[i].dead then table.remove(balls, i) end
    end
    for i = #ball_trails, 1, -1 do
        ball_trails[i]:update(dt)
        if ball_trails[i].dead then table.remove(ball_trails, i) end
    end
    for i = #paddle_trails, 1, -1 do
        paddle_trails[i]:update(dt)
        if paddle_trails[i].dead then table.remove(paddle_trails, i) end
    end

    local r = mg.utils.math.random
    local intensity = 0.8*level
    rgb:send('redoffset', {r(-intensity, intensity), r(-intensity, intensity)})
    rgb:send('greenoffset', {r(-intensity, intensity), r(-intensity, intensity)})
    rgb:send('blueoffset', {r(-intensity, intensity), r(-intensity, intensity)})

    heavybloom:send('glarebasesize', 0.5*level)
end

function love.draw()
    canvas_1:clear()
    canvas_1:renderTo(function()
        camera:attach()
        mg.draw()

        local w, h = font:getWidth('Level: ' .. tostring(level)), font:getHeight()
        love.graphics.print('Level: ' .. tostring(level), 200 - w/2, 100 - h/2)

        paddle1:draw()
        paddle2:draw()
        for _, ball in ipairs(balls) do ball:draw() end
        for _, ball_trail in ipairs(ball_trails) do ball_trail:draw() end
        for _, paddle_trail in ipairs(paddle_trails) do paddle_trail:draw() end
        camera:detach()
    end)

    canvas_2:clear()
    canvas_2:renderTo(function()
        love.graphics.setShader(rgb)
        love.graphics.draw(canvas_1, 0, 0)
        love.graphics.setShader()
    end)

    canvas_3:clear()
    canvas_3:renderTo(function()
        love.graphics.setShader(phosphor)
        love.graphics.draw(canvas_2, 0, 0)
        love.graphics.setShader()
    end)

    love.graphics.setShader(heavybloom)
    love.graphics.draw(canvas_3, 0, 0)
    love.graphics.setShader()
end


function love.keypressed(key)
    mg.keypressed(key)
end

function love.keyreleased(key)
    mg.keyreleased(key)   
end

function love.mousepressed(x, y, button)
    mg.mousepressed(button) 
end

function love.mousereleased(x, y, button)
    mg.mousereleased(button) 
end

function love.run()
    math.randomseed(os.time())
    math.random() math.random()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.event then love.event.pump() end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end
    mg.run()
end
