local tilemap = {}
tilemap.__index = tilemap

local utils = require (mogamett_path .. '/libraries/mogamett/utils')
local Vector = require (mogamett_path .. '/libraries/hump/vector')

local function new(image, size, x, y, grid)
    local t = {spritebatch = love.graphics.newSpriteBatch(image, 1000), x = x, y = y, tile_size = size, grid = grid}

    local quads = {}
    for j = 1, math.floor(image:getHeight()/size) do
        for i = 1, math.floor(image:getWidth()/size) do
            table.insert(quads, love.graphics.newQuad((i-1)*size, (j-1)*size, size, size, image:getWidth(), image:getHeight()))
        end
    end
    t.quads = quads

    t.solid_grid = {}
    for i = 1, #grid do
        t.solid_grid[i] = {}
        for j = 1, #grid[i] do
            t.solid_grid[i][j] = 0
            if grid[i][j] ~= 0 then
                t.solid_grid[i][j] = 1
            end
        end
    end

    t.spritebatch_id_grid = {} 
    for i = 1, #grid do
        t.spritebatch_id_grid[i] = {}
        for j = 1, #grid[i] do
            if grid[i][j] ~= 0 then
                t.spritebatch_id_grid[i][j] = t.spritebatch:add(t.quads[grid[i][j]], size*(j-1) + x, size*(i-1) + y)
            end
        end
    end

    t.auto_tile_rules = {}
    t.extended_rules = {}

    return setmetatable(t, tilemap)
end

function tilemap:changeTile(n, x, y)
    if not self.quads[n] then return end
    if self.spritebatch_id_grid[x][y] then
        self.spritebatch:set(self.spritebatch_id_grid[x][y], self.quads[n], self.tile_size*(y-1) + self.x, self.tile_size*(x-1) + self.y)
        self.grid[x][y] = n
    else
        self.spritebatch_id_grid[x][y] = self.spritebatch:add(self.quads[n], self.tile_size*(y-1) + self.x, self.tile_size*(x-1) + self.y)
        self.grid[x][y] = n
    end
end

function tilemap:removeTile(x, y)
    self.spritebatch:set(self.spritebatch_id_grid[x][y], 0, 0, 0, 0, 0)
    self.spritebatch_id_grid[x][y] = 0
end

function tilemap:setAutoTileRules(auto_tile_rules, extended_rules)
    self.auto_tile_rules = auto_tile_rules or self.auto_tile_rules
    self.extended_rules = extended_rules or self.extended_rules
end

function tilemap:autoTile(auto_tile_rules, extended_rules)
    self:setAutoTileRules(auto_tile_rules, extended_rules)

    -- Basic auto tiling pass using auto_tile_rules

    local getAutoTileValue = function(x, y)
        local h, w = #self.grid, #self.grid[1]
        local left, right, up, down = nil, nil, nil, nil
        if x-1 >= 1 then left = self.grid[y][x-1] end 
        if x+1 <= w then right = self.grid[y][x+1] end
        if y-1 >= 1 then up = self.grid[y-1][x] end
        if y+1 <= h then down = self.grid[y+1][x] end
        local value = 0
        if left and left ~= 0 then value = value + 8 end
        if right and right ~= 0 then value = value + 2 end
        if up and up ~= 0 then value = value + 1 end
        if down and down ~= 0 then value = value + 4 end
        return value
    end
     
    -- Set bitmask values grid
    local auto_tile_grid = {}
    for i = 1, #self.grid do
        auto_tile_grid[i] = {}
        for j = 1, #self.grid[i] do
            if self.grid[i][j] ~= 0 then
                auto_tile_grid[i][j] = getAutoTileValue(j, i)
            end
        end
    end

    local findTileValueFromAutoTileRules = function(value)
        for i, v in ipairs(self.auto_tile_rules) do
            if v == value then return i end
        end
    end

    -- Set grid values based on auto tiles rules and the temporary bitmask values grid
    for i = 1, #self.grid do
        for j = 1, #self.grid[i] do
            local n = findTileValueFromAutoTileRules(auto_tile_grid[i][j])
            self:changeTile(n, i, j)
        end
    end

    -- Advanced auto tiling pass using extended_rules
    for i = 1, #self.grid do
        for j = 1, #self.grid[i] do
            for _, rule in ipairs(self.extended_rules) do
                if auto_tile_grid[i][j] == rule.bit_value then
                    -- Get information about this tile and its neighborhood
                    local h, w = #self.grid, #self.grid[1]
                    local left, right, up, down = nil, nil, nil, nil
                    if j-1 >= 1 then left = self.grid[i][j-1] end
                    if j+1 <= w then right = self.grid[i][j+1] end
                    if i-1 >= 1 then up = self.grid[i-1][j] end
                    if i+1 <= h then down = self.grid[i+1][j] end

                    -- Check if this tile satisfies the current extended rule
                    local satisfies = {}
                    if utils.logic.equalsAny(left, rule.left or {}) then satisfies.left = true end
                    if utils.logic.equalsAny(right, rule.right or {}) then satisfies.right = true end
                    if utils.logic.equalsAny(up, rule.up or {}) then satisfies.up = true end
                    if utils.logic.equalsAny(down, rule.down or {}) then satisfies.down = true end
                    local rules = {left = rule.left, right = rule.right, up = rule.up, down = rule.down}
                    local satisfied = true
                    for direction, rule_value in pairs(rules) do
                        if rule_value and satisfies[direction] then
                        else satisfied = false end
                    end

                    -- Set the tile if it does
                    if satisfied then self:changeTile(rule.tile, i, j) end
                end
            end
        end
    end
end

function tilemap:draw()
    love.graphics.draw(self.spritebatch, 0, 0)
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
