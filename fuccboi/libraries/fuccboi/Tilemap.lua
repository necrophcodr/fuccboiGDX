local Tilemap = {}
Tilemap.__index = Tilemap

local utils = require (fuccboi_path .. '/libraries/fuccboi/utils')
local Vector = require (fuccboi_path .. '/libraries/hump/vector')

function Tilemap.new(x, y, tile_width, tile_height, tilesets, tile_grid, settings)
    local self = {}
    local settings = settings or {}

    -- Initializes this tilemap to an area so it can be update/drawn if that area is active
    self.area = settings.area or fg.world.areas['Default']

    -- Padding (horizontal and vertical) in pixels between each tile
    self.padding = settings.padding or 0

    -- Top left position of the map
    self.x = x
    self.y = y

    -- Tile width and height, needs to match the size of each tile in the tileset tilesets
    self.tile_width = tile_width
    self.tile_height = tile_height

    -- A single or multiple tilesets
    if type(tilesets) == 'Image' then self.tilesets = {tilesets}
    else self.tilesets = tilesets end

    -- 2D array containing tile data for the map, each element = a tile number
    self.tile_grid = tile_grid 

    -- If input data is from a Tiled map...
    if type(tile_width) == 'string' then
        local tiled_map_path = tile_width 
        self.tiled_data = require(tiled_map_path)

        -- Set tile size
        self.tile_width = self.tiled_data.tilewidth
        self.tile_height = self.tiled_data.tileheight

        -- Set tileset images
        self.tilesets = {}
        for _, tileset in ipairs(self.tiled_data.tilesets) do
            -- Image path starts with .., meaning have to substitute .. for 
            -- whatever is the first directory before a / in tiled_map_path
            if tileset.image:sub(1, 2) == '..' then
                table.insert(self.tilesets, love.graphics.newImage(tiled_map_path:sub(1, 
                             tiled_map_path:find('/')) .. tileset.image:sub(4, -1)))
            -- Already the full path, just use that as it is
            else table.insert(self.tilesets, love.graphics.newImage(tileset.image)) end
        end

        -- Set tile grid
        self.tile_grid = {}
        for i = 1, self.tiled_data.height do
            self.tile_grid[i] = {}
            for j = 1, self.tiled_data.width do
                self.tile_grid[i][j] = 0
            end
        end
        for _, layer in ipairs(self.tiled_data.layers) do
            if layer.type == 'tilelayer' then
                local width, height = layer.width, layer.height
                for i = 1, height do
                    for j = 1, width do
                        if layer.data[(i-1)*width + j] ~= 0 then
                            self.tile_grid[i][j] = layer.data[(i-1)*width + j]
                        end
                    end
                end
            end
        end

        -- Set solid grid
        self.solid_grid = {}
        for _, layer in ipairs(self.tiled_data.layers) do
            if layer.type == 'tilelayer' then
                if layer.properties.collision == "true" then
                    local width, height = layer.width, layer.height
                    for i = 1, height do
                        self.solid_grid[i] = {}
                        for j = 1, width do
                            if layer.data[(i-1)*width + j] ~= 0 then
                                self.solid_grid[i][j] = 1
                            else self.solid_grid[i][j] = 0 end
                        end
                    end
                end
            end
        end

        -- Set objects
        self.objects = {}
        for _, layer in ipairs(self.tiled_data.layers) do
            if layer.type == 'objectgroup' then
                for _, object in ipairs(layer.objects) do
                    table.insert(self.objects, object)
                end
            end
        end
    end

    -- Width and height of the map in terms of pixels
    self.w = #self.tile_grid[1] * self.tile_width
    self.h = #self.tile_grid * self.tile_height

    -- x1, y1, x2, y2 = top left and bottom right corners of the map in terms of pixels/world units
    self.x1 = self.x - self.tile_width * #self.tile_grid[1]/2
    self.y1 = self.y - self.tile_height * #self.tile_grid/2
    self.x2 = self.x + self.tile_width * #self.tile_grid[1]/2
    self.y2 = self.y + self.tile_height * #self.tile_grid/2

    -- How many tiles each tileset has, i.e. {108, 56, 30} means the first tileset has 108 tiles, 
    -- the second has 56 and the third 30
    self.n_tiles_per_tileset = {}
    for _, tileset in ipairs(self.tilesets) do
        local n_tiles = math.floor(tileset:getWidth()/self.tile_width) * 
                        math.floor(tileset:getHeight()/self.tile_height)
        table.insert(self.n_tiles_per_tileset, n_tiles)
    end

    -- One spritebatch is created for each tileset
    self.spritebatches = {}
    for i, tileset in ipairs(self.tilesets) do 
        self.spritebatches[i] = love.graphics.newSpriteBatch(tileset, 1000) 
    end

    -- Each tile from a tileset is divided into quads and accessible via their tile id.
    -- The tile id for an tileset is found out by just counting each tile left -> right, top -> down, 
    -- meaning the top left most tile is 1 and the bottom right most tile is self.n_tiles_per_tileset[n] 
    -- (how many tiles the tileset has), where n is the position of this tileset in the tilesets array.
    self.quads = {}
    for k, tileset in ipairs(self.tilesets) do
        self.quads[k] = {}
        for j = 1, math.floor(tileset:getHeight()/self.tile_height) do
            for i = 1, math.floor(tileset:getWidth()/self.tile_width) do
                table.insert(self.quads[k], 
                             love.graphics.newQuad((i-1)*self.tile_width + self.padding*(i-1),
                            (j-1)*self.tile_height + self.padding*(j-1), self.tile_width, self.tile_height,
                             tileset:getWidth(), tileset:getHeight()))
            end
        end
    end

    -- Solid grid is used for collision data. Any tile that should be a collision is marked with a 1, 
    -- otherwise it's 0. By default any tile at all is assumed to be 1, but this can be changed by 
    -- specifying the solid grid directly through the setCollidionData method.
    --
    -- If not already set from Tiled...
    if not self.solid_grid then
        self.solid_grid = {}
        for i = 1, #self.tile_grid do
            self.solid_grid[i] = {}
            for j = 1, #self.tile_grid[i] do
                self.solid_grid[i][j] = 0
                if self.tile_grid[i][j] ~= 0 then
                    self.solid_grid[i][j] = 1
                end
            end
        end
    end

    -- Holds the ids of all quads added to the spritebatches so that they can be changed and/or deleted.
    -- Similarly to the spritebatches, one table is created for each tileset.
    self.spritebatches_id_grid = {} 
    for k, tileset in ipairs(self.tilesets) do
        local min_tile_id, max_tile_id = self.n_tiles_per_tileset[k-1] or 0, self.n_tiles_per_tileset[k] or 10000
        self.spritebatches_id_grid[k] = {}
        for i = 1, #self.tile_grid do
            self.spritebatches_id_grid[k][i] = {}
            for j = 1, #self.tile_grid[i] do
                if self.tile_grid[i][j] ~= 0 and self.tile_grid[i][j] >= min_tile_id and self.tile_grid[i][j] <= max_tile_id + min_tile_id then
                    self.spritebatches_id_grid[k][i][j] = self.spritebatches[k]:add(
                                                          self.quads[k][self.tile_grid[i][j] - min_tile_id], 
                                                          self.x + self.tile_width*(j-1), 
                                                          self.y + self.tile_height*(i-1))
                end
            end
        end
    end

    -- Auto tile rules and extended rules explained extensively in the documentation...
    self.auto_tile_rules = {}
    self.extended_rules = {}

    return setmetatable(self, Tilemap)
