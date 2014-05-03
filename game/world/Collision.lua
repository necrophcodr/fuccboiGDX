local collision_struct = struct('type1', 'type2', 'action')

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

local function collIsSensor(type1, type2)
    if isSensor(type1, type2) or isSensor(type2, type1) then return true
    else return false end
end

Collision = {
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
    end,

    addCollisionEnter = function(self, type1, type2, action, physical)
        if not collIsSensor(type1, type2) or physical then
            table.insert(self.collisions.on_enter.non_sensor, collision_struct(type1, type2, action))
        else table.insert(self.collisions.on_enter.sensor, collision_struct(type1, type2, action)) end
    end,

    addCollisionExit = function(self, type1, type2, action, physical)
        if not collIsSensor(type1, type2) or physical then
            table.insert(self.collisions.on_exit.non_sensor, collision_struct(type1, type2, action))
        else table.insert(self.collisions.on_exit.sensor, collision_struct(type1, type2, action)) end
    end,

    addCollisionPre = function(self, type1, type2, action, physical)
        if not collIsSensor(type1, type2) or physical then
            table.insert(self.collisions.pre.non_sensor, collision_struct(type1, type2, action))
        else table.insert(self.collisions.pre.sensor, collision_struct(type1, type2, action)) end
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
