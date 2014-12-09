local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Tilemap = Class:extend()

function Tilemap:tilemapNew()

end

function Tilemap:createTiledMapEntities(tilemap)
    for _, object in ipairs(tilemap.objects) do
        if object.type == 'Solid' then
            self:createEntity('Solid', object.x + tilemap.x - tilemap.w/2 + object.width/2, 
                              object.y + tilemap.y - tilemap.h/2 + object.height/2,
                             {body_type = 'static', w = object.width, h = object.height})
        else
            local settings = {}
            settings.name = object.name
            settings.shape = object.shape
            settings.width, settings.height = object.width, object.height
            settings.rotation = object.rotation
            settings.visible = object.visible
            for k, v in pairs(object.properties) do settings[k] = v end
            self:createEntity(object.type, object.x + tilemap.x - tilemap.w/2 + object.width/2, 
                              object.y + tilemap.y - tilemap.w/2 + object.height/2, settings) 
        end
    end
end

function Tilemap:generateCollisionSolids(tilemap)
    -- New solid_grid copy to be marked over
    local solid_grid = {}
    for i = 1, #tilemap.solid_grid do
            solid_grid[i] = {}
        for j = 1, #tilemap.solid_grid[i] do
            solid_grid[i][j] = tilemap.solid_grid[i][j]
        end
    end

    -- Returns x, y's neighbors' solid values (1, nil)
    local getNeighbors = function(x, y)
        local left, right, up, down = nil, nil, nil, nil
        local neighbors = {}
        local w, h = #solid_grid[1], #solid_grid
        if x > 1 then neighbors.left = solid_grid[y][x-1] end
        if x < w then neighbors.right = solid_grid[y][x+1] end
        if y > 1 then neighbors.up = solid_grid[y-1][x] end
        if y < h then neighbors.down = solid_grid[y+1][x] end
        return neighbors
    end

    -- Finds corners from which to start the solidification from
    local findCorners = function()
        local corners = {}
        for i = 1, #solid_grid do
            for j = 1, #solid_grid[i] do
                if solid_grid[i][j] == 1 then
                    local n = getNeighbors(j, i)
                    for k, v in pairs(n) do if v == 0 or v == 100 then n[k] = nil end end
                    local direction = nil 
                    if n.right and n.down and not n.up and not n.left then direction = 'left up' end
                    if n.left and n.down and not n.up and not n.right then direction = 'right up' end
                    if n.right and n.up and not n.down and not n.left then direction = 'left down' end
                    if n.left and n.up and not n.down and not n.right then direction = 'right down' end
                    if n.left and not n.up and not n.down and not n.right then direction = 'right' end
                    if n.right and not n.up and not n.down and not n.left then direction = 'left' end
                    if n.up and not n.right and not n.down and not n.left then direction = 'down' end
                    if n.down and not n.right and not n.up and not n.left then direction = 'up' end
                    if direction then table.insert(corners, {x = j, y = i, direction = direction}) end
                end
            end
        end
        return corners
    end

    -- From x, y, finds the tile right before the first 0 or nil on a straight horizontal line to the right
    local findEndTile = function(x, y, direction)
        local current_tile = solid_grid[y][x]
        local i = 0
        if direction == 'right' or direction == 'left' then
            while current_tile == 1 do
                if direction == 'right' then
                    current_tile = solid_grid[y][x+i]
                elseif direction == 'left' then
                    current_tile = solid_grid[y][x-i]
                end
                i = i + 1
            end
            if direction == 'right' then 
                return x+i-2, y
            elseif direction == 'left' then 
                return x-i+2, y 
            end

        elseif direction == 'up' or direction == 'down' then
            while current_tile == 1 do
                if direction == 'up' then
                    current_tile = solid_grid[y-i][x]
                elseif direction == 'down' then
                    current_tile = solid_grid[y+i][x]
                end
                i = i + 1
            end
            if direction == 'up' then return x, y-i+2
            elseif direction == 'down' then return x, y+i-2 end
        end
    end

    local getNUnfilled = function()
        local r = 0
        for i = 1, #solid_grid do
            for j = 1, #solid_grid[i] do
                if solid_grid[i][j] == 1 then
                    r = r + 1
                end
            end
        end
        return r
    end

    -- Finds all corners and fills up rectangles starting from those corners...
    -- The way the rectangle are filled is not random but doesn't behave as I expected it would,
    -- meaning it's not optimal rectangle placing
    local rectangles = {}
    while #findCorners() > 0 do
        local corners = findCorners()
        for _, corner in ipairs(corners) do
            -- Marked tiles = 100
            if solid_grid[corner.y][corner.x] ~= 100 then

                local direction = nil
                if corner.direction == 'left up' then direction = 'right' 
                elseif corner.direction == 'right up' then direction = 'left' end
                if corner.direction == 'left down' then direction = 'right'
                elseif corner.direction == 'right down' then direction = 'left' end
                if corner.direction == 'left' then direction = 'right'
                elseif corner.direction == 'right' then direction = 'left' end
                if corner.direction == 'up' then direction = 'down'
                elseif corner.direction == 'down' then direction = 'up' end

                -- Fills a rectangle right/left and down
                if corner.direction == 'left up' or corner.direction == 'right up' then
                    local x1, y1 = findEndTile(corner.x, corner.y, direction)
                    local x2, y2 = findEndTile(corner.x, corner.y+1, direction)
                    local i = 0
                    local move = (x2 == x1) 
                    while move and y2 < #solid_grid and solid_grid[corner.y+1+i][corner.x] ~= 100 and solid_grid[corner.y+1+i][corner.x] ~= 0 do
                        local x_, y_ = findEndTile(corner.x, corner.y+1+i, direction)
                        if x_ ~= x1 then move = false 
                        else x2, y2 = x_, y_ end
                        i = i + 1
                    end

                    solid_grid[corner.y][corner.x] = 100
                    local increment = 1
                    if direction == 'left' then increment = -1 end
                    if i == 0 then 
                        for i = corner.x, x1, increment do solid_grid[corner.y][i] = 100 end
                        table.insert(rectangles, {x1 = corner.x, y1 = corner.y, x2 = x1, y2 = y1})
                    else 
                        for i = corner.x, x2, increment do
                            for j = corner.y, y2, 1 do
                                solid_grid[j][i] = 100
                            end
                        end
                        table.insert(rectangles, {x1 = corner.x, y1 = corner.y, x2 = x2, y2 = y2})
                    end

                -- Fills a rectangle right/left and up
                elseif corner.direction == 'left down' or corner.direction == 'right down' then
                    local x1, y1 = findEndTile(corner.x, corner.y, direction)
                    local x2, y2 = findEndTile(corner.x, corner.y-1, direction)
                    local i = 0
                    local move = (x2 == x1) 
                    while move and y2 > 1 and solid_grid[corner.y-1-i][corner.x] ~= 100 and solid_grid[corner.y-1-i][corner.x] ~= 0 do
                        local x_, y_ = findEndTile(corner.x, corner.y-1-i, direction)
                        if x_ ~= x1 then move = false
                        else x2, y2 = x_, y_ end
                        i = i + 1
                    end

                    solid_grid[corner.y][corner.x] = 100
                    local increment = 1
                    if direction == 'left' then increment = -1 end
                    if i == 0 then 
                        for i = corner.x, x1, increment do solid_grid[corner.y][i] = 100 end
                        table.insert(rectangles, {x1 = corner.x, y1 = corner.y, x2 = x1, y2 = y1})
                    else 
                        for i = corner.x, x2, increment do
                            for j = corner.y, y2, -1 do
                                solid_grid[j][i] = 100
                            end
                        end
                        table.insert(rectangles, {x1 = corner.x, y1 = corner.y, x2 = x2, y2 = y2})
                    end

                -- Fills a rectangle left/right
                elseif corner.direction == 'right' or corner.direction == 'left' then
                    local x1, y1 = findEndTile(corner.x, corner.y, direction)
                    solid_grid[corner.y][corner.x] = 100
                    local increment = 1
                    if direction == 'left' then increment = -1 end
                    for i = corner.x, x1, increment do solid_grid[corner.y][i] = 100 end
                    table.insert(rectangles, {x1 = corner.x, y1 = corner.y, x2 = x1, y2 = y1})

                -- Fills a rectangle up/down
                elseif corner.direction == 'down' or corner.direction == 'up' then
                    local x1, y1 = findEndTile(corner.x, corner.y, direction)
                    solid_grid[corner.y][corner.x] = 100
                    local increment = 1
                    if direction == 'up' then increment = -1 end
                    for i = corner.y, y1, increment do solid_grid[i][corner.x] = 100 end
                    table.insert(rectangles, {x1 = corner.x, y1 = corner.y, x2 = x1, y2 = y1})
                end
            end
        end
    end

    while getNUnfilled() > 0 do
        for i = 1, #solid_grid do
            for j = 1, #solid_grid[i] do
                if solid_grid[i][j] == 1 then
                    solid_grid[i][j] = 100
                    table.insert(rectangles, {x1 = j, y1 = i, x2 = j, y2 = i})
                end
            end
        end
    end

    local mx, my = tilemap.tile_width, tilemap.tile_height
    for _, rectangle in ipairs(rectangles) do
        local ensure = function(v1, v2)
            if v1 < v2 then return v1, v2
            else return v2, v1 end
        end
        local x1, x2 = ensure(rectangle.x1, rectangle.x2)
        local y1, y2 = ensure(rectangle.y1, rectangle.y2)
        local w = (tilemap.x + mx*x2 + mx/2) - (tilemap.x + mx*x1 - mx/2)
        local h = (tilemap.y + my*y2 + my/2) - (tilemap.y + my*y1 - my/2)
        local x = (tilemap.x + mx*x1 - mx) + w/2
        local y = (tilemap.y + my*y1 - my) + h/2
        self:createEntity('Solid', x - tilemap.w/2, y - tilemap.h/2, {body_type = 'static', w = w, h = h})
    end
end

return Tilemap
