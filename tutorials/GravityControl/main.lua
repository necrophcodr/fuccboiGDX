function love.load()
    mg = require 'mogamett/mogamett'

    require 'Rock'

    mg.init()

    rocks = {love.graphics.newImage('rock_1.png'), love.graphics.newImage('rock_2.png'), 
             love.graphics.newImage('rock_3.png'), love.graphics.newImage('rock_4.png')}

    mg.debug_draw = false
    mg.world.camera:zoomTo(2)

    for i = 1, 150 do
        mg.world:createEntity('Rock', mg.utils.math.random(200, 600), mg.utils.math.random(100, 500), {w = 8, h = 8})
    end

    mg.input:bind('mouse1', 'attract')
    mg.input:bind('mouse2', 'repulse')
    mg.input:bind('p', 'pause')
    paused = false
    love.mouse.setVisible(false)
end

function love.update(dt)
    if mg.input:pressed('pause') then paused = not paused end
    if paused then return end
    mg.update(dt)
end

function love.draw()
    mg.draw()
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
