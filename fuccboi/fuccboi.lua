fuccboi_path = string.sub(..., 1, -9)

fg = {}

fg.Timer = require (fuccboi_path .. '/libraries/fuccboi/Timer')
fg.timer = fg.Timer()
fg.Camera = require (fuccboi_path .. '/libraries/hump/camera')
fg.Vector = require (fuccboi_path .. '/libraries/hump/vector')
fg.Gamestate = require (fuccboi_path .. '/libraries/hump/gamestate')
fg.Animation = require (fuccboi_path .. '/libraries/anal/AnAL')
fg.Tilemap = require (fuccboi_path .. '/libraries/fuccboi/Tilemap')
fg.Text = require (fuccboi_path .. '/libraries/fuccboi/Text')
fg.Group = require (fuccboi_path .. '/world/Group')
fg.Object = require (fuccboi_path .. '/libraries/classic/classic')
fg.Sound = require (fuccboi_path .. '/libraries/TEsound/TEsound')
fg.Serial = require (fuccboi_path .. '/libraries/fuccboi/Serial')()

-- holds all classes created with the fg.Class call
fg.classes = {}
fg.Class = function(class_name, ...)
    local args = {...}
    fg.classes[class_name] = (fg[args[1]] or fg.classes[args[1]]):extend(class_name)
    return fg.classes[class_name]
end

fg.moses = require (fuccboi_path .. '/libraries/moses/moses')
fg.fn = fg.moses
fg.mo = fg.moses
fg.mlib = require (fuccboi_path .. '/libraries/mlib/mlib')
fg.Assets = {}
fg.Loader = require (fuccboi_path .. '/libraries/love-loader/love-loader')
fg.lovebird = require (fuccboi_path .. '/libraries/lovebird/lovebird')
require(string.gsub(fuccboi_path, '/', '.') .. '.libraries.loveframes')
fg.loveframes = loveframes

fg.Input = require (fuccboi_path .. '/libraries/fuccboi/Input')
fg.input = fg.Input()

fg.textinput = function(text)
    fg.loveframes.textinput(text)
end

fg.keypressed = function(key) 
    fg.input:keypressed(key) 
    fg.loveframes.keypressed(key)
end

fg.keyreleased = function(key) 
    fg.input:keyreleased(key) 
    fg.loveframes.keyreleased(key)
end

fg.mousepressed = function(button) 
    fg.input:mousepressed(button) 
    local x, y = love.mouse.getPosition()
    fg.loveframes.mousepressed(x, y, button)
end

fg.mousereleased = function(button) 
    fg.input:mousereleased(button) 
    local x, y = love.mouse.getPosition()
    fg.loveframes.mousereleased(x, y, button)
end

fg.gamepadpressed = function(joystick, button) fg.input:gamepadpressed(joystick, button) end
fg.gamepadreleased = function(joystick, button) fg.input:gamepadreleased(joystick, button) end
fg.gamepadaxis = function(joystick, axis, newvalue) fg.input:gamepadaxis(joystick, axis, newvalue) end

-- collision, holds global collision data (mostly who should ignore who and callback settings)
fg.Collision = require (fuccboi_path .. '/libraries/fuccboi/Collision')(fg)

-- utils
fg.utils = require (fuccboi_path .. '/libraries/fuccboi/utils')

fg.getUID = function()
    fg.uid = fg.uid + 1
    return fg.uid
end

fg.uid = 0
fg.path = nil
fg.debug_draw = true
fg.lovebird_enabled = false
fg.min_width = 480
fg.min_height = 360
fg.screen_width = fg.min_wdith
fg.screen_height = fg.min_height
fg.screen_scale = 1

-- init
fg.init = function()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    fg.screen_width = fg.min_width
    fg.screen_heigth = fg.min_height
    love.window.setMode(fg.screen_width, fg.screen_height, {resizable = true})
    fg.world = fg.World(fg)
    fg.Collision:generateCategoriesMasks()
end

fg.setScreenSize = function(w, h)
    love.window.setMode(w, h, {resizable = true})
    fg.resize(w, h)
end

fg.resize = function(w, h)
    fg.screen_scale = math.min(w/fg.min_width, h/fg.min_height)
    fg.screen_width = w
    fg.screen_height = h
    fg.world:resize(w, h)
end

-- world
fg.World = require (fuccboi_path .. '/world/World')

-- entity
fg.Background = require (fuccboi_path .. '/entities/Background') 
fg.Entity = require (fuccboi_path .. '/entities/Entity')
fg.Solid = require (fuccboi_path .. '/entities/Solid')
fg.classes['Solid'] = fg.Solid
fg.Spritebatch = require (fuccboi_path .. '/entities/Spritebatch')
fg.Spritebatches = {}
fg.Shaders = {}

-- mixin
fg.PhysicsBody = require (fuccboi_path .. '/mixins/PhysicsBody')

fg.update = function(dt)
    fg.Sound.cleanup()
    if fg.lovebird_enabled then fg.lovebird.update() end
    fg.loveframes.update(dt)
    fg.Collision:generateCategoriesMasks()
    for k, s in pairs(fg.Spritebatches) do s:update(dt) end
    fg.timer:update(dt)
    fg.world:update(dt)
end

fg.draw = function()
    fg.world:draw()
    fg.loveframes.draw()
end

fg.run = function()
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
            if love.update then love.update(fixed_dt); fg.input:update(dt) end
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

return fg
