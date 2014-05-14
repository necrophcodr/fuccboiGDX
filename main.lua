function love.load()
    mg = require 'mogamett/mogamett'

    require 'Girl'

    mg.init()

    mg.world:createEntity('Girl', 400, 300, {controlled = true})
    for i = 1, 200 do 
        mg.world:createEntity('Girl', mg.utils.math.random(0, 800), mg.utils.math.random(0, 600))
    end
end

function love.update(dt)
    mg.update(dt)
    mg.world:sortRenderOrder(function(a, b) return a.y < b.y end)
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