end

function Tilemap:draw()
    for i, tileset in pairs(self.tilesets) do
        love.graphics.draw(self.spritebatches[i], -self.w/2, -self.h/2)
    end
end

function Tilemap:autoTile(auto_tile_rules, extended_rules)
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
        local results = {}
        for i, v in ipairs(self.auto_tile_rules) do
            if v == value then table.insert(results, i) end
        end
        return results[math.random(1, #results)] or 1
    end

    -- Set grid values based on auto tiles rules and the temporary bitmask values grid
    for i = 1, #self.grid do
        for j = 1, #self.grid[i] do
            local n = findTileValueFromAutoTileRules(auto_tile_grid[i][j])
            self:changeTile(i, j, n)
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
                    if satisfied then self:changeTile(i, j, rule.tile) end
                end
            end
        end
    end
end

function Tilemap:changeTile(x, y, n)
    -- From n find which tileset this n belongs to (i.e. if the first tileset has 100 tiles and n = 102, 
    -- then n is referring to the second tile of the second tileset, tileset_index holds the index (position
    -- in the tilesets list) for that second tileset)
    local tileset_index = 1
    for i, x in ipairs(self.n_tiles_per_tileset) do
        if n <= x then tileset_index = i; break end
    end

    -- Change the tile_grid and the relevant spritebatch
    if not self.quads[tileset_index][n] then return end
    if self.spritebatches_id_grid[tileset_index][x][y] then
        self.tile_grid[x][y] = n
        self.spritebatches[tileset_index]:set(self.spritebatches_id_grid[tileset_index][x][y], 
                                             self.quads[tileset_index][n], self.tile_width*(y-1) + self.x, 
                                             self.tile_height*(x-1) + self.y)
    else
        self.tile_grid[x][y] = n
        self.spritebatches_id_grid[tileset_index][x][y] = self.spritebatches[tileset_index]:add(
        self.quads[tileset_index][n], self.tile_width*(y-1) + self.x, self.tile_height*(x-1) + self.y)
    end
end

function Tilemap:removeTile(x, y)
    for i, tileset in ipairs(self.tilesets) do
        self.spritebatches[i]:set(self.spritebatches_id_grid[i][x][y], 0, 0, 0, 0, 0)
        self.spritebatches_id_grid[i][x][y] = 0
    end
end

function Tilemap:setAutoTileRules(auto_tile_rules, extended_rules)
    self.auto_tile_rules = auto_tile_rules or self.auto_tile_rules
    self.extended_rules = extended_rules or self.extended_rules
end

function Tilemap:setCollisionData(data)
    for i = 1, #grid do
        for j = 1, #grid[i] do
            self.solid_grid[i][j] = data[i][j]
        end
    end
end

return setmetatable({new = new}, {__call = function(_, ...) return Tilemap.new(...) end})
