local function collEnsure(class_name1, a, class_name2, b)
    if a.class.name == class_name2 and b.class.name == class_name1 then return b, a
    else return a, b end
end

local function collIf(class_name1, class_name2, a, b)
    if (a.class.name == class_name1 and b.class.name == class_name2) or
       (a.class.name == class_name2 and b.class.name == class_name1) then
       return true
    else return false end
end

local Collision = {
    collisionInit = function(self)
        self.collisions = {}
        self.collisions.on_enter = {}
        self.collisions.on_enter.sensor = {}
        self.collisions.on_enter.non_sensor = {}
        self.collisions.on_exit = {}
        self.collisions.on_exit.sensor = {}
        self.collisions.on_exit.non_sensor = {}
        self.collisions.pre = {}
        self.collisions.pre.sensor = {}
        self.collisions.pre.non_sensor = {}
        self.collisions.post = {}
        self.collisions.post.sensor = {}
        self.collisions.post.non_sensor = {}
    end,

    isSensor = function(type1, type2)
        local collision_ignores = {}
        for class_name, class in pairs(self.mg.classes) do
            collision_ignores[class_name] = class.static.ignores or {}
        end
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
    end,

    collIsSensor = function(type1, type2)
        if self:isSensor(type1, type2) or self:isSensor(type2, type1) then return true
        else return false end
    end,

    addCollisionEnter = function(self, type1, type2, action, physical)
        if not self:collIsSensor(type1, type2) or physical then
            table.insert(self.collisions.on_enter.non_sensor, {type1 = type1, type2 = type2, action = action})
        else table.insert(self.collisions.on_enter.sensor, {type1 = type1, type2 = type2, action = action}) end
    end,

    addCollisionExit = function(self, type1, type2, action, physical)
        if not self:collIsSensor(type1, type2) or physical then
            table.insert(self.collisions.on_exit.non_sensor, {type1 = type1, type2 = type2, action = action})
        else table.insert(self.collisions.on_exit.sensor, {type1 = type1, type2 = type2, action = action}) end
    end,

    addCollisionPre = function(self, type1, type2, action, physical)
        if not self:collIsSensor(type1, type2) or physical then
            table.insert(self.collisions.pre.non_sensor, {type1 = type1, type2 = type2, action = action})
        else table.insert(self.collisions.pre.sensor, {type1 = type1, type2 = type2, action = action}) end
    end,

    addCollisionPost = function(self, type1, type2, action, physical)
        if not self:collIsSensor(type1, type2) or physical then
            table.insert(self.collisions.post.non_sensor, {type1 = type1, type2 = type2, action = action})
        else table.insert(self.collisions.post.sensor, {type1 = type1, type2 = type2, action = action}) end
    end,

    collisionPre = function(fixture_a, fixture_b, contact)
        local a, b = fixture_a:getUserData(), fixture_b:getUserData()
        local nx, ny = contact:getNormal()

        if fixture_a:isSensor() and fixture_b:isSensor() then
            if a and b then
                for _, collision in ipairs(a.world.collisions.pre.sensor) do
                    if collIf(collision.type1, collision.type2, a, b) then
                        a, b = collEnsure(collision.type1, a, collision.type2, b)
                        a[collision.action](a, 'pre', b, nx, ny, contact)
                    end
                end
            end

        elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
            if a and b then
                for _, collision in ipairs(a.world.collisions.pre.non_sensor) do
                    if collIf(collision.type1, collision.type2, a, b) then
                        a, b = collEnsure(collision.type1, a, collision.type2, b)
                        a[collision.action](a, 'pre', b, nx, ny, contact, true)
                    end
                end
            end
        end
    end,

    collisionPost = function(fixture_a, fixture_b, contact)
        local a, b = fixture_a:getUserData(), fixture_b:getUserData()
        local nx, ny = contact:getNormal()

        if fixture_a:isSensor() and fixture_b:isSensor() then
            if a and b then
                for _, collision in ipairs(a.world.collisions.post.sensor) do
                    if collIf(collision.type1, collision.type2, a, b) then
                        a, b = collEnsure(collision.type1, a, collision.type2, b)
                        a[collision.action](a, 'post', b, nx, ny, contact)
                    end
                end
            end

        elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
            if a and b then
                for _, collision in ipairs(a.world.collisions.post.non_sensor) do
                    if collIf(collision.type1, collision.type2, a, b) then
                        a, b = collEnsure(collision.type1, a, collision.type2, b)
                        a[collision.action](a, 'post', b, nx, ny, contact, true)
                    end
                end
            end
        end
    end,

    collisionOnEnter = function(fixture_a, fixture_b, contact)
        local a, b = fixture_a:getUserData(), fixture_b:getUserData()
        local nx, ny = contact:getNormal()
        
        if fixture_a:isSensor() and fixture_b:isSensor() then
            if a and b then
                for _, collision in ipairs(a.world.collisions.on_enter.sensor) do
                    if collIf(collision.type1, collision.type2, a, b) then
                        a, b = collEnsure(collision.type1, a, collision.type2, b)
                        a[collision.action](a, 'enter', b, nx, ny, contact)
                    end
                end
            end

        elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
            if a and b then
                for _, collision in ipairs(a.world.collisions.on_enter.non_sensor) do
                    if collIf(collision.type1, collision.type2, a, b) then
                        a, b = collEnsure(collision.type1, a, collision.type2, b)
                        a[collision.action](a, 'enter', b, nx, ny, contact, true)
                    end
                end
            end
        end
    end,

    collisionOnExit = function(fixture_a, fixture_b, contact)
        local a, b = fixture_a:getUserData(), fixture_b:getUserData()
        local nx, ny = contact:getNormal()

        if fixture_a:isSensor() and fixture_b:isSensor() then
            if a and b then
                for _, collision in ipairs(a.world.collisions.on_exit.sensor) do
                    if collIf(collision.type1, collision.type2, a, b) then
                        a, b = collEnsure(collision.type1, a, collision.type2, b)
                        a[collision.action](a, 'exit', b, nx, ny, contact)
                    end
                end
            end

        elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
            if a and b then
                for _, collision in ipairs(a.world.collisions.on_exit.non_sensor) do
                    if collIf(collision.type1, collision.type2, a, b) then
                        a, b = collEnsure(collision.type1, a, collision.type2, b)
                        a[collision.action](a, 'exit', b, nx, ny, contact, true)
                    end
                end
            end
        end
    end
}

return Collision
