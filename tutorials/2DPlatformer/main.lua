function love.load()
    mg = require 'mogamett/mogamett'
    
    require 'Player'

    mg.init()

    mg.world.camera:zoomTo(1)
    mg.world:createEntity('Player', 400, 300, {w = 16, h = 28})

    test = mg.Tilemap(love.graphics.newImage('tiles.png'), 32, 400, 300, {
        {1, 0, 0, 0, 1, 1},
        {1, 1, 0, 1, 1, 1},
        {1, 1, 0, 1, 1, 1},
        {0, 1, 0, 1, 1, 0},
    })

    local tile_rule = mg.utils.struct('tile', 'bit_value', 'left', 'right', 'up', 'down')
    test:setAutoTileRules({6, 14, 12, 2, 10, 8, 7, 15, 13, 3, 11, 9}, {
        tile_rule(13, 15, {1, 2}, {8, 9, 15}, {1, 7}, {8, 11}),
        tile_rule(15, 15, {7, 8, 13}, {2, 3}, {3, 9}, {8, 11}),
        tile_rule(16, 11, {4, 5}, {11, 12, 18}, {1, 7}, nil),
        tile_rule(18, 11, {10, 11, 16}, {5, 6}, {3, 9}, nil),
    })
    test:autoTile()
    mg.world:generateCollisionSolids(test)
end

function love.update(dt)
    mg.update(dt)
end

function love.draw()
    mg.draw()
    test:draw()
end

function love.keypressed(key)
    mg.keypressed(key)
end

function love.keyreleased(key)
    mg.keyreleased(key)   
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
