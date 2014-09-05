mogamett_path = string.sub(..., 1, -10)

mg = {}

-- hump
mg.Timer = require (mogamett_path .. '/libraries/mogamett/timer')
mg.timer = mg.Timer.new()
mg.Camera = require (mogamett_path .. '/libraries/hump/camera')
mg.Vector = require (mogamett_path .. '/libraries/hump/vector')
mg.Gamestate = require (mogamett_path .. '/libraries/hump/gamestate')

-- AnAL
mg.Animation = require (mogamett_path .. '/libraries/anal/AnAL')

mg.Tilemap = require (mogamett_path .. '/libraries/mogamett/tilemap')
mg.Text = require (mogamett_path .. '/libraries/mogamett/text')

-- Group
mg.Group = require (mogamett_path .. '/world/Group')

mg.Class = require (mogamett_path .. '/libraries/classic/classic')
-- holds all classes created with the mg.class call
mg.classes = {}
mg.class = function(class_name, ...)
    local args = {...}
    mg.classes[class_name] = (mg[args[1]] or mg.classes[args[1]]):extend(class_name)
    return mg.classes[class_name]
end

-- moses
mg.moses = require (mogamett_path .. '/libraries/moses/moses')
mg.fn = mg.moses
mg.mo = mg.moses

-- love-loader
mg.Assets = {}
mg.Loader = require (mogamett_path .. '/libraries/love-loader/love-loader')

-- lovebird
mg.lovebird = require (mogamett_path .. '/libraries/lovebird/lovebird')

-- lurker
mg.lurker = require (mogamett_path .. '/libraries/lurker/lurker')

-- UI
require(string.gsub(mogamett_path, '/', '.') .. '.libraries.loveframes')
mg.loveframes = loveframes

-- input
mg.Input = require (mogamett_path .. '/libraries/mogamett/input')
mg.input = mg.Input()
mg.textinput = function(text)
    mg.loveframes.textinput(text)
end
mg.keypressed = function(key) 
    mg.input:keypressed(key) 
    mg.loveframes.keypressed(key)
end
mg.keyreleased = function(key) 
    mg.input:keyreleased(key) 
    mg.loveframes.keyreleased(key)
end
mg.mousepressed = function(button) 
    mg.input:mousepressed(button) 
    local x, y = love.mouse.getPosition()
    mg.loveframes.mousepressed(x, y, button)
end
mg.mousereleased = function(button) 
    mg.input:mousereleased(button) 
    local x, y = love.mouse.getPosition()
    mg.loveframes.mousereleased(x, y, button)
end
mg.gamepadpressed = function(joystick, button) mg.input:gamepadpressed(joystick, button) end
mg.gamepadreleased = function(joystick, button) mg.input:gamepadreleased(joystick, button) end
mg.gamepadaxis = function(joystick, axis, newvalue) mg.input:gamepadaxis(joystick, axis, newvalue) end

-- collision, holds global collision data (mostly who should ignore who and callback settings)
mg.Collision = require (mogamett_path .. '/libraries/mogamett/collision')(mg)

-- utils
mg.utils = require (mogamett_path .. '/libraries/mogamett/utils')

-- global
mg.getUID = function()
    mg.uid = mg.uid + 1
    return mg.uid
end

mg.uid = 0
mg.path = nil
mg.debug_draw = true
mg.lovebird_enabled = false
mg.lurker_enabled = false
mg.min_width = 480
mg.min_height = 360
mg.screen_width = mg.min_wdith
mg.screen_height = mg.min_height
mg.screen_scale = 1

-- init
mg.init = function()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    mg.screen_width = mg.min_width
    mg.screen_heigth = mg.min_height
    love.window.setMode(mg.screen_width, mg.screen_height, {resizable = true})
    mg.world = mg.World(mg)
end

mg.setScreenSize = function(w, h)
    love.window.setMode(w, h, {resizable = true})
    mg.resize(w, h)
end

mg.resize = function(w, h)
    mg.screen_scale = math.min(w/mg.min_width, h/mg.min_height)
    mg.screen_width = w
    mg.screen_height = h
    mg.world:resize(w, h)
end

-- world
mg.World = require (mogamett_path .. '/world/World')

-- entity
mg.Background = require (mogamett_path .. '/entities/Background') 
mg.Entity = require (mogamett_path .. '/entities/Entity')
mg.Solid = require (mogamett_path .. '/entities/Solid')
mg.classes['Solid'] = mg.Solid
mg.Spritebatch = require (mogamett_path .. '/entities/Spritebatch')
mg.Spritebatches = {}
mg.Shaders = {}

-- mixin
mg.PhysicsBody = require (mogamett_path .. '/mixins/PhysicsBody')

mg.update = function(dt)
    if mg.lovebird_enabled then mg.lovebird.update() end
    mg.loveframes.update(dt)
    mg.Collision:generateCategoriesMasks()
    for k, s in pairs(mg.Spritebatches) do s:update(dt) end
    mg.world:update(dt)
    mg.timer:update(dt)
end

mg.draw = function()
    mg.world:draw()
    mg.loveframes.draw()
end

mg.run = function()
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
            if love.update then love.update(fixed_dt); mg.input:update(dt) end
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

return mg
