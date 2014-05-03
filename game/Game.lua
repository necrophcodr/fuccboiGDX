require 'game/world/World'

Game = class('Game')

function Game:init()
    self.paused = false
    love.physics.setMeter(8)
    self.world = love.physics.newWorld(0, 5*8)
    self.current_world = World(self)
end

function Game:update(dt)
    if self.paused then return end
    if self.current_world then self.current_world:update(dt) end
end

function Game:draw()
    if self.current_world then self.current_world:draw() end
end

function Game:resize(w, h)
    if self.current_world then self.current_world:resize(w, h) end
end

function Game:keypressed(key)
    if self.current_world then self.current_world:keypressed(key) end
end

function Game:keyreleased(key)
    if self.current_world then self.current_world:keyreleased(key) end
end

function Game:mousepressed(x, y, button)
    if self.current_world then self.current_world:mousepressed(x, y, button) end
end

function Game:mousereleased(x, y, button)
    if self.current_world then self.current_world:mousereleased(x, y, button) end
end

function Game:gamepadpressed(button)
    if self.current_world then self.current_world:gamepadpressed(button) end
end

function Game:gamepadreleased(button)
    if self.current_world then self.current_world:gamepadreleased(button) end
end
