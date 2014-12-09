require 'fuccboi/fuccboi'
local Game = require 'Game'

function love.load()
    fg.init()

    game = Game()
    fg.Gamestate.registerEvents()
    fg.Gamestate.switch(game)
end

function love.update(dt)
    fg.update(dt)
end

function love.draw()
    fg.draw()
end

function love.keypressed(key)
    fg.keypressed(key)
end

function love.keyreleased(key)
    fg.keyreleased(key)   
end

function love.mousepressed(x, y, button)
    fg.mousepressed(button) 
end

function love.mousereleased(x, y, button)
    fg.mousereleased(button) 
end

function love.gamepadpressed(joystick, button)
    fg.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    fg.gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, newvalue)
    fg.gamepadaxis(joystick, axis, newvalue)
end

function love.textinput(text)
    fg.textinput(text)
end

function love.resize(w, h)
    fg.resize(w, h)
end

function love.run()
    math.randomseed(os.time())
    math.random() math.random()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.event then love.event.pump() end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end
    fg.run()
end
