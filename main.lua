function love.load()
    mg = require 'mogamett/mogamett'
    mg.init()

    love.graphics.setDefaultFilter('linear', 'linear')

    Text = require 'mogamett/libraries/mogamett/text'

    love.window.setMode(1000, 300, {display = 2})

    TextConfig = {
        line_height = 0.8,
        font = love.graphics.newFont('Moon Flower Bold.ttf', 72),

        blue = function(dt, c) love.graphics.setColor(128, 160, 222) end,
        increasingRed = function(dt, c) love.graphics.setColor(c.position*10, 128, 128) end,

        shake = function(dt, c, ...)
            local args = {...}
            local intensity = args[1]
            c.x = c.x + mg.utils.math.random(-intensity, intensity)
            c.y = c.y + mg.utils.math.random(-intensity, intensity)
        end,

        wavyInit = function(c) c.t = 0 end,
        wavy = function(dt, c) 
            c.t = c.t + dt
            c.y = c.y + 100*math.cos(c.position/4 + 4*c.t)*dt
        end,

        randomFadeInit = function(c, ...)
            local args = {...}
            c.a = 255
            local r = mg.utils.math.random(args[1], args[2])
            mg.timer:every(2*r, function()
                mg.timer:tween(r, c, {a = 0}, 'in-out-cubic')
                mg.timer:after(r, function()
                    mg.timer:tween(r, c, {a = 255}, 'in-out-cubic')
                end)
            end)
        end,
        randomFade = function(dt, c)
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(r, g, b, c.a)
        end,

        randomRotationInit = function(c)
            c.r = 0
            local r = mg.utils.math.random(1, 2)
            mg.timer:every(r, function()
                mg.timer:tween(r, c, {r = mg.utils.math.random(-2*math.pi, 2*math.pi)}, 'in-out-cubic')
            end)
        end,

        randomSizesInit = function(c)
            c.sx = 1
            c.sy = 1
            local r = mg.utils.math.random(1, 2)
            mg.timer:every(r, function()
                mg.timer:tween(r, c, {sx = mg.utils.math.random(0.75, 1.5), sy = mg.utils.math.random(0.75, 1.5)}, 'in-out-cubic')
            end)
        end
    }

    text = Text("[[SURFING](wavy; blue) [the [web](randomSizes)[!!!](randomRotation)](shake: 2; increasingRed) EVERY DAY](randomFade: 1, 2)", TextConfig)
end

function love.update(dt)
    mg.update(dt)
    text:update(dt)
end

function love.draw()
    mg.draw()
    text:draw(100, 150)
end
