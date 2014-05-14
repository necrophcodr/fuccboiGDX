mogamett_path = string.sub(..., 1, -10)

local mm = {}

-- hump
mm.Timer = require (mogamett_path .. '/libraries/mogamett/timer')
mm.timer = mm.Timer.new()
mm.Camera = require (mogamett_path .. '/libraries/hump/camera')
mm.Vector = require (mogamett_path .. '/libraries/hump/vector')

-- AnAL
mm.Animation = require (mogamett_path .. '/libraries/anal/AnAL')

-- struct
mm.Struct = require (mogamett_path .. '/libraries/struct/struct')

-- Group
mm.Group = require (mogamett_path .. '/world/Group')

-- middleclass 
mm.Class = require (mogamett_path .. '/libraries/middleclass/middleclass')
-- holds all classes created with the mm.class call
mm.classes = {}
mm.class = function(class_name, ...)
    mm.classes[class_name] = mm.Class(class_name, ...)
    return mm.classes[class_name]
end

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
mm.Entity = require (mogamett_path .. '/entities/Entity')

-- mixin
mm.PhysicsBody = require (mogamett_path .. '/mixins/PhysicsBody')

mm.update = function(dt)
    if mm.lovebird_enabled then mm.lovebird.update() end
    mm.world:update(dt)
    mm.input:update(dt)
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
