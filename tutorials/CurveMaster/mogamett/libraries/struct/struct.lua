-- The problem:
-- Lua has a problem whenever you want to define a C-like struct.
-- For instance, when I want to define a point structure without having 
-- to define a new class I can create a table like so:
--
-- {x = number, y = number}
--
-- And a function that does something to points can use them like this:
--
-- function dist(p1, p2)
--   local dx, dy = p1.x - p2.x, p1.y - p2.y
--   return math.sqrt(dx*dx + dy*dy)
-- end
--
-- The problem with this is that whenever I have to create a new point
-- I have to create a naked table like in line 6 and it feels "loose".
-- There's no indication of what type that table is before I have to
-- read its contents and there's also no feedback when I try to access
-- p1.z on dist, for instance.
--

-- The solution:
-- An ideal solution would allow me to detect access on undefined 
-- fields and to specify a type for the struct I am creating, like this:
--
-- local Point = struct('x', 'y')
-- local p1 = Point(1, 1)       -- OK
-- local p2 = Point(1, 2, 3)    -- error, unknown argument #3
-- p1.x = 3    -- OK
-- print(p1.x) -- OK
-- print(p1.z) -- error, unknown field 'z'
-- p1.w = 1    -- error, unknown field 'w'

local struct = setmetatable({}, {
    __call =
        function(struct_table, ...)
            local fields = {...}

            for _, field in ipairs(fields) do
                if type(field) ~= "string" then error("Struct field names must be strings.") end
            end

            local struct_table = setmetatable({}, {
                __call = 
                    function(struct_table, ...)
                        local params = {...}
                        local instance_table = setmetatable({}, {
                            __index = 
                                function(struct_table, key)
                                    for _, field in ipairs(fields) do
                                        if field == key then return rawget(struct_table, key) end
                                    end
                                    error("Unknown field '" .. key .. "'")
                                end,

                            __newindex =
                                function(struct_table, key, value)
                                    for _, field in ipairs(fields) do
                                        if field == key then 
                                            rawset(struct_table, key, value) 
                                            return
                                        end
                                    end
                                    error("Unknown field '" .. key .. "'")
                                end,

                            __tostring = 
                                function(struct_table)
                                    local result = "("
                                    for _, field in ipairs(fields) do
                                        result = 
                                            result .. field .. "=" ..
                                            tostring(struct_table[field]) .. ", "
                                    end
                                    result = string.sub(result, 1, -3) .. ")"
                                    return result
                                end
                        })

                        for i = 1, table.maxn(params) do
                            if fields[i] then instance_table[fields[i]] = params[i] 
                            else error("Unknown argument #" .. tostring(i)) end 
                        end
                        return instance_table
                    end
            })
            return struct_table
        end
})

return struct
