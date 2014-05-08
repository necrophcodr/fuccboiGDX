function love.load()
    mm = require 'mogamett/mogamett'
    mm.init('mm')
    mm.world:createEntity('Rectangle', mm.screen_width/2, mm.screen_height/2, {w = 50, h = 50})
end

function love.update(dt)
    mm.update(dt)
end

function love.draw()
    mm.draw() 
end
