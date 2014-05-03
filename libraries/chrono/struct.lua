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
