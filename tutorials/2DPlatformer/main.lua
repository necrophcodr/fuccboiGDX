function love.load()
    mg = require 'mogamett/mogamett'
    
    require 'Player'

    mg.init()

    mg.world.camera:zoomTo(2)
    mg.world.world:setGravity(0, 20*32)
    mg.world:createEntity('Player', 400, 400, {w = 16, h = 28})

    tilemap = mg.Tilemap(400, 420, 32, 32, love.graphics.newImage('tiles.png'), {
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1},
        {1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1},
        {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},
        {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},
        {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    })
    local tile_rule = mg.utils.struct('tile', 'bit_value', 'left', 'right', 'up', 'down')
    tilemap:setAutoTileRules({6, 14, 12, 2, 10, 8, 7, 15, 13, 3, 11, 9})
    tilemap:autoTile()
    mg.world:generateCollisionSolids(tilemap)
    mg.world:addToLayer('Default', tilemap)

    bg_back = love.graphics.newImage('bg_back.png')
    bg_mid = love.graphics.newImage('bg_mid.png')
    mg.world:addLayer('BG1', 0.8)
    mg.world:addToLayer('BG1', mg.Background(-320, 300, bg_back))
    mg.world:addToLayer('BG1', mg.Background(320, 300, bg_back))
    mg.world:addToLayer('BG1', mg.Background(960, 300, bg_back))
    mg.world:addToLayer('BG1', mg.Background(-320, 608, bg_back))
    mg.world:addToLayer('BG1', mg.Background(320, 608, bg_back))
    mg.world:addToLayer('BG1', mg.Background(960, 608, bg_back))
    mg.world:addLayer('BG2', 0.9)
    mg.world:addToLayer('BG2', mg.Background(-320, 320, bg_mid))
    mg.world:addToLayer('BG2', mg.Background(320, 320, bg_mid))
    mg.world:addToLayer('BG2', mg.Background(960, 320, bg_mid))
    mg.world:addToLayer('BG2', mg.Background(-320, 628, bg_mid))
    mg.world:addToLayer('BG2', mg.Background(320, 628, bg_mid))
    mg.world:addToLayer('BG2', mg.Background(960, 628, bg_mid))
    mg.world:setLayerOrder({'BG1', 'BG2', 'Default'})
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

function love.run()
    math.randomseed(os.time())
    math.random() math.random()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.event then love.event.pump() end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end
    mg.run()
end
