function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')

    -- Libraries
    class = require 'libraries/middleclass/middleclass'
    require 'libraries/Vector'
    struct = require 'libraries/chrono/struct'
    Camera = require 'libraries/hump/camera'
    GTimer = require 'libraries/hump/timer'
    require 'libraries/TEsound'
    require 'utils'
    profi = require 'libraries/ProFi'

    classes = {}

    -- Data
    require 'game/data/collision'
    require 'game/data/input'
    require 'game/data/visual'
    require 'game/data/groups'
    require 'game/data/sound'
    require 'game/data/music'
    require 'game/data/shaders'

    -- Mixins
    require 'game/mixins/Fader'
    require 'game/mixins/HittableInvulnerable'
    require 'game/mixins/HittableRed'
    require 'game/mixins/Input'
    require 'game/mixins/Movable'
    require 'game/mixins/PhysicsCircle'
    require 'game/mixins/PhysicsRectangle'
    require 'game/mixins/Stats'
    require 'game/mixins/Steerable'
    require 'game/mixins/Timer'
    require 'game/mixins/Visual'
    require 'game/mixins/Particler'
    require 'game/mixins/PhysicsBSGRectangle'
    require 'game/mixins/PhysicsPolygon'
    require 'game/mixins/PhysicsChain'
    require 'game/mixins/Jumper'

    -- Entities
    require 'game/entities/Entity'
    require 'game/entities/Solid'
    require 'game/entities/Player'
    require 'game/entities/Projectile'
    require 'game/entities/Flash'
    require 'game/entities/FlashLine'
    require 'game/entities/Item'
    require 'game/entities/Text'
    require 'game/entities/HPNode'
    require 'game/entities/AmmoNode'
    require 'game/entities/Enemy'

    -- Game 
    require 'game/Game'
    require 'game/Sound'

    -- Menu
    
    -- Main

    initialize()
end

function initialize()
    rng = love.math.newRandomGenerator(os.time())
    for i = 1, 1000 do rng:random() end
    uid = 0
    t = 0
    debug_draw = false 
    camera_follow_player = true
    game_mouse = Vector(0, 0)
    love.mouse.setVisible(false)
    zoom = 3
    mapn = 1
    game_width = love.graphics.getWidth()
    game_height = love.graphics.getHeight()
    timer = GTimer.new()
    game = Game()
    sound = Sound()
end

function love.update(dt)
    game_mouse = Vector(love.mouse.getPosition())
    sound:update(dt)
    t = t + dt
    timer:update(dt)
    game:update(dt)
    if game.current_world then game.current_world.camera:zoomTo(zoom) end
end

function love.draw()
    game:draw()
end

function love.resize(w, h)
    game_width, game_height = w, h
end

function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    game:mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
    if key == 'f1' then
        zoom = 2
        love.window.setMode(640, 480)
        game:resize(640, 480)
    end
    if key == 'f2' then
        zoom = 3
        love.window.setMode(960, 720)
        game:resize(960, 720)
    end
    if key == 'f3' then 
        zoom = 4
        love.window.setMode(1280, 960)
        game:resize(1280, 960)
    end
    game:keypressed(key)
end

function love.keyreleased(key)
    game:keyreleased(key)
end

function love.textinput(text)

end

function love.gamepadpressed(joystick, button)
    -- game:gamepadpressed(button)
end

function love.gamepadreleased(joystick, button)
    -- game:gamepadreleased(button)
end

-- 0.8
--[[
function love.run()
    math.randomseed(os.time())
    math.random(); math.random(); math.random();

    if love.load then love.load(arg) end

    local t = 0
    local dt = 0
    local fixed_dt = 1/60 
    local accumulator = 0

    -- Main loop time
    while true do
        -- Process events
        if love.event then
            love.event.pump()
            for e, a, b, c, d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a, b, c, d)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt

        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
            t = t + fixed_dt
        end

        if love.graphics then
            love.graphics.clear()
            if love.draw then love.draw() end
        end

        if love.timer then love.timer.sleep(0.001) end
        if love.graphics then love.graphics.present() end
    end
end
]]--

-- 0.9
function love.run()
    math.randomseed(os.time())
    math.random() math.random()

    if love.event then love.event.pump() end
    if love.load then love.load(arg) end

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
            if love.update then love.update(fixed_dt) end
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
