local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Pool = Class:extend()

function Pool:new(area, name, size, overflow_rule)
    self.area = area 
    self.name = name
    self.size = size
    self.overflow_rule = string.lower(overflow_rule or 'oldest')

    self.objects = {}
    for i = 1, self.size do
        self.objects[i] = {object = self.area:poolCreateEntity(name, -100000, -100000), in_use = false, last_time = love.timer.getTime()}
    end
end

function Pool:getFirstFreeObject()
    -- Mark object as being use, set its last "get" time and return it
    for i = 1, self.size do
        if not self.objects[i].in_use then
            self.objects[i].in_use = true
            self.objects[i].last_time = love.timer.getTime()
            self.objects[i].object.pool_active = true
            return self.objects[i].object
        end
    end
    -- In case no object is free, use this pool's overflow rule to find (or to not find) an entity
    if self.overflow_rule == 'oldest' then
        local max, j = -100000, 1
        for i = 1, self.size do
            local dt = love.timer.getTime() - self.objects[i].last_time
            if dt > max then max = dt; j = i end
        end
        self.objects[j].last_time = love.timer.getTime()
        self.objects[j].object.pool_active = true
        return self.objects[j].object

    elseif self.overflow_rule == 'random' then
        return self.objects[math.random(1, self.size)].object

    elseif self.overflow_rule == 'distance' then
        local max, j = -100000, 1
        for i = 1, self.size do
            local object = self.objects[i].object
            local c_x, c_y = object.area.world.camera:getWorldCoords(object.area.fg.screen_width/2, object.area.fg.screen_height/2)
            local dx, dy = c_x - object.x, c_y - object.y
            local d = dx*dx + dy*dy
            if d > max then max = d; j = i end
        end
        self.objects[j].last_time = love.timer.getTime()
        self.objects[j].object.pool_active = true
        return self.objects[j].object

    elseif self.overflow_rule == 'never' then end
end

function Pool:unsetObject(object)
    -- Free object and call its unset function
    for i = 1, self.size do
        if object.id == self.objects[i].object.id then
            self.objects[i].in_use = false
            self.objects[i].object.pool_active = false
            self.objects[i].object.dead = false
            -- If has unset function, call it
            if self.objects[i].object.unset then
                self.objects[i].object:unset()
            -- Otherwise use default unset
            else
                self.objects[i].object.x = -100000
                self.objects[i].object.y = -100000
                -- Unset position of all bodies if the object has bodies
                if self.objects[i].object.bodies then
                    for j = 1, #self.objects[i].object.bodies do
                        self.objects[i].object.bodies[j]:setPosition(-100000, -100000)
                    end
                end
            end
            return
        end
    end
end

return Pool
