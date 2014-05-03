collision_table = {}
c = struct('type', 'other', 'physical')

local collision_mask = struct('categories', 'masks')
collision_masks = {}

collision_ignores = {}
collision_ignores['Player'] = {}
collision_ignores['Solid'] = {}
collision_ignores['Projectile'] = {'Player'}
collision_ignores['Item'] = {'Projectile'}
collision_ignores['HPNode'] = {'Solid'}
collision_ignores['AmmoNode'] = {'Solid'}
collision_ignores['Enemy'] = {}

function isSensor(type1, type2)
    local all = {}
    for class_name, _ in pairs(collision_ignores) do
        table.insert(all, class_name)
    end
    local ignored_types = {}
    for _, class_type in ipairs(collision_ignores[type1]) do
        if class_type == 'All' then
            for _, class_name in ipairs(all) do
                table.insert(ignored_types, class_name)
            end
        else table.insert(ignored_types, class_type) end
    end
    for key, _ in pairs(collision_ignores[type1]) do
        if key == 'except' then
            for _, except_type in ipairs(collision_ignores[type1].except) do
                for i = #ignored_types, 1, -1 do
                    if ignored_types[i] == except_type then table.remove(ignored_types, i) end
                end
            end
        end
    end
    if table.contains(ignored_types, type2) then return true else return false end
end

function generateCategoriesMasks()
    local incoming = {}
    local expanded = {}
    local all = {}
    for object_type, _ in pairs(collision_ignores) do
        incoming[object_type] = {}
        expanded[object_type] = {}
        table.insert(all, object_type)
    end
    for object_type, ignore_list in pairs(collision_ignores) do
        for key, ignored_type in pairs(ignore_list) do
            if ignored_type == 'All' then
                for _, all_object_type in ipairs(all) do
                    table.insert(incoming[all_object_type], object_type)
                    table.insert(expanded[object_type], all_object_type)
                end
            elseif type(ignored_type) == 'string' then
                if ignored_type ~= 'All' then
                    table.insert(incoming[ignored_type], object_type)
                    table.insert(expanded[object_type], ignored_type)
                end
            end
            if key == 'except' then
                for _, except_ignored_type in ipairs(ignored_type) do
                    for i, v in ipairs(incoming[except_ignored_type]) do
                        if v == object_type then
                            table.remove(incoming[except_ignored_type], i)
                            break
                        end
                    end
                end
                for _, except_ignored_type in ipairs(ignored_type) do
                    for i, v in ipairs(expanded[object_type]) do
                        if v == except_ignored_type then
                            table.remove(expanded[object_type], i)
                            break
                        end
                    end
                end
            end
        end
    end
    local edge_groups = {}
    for k, v in pairs(incoming) do
        table.sort(v, function(a, b) return string.lower(a) < string.lower(b) end)
    end
    local i = 0
    for k, v in pairs(incoming) do
        local str = ""
        for _, c in ipairs(v) do
            str = str .. c
        end
        if not edge_groups[str] then i = i + 1; edge_groups[str] = {n = i} end
        table.insert(edge_groups[str], k)
    end
    local categories = {}
    for k, _ in pairs(collision_ignores) do
        categories[k] = {}
    end
    for k, v in pairs(edge_groups) do
        for i, c in ipairs(v) do
            categories[c] = v.n
        end
    end
    for k, v in pairs(expanded) do
        local category = {categories[k]}
        local masks = {}
        for _, c in ipairs(v) do
            table.insert(masks, categories[c])
        end
        collision_masks[k] = collision_mask(category, masks)
    end
end

generateCategoriesMasks()
