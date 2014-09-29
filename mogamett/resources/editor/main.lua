require 'mogamett/mogamett'
require 'Editor'

function love.load()
    mg.init()

    editor = Editor()
    mg.Gamestate.registerEvents()
    mg.Gamestate.switch(editor)

    mg.input:bind('f1', function()
        mg.lurker.scan()
        editor = Editor()
    end)
end

function love.update(dt)
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

function love.gamepadpressed(joystick, button)
    mg.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    mg.gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, newvalue)
    mg.gamepadaxis(joystick, axis, newvalue)
end

function love.textinput(text)
    mg.textinput(text)
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
