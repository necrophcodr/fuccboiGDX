classes['Item'] = class('Item', Entity); local Item = classes['Item']
Item:include(PhysicsRectangle)
Item:include(Particler)

function Item:init(world, x, y, settings)
    Entity.init(self, world, x, y, settings)
    self:physicsRectangleInit(self.world.world, x, y, 'dynamic', 8, 8)
    self:particlerInit()
    if self.name == 'HP' then self:particlerSpawn('HP', self.x, self.y, {parent = self})
    elseif self.name == 'Mana' then self:particlerSpawn('Mana', self.x, self.y, {parent = self})
    else self:particlerSpawn('Item', self.x, self.y, {parent = self}) end
end

function Item:update(dt)
    self.x, self.y = self.body:getPosition()
    self:particlerUpdate(dt)
end

function Item:draw()
    self:physicsRectangleDraw()
    self:particlerDraw()
end

function Item:activate(object)
    if self.name == 'linumllum' then
        object.pistol = true
        object.world:createToGroup('Text', object.x, object.y + 5, {text = 'linumllum'}) 
        object.world:createToGroup('Text', object.x, object.y + 15, {text = 'left click to use'}) 
    elseif self.name == 'byggllum' then
        if object.bigger_lights then object.bigger_lights = object.bigger_lights + 1
        else object.bigger_lights = 1 end
        object.world:createToGroup('Text', object.x, object.y + 5, {text = 'byggllum'}) 
        object.world:createToGroup('Text', object.x, object.y + 15, {text = 'bigger lights'}) 
    elseif self.name == 'haereollum' then
        object.sticky_light = true
        object.world:createToGroup('Text', object.x, object.y + 5, {text = 'haereollum'}) 
        object.world:createToGroup('Text', object.x, object.y + 15, {text = 'sticky lights'}) 
        object.world:createToGroup('Text', object.x, object.y + 25, {text = 'longer light duration'}) 
    elseif self.name == 'llumkir' then
        if object.laser_light then object.laser_light = object.laser_light + 1
        else object.laser_light = 1 end
        object.world:createToGroup('Text', object.x, object.y + 5, {text = 'llumkir'}) 
        object.world:createToGroup('Text', object.x, object.y + 15, {text = 'chance lights attack'}) 

    elseif self.name == 'HP' then
        object.world:createToGroup('Text', object.x, object.y + 5, {text = '+1hp'}) 
        object.world:createToGroup('HPNode', object.x, object.y)
        object.hp = object.hp + 1
    elseif self.name == 'Mana' then
        object.world:createToGroup('Text', object.x, object.y + 5, {text = '+1mana'}) 
        object.world:createToGroup('AmmoNode', object.x, object.y)
        object.ammo = object.ammo + 1
    end
    self.dead = true
end
