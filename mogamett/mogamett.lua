mogamett_path = string.sub(..., 1, -10)

local mm = {}

-- hump
mm.Timer = require (mogamett_path .. '/libraries/mogamett/timer')
mm.timer = mm.Timer.new()
mm.Camera = require (mogamett_path .. '/libraries/hump/camera')
mm.Vector = require (mogamett_path .. '/libraries/hump/vector')
mm.Gamestate = require (mogamett_path .. '/libraries/hump/gamestate')

-- AnAL
mm.Animation = require (mogamett_path .. '/libraries/anal/AnAL')

mm.Tilemap = require (mogamett_path .. '/libraries/mogamett/tilemap')
mm.Text = require (mogamett_path .. '/libraries/mogamett/text')

-- Group
mm.Group = require (mogamett_path .. '/world/Group')

mm.Class = require (mogamett_path .. '/libraries/classic/classic')
-- holds all classes created with the mm.class call
mm.classes = {}
mm.class = function(class_name, ...)
    local args = {...}
    mm.classes[class_name] = mm[args[1]]:extend(class_name)
    return mm.classes[class_name]
end

-- love-loader
mm.Assets = {}
mm.Loader = require (mogamett_path .. '/libraries/love-loader/love-loader')

-- lovebird
mm.lovebird = require (mogamett_path .. '/libraries/lovebird/lovebird')

-- input
mm.Input = require (mogamett_path .. '/libraries/mogamett/input')
mm.input = mm.Input()
mm.keypressed = function(key) mm.input:keypressed(key) end
mm.keyreleased = function(key) mm.input:keyreleased(key) end
mm.mousepressed = function(button) mm.input:mousepressed(button) end
mm.mousereleased = function(button) mm.input:mousereleased(button) end

-- collision, holds global collision data (mostly who should ignore who and callback settings)
mm.Collision = require (mogamett_path .. '/libraries/mogamett/collision')(mm)

-- utils
mm.utils = require (mogamett_path .. '/libraries/mogamett/utils')

-- global
mm.getUID = function()
    mm.uid = mm.uid + 1
    return mm.uid
end

mm.uid = 0
mm.path = nil
mm.debug_draw = true
mm.lovebird_enabled = false
mm.game_width = love.window.getWidth()
mm.game_height = love.window.getHeight()

mm.addCollisionClass = function(class_name, ignores)
    mm.classes[class_name] = {ignores = ignores}
end

-- init
mm.init = function()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    mm.world = mm.World(mm)
    mm.Collision:generateCategoriesMasks()
    mm.game_width = love.window.getWidth()
    mm.game_height = love.window.getHeight()
end

-- world
mm.World = require (mogamett_path .. '/world/World')

-- entity
mm.Background = require (mogamett_path .. '/entities/Background') 
mm.Entity = require (mogamett_path .. '/entities/Entity')
mm.Solid = require (mogamett_path .. '/entities/Solid')
mm.classes['Solid'] = mm.Solid

-- mixin
mm.PhysicsBody = require (mogamett_path .. '/mixins/PhysicsBody')

mm.update = function(dt)
    if mm.lovebird_enabled then mm.lovebird.update() end
    mm.world:update(dt)
    mm.timer:update(dt)
end

mm.draw = function()
    mm.world:draw()
end

mm.run = function()
    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then love.audio.stop() end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt); mm.input:update(dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.window and love.graphics then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

return mm
