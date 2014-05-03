Render = {
    renderInit = function(self)
        self.camera = Camera()
        self.camera_v = Vector(0, 0)
        self.camera_v_multiplier = 0.2
        self.game_width = game_width
        self.game_height = game_height
        self.out_follow = nil
        self.bounds = {x1 = 0, y1 = 0, x2 = self.game_width, y2 = self.game_height}

        self.canvas_1 = love.graphics.newCanvas(4*game_width, 4*game_height)
        self.canvas_2 = love.graphics.newCanvas(4*game_width, 4*game_height)
        self.canvas_3 = love.graphics.newCanvas(4*game_width, 4*game_height)
        self.heavybloom = love.graphics.newShader("game/data/shaders/heavybloom.frag", "game/data/shaders/default.vert")
        self.heavybloom:send('textureSize', {100*zoom, 100*zoom})
        self.phosphor = love.graphics.newShader("game/data/shaders/phosphor.frag", "game/data/shaders/default.vert")
        self.phosphor:send('textureSize', {800*zoom, 800*zoom})

        self.keys_alpha = 0
        self.keys_text = 'click, A, D, space'
        self.arrow_alpha = 0
        self.arrow_text = '----->'
        self.survive_text = 'survive'
        self.first_click = false
        timer:tween(5, self, {keys_alpha = 255}, 'in-out-cubic')
        timer:after(5, function() timer:tween(20, self, {keys_alpha = 0}, 'in-out-cubic') end)
        self.sanity = false
        self.sanity_alpha = 0
        self.sanity_text = 'the depths are dark and full of terrors'
        self.hp_alpha = 0
        self.hp_text = '<-hp'
        self.ammo_text = '->mana'
        self.arrow_alpha_2 = 0
        self.keep_going = false
        self.hp_ammo = false
        self.depth = 0 
        self.player_dead = false
        self.can_restart_click = false
        self.dead_alpha = 0
        self.dead_text = 'you died, click to restart'
    end,

    renderUpdate = function(self, dt, follow)
        -- Camera movement, follows follow
        if self.out_follow and not follow then
            self.camera:move(0.08*self.out_follow.x*self.camera_v_multiplier, 0.08*self.out_follow.y*self.camera_v_multiplier)
        elseif follow  then
            local x, y = self.camera:pos()
            self.camera_v = Vector(follow.x - x, follow.y - y)
            self.camera:move(self.camera_v.x*self.camera_v_multiplier, self.camera_v.y*self.camera_v_multiplier)
        end

        -- Bounds + center
        self.bounds = {x1 = 200, y1 = 100, 
                       x2 = 1800, y2 = 140}
        local x, y = self.camera:pos()
        x = math.bounds(x, self.bounds.x1, self.bounds.x2)
        y = math.bounds(y, self.bounds.y1, self.bounds.y2)
        self.camera:lookAt(x, y)

        if self.player.x > 500 then 
            if not self.sanity then
                self.sanity = true 
                timer:after(4, function() self.hp_ammo = true end)
                for i = 1, self.player.max_hp do self:createToGroup('HPNode', self.player.x, -500) end
                for i = 1, self.player.max_ammo do self:createToGroup('AmmoNode', self.player.x, -500) end
                self:createToGroup('Flash', 0, 0, {follow_camera_left = true, size = 60, permanent = true})
                self:createToGroup('Flash', 0, 0, {follow_camera_right = true, size = 60, permanent = true})
                timer:tween(4, self, {sanity_alpha = 255}, 'in-out-cubic')
                timer:after(4, function() timer:tween(16, self, {sanity_alpha = 0}, 'in-out-cubic') end)
                timer:after(2, function() timer:tween(4, self, {hp_alpha = 255}, 'in-out-cubic') end)
                timer:after(14, function() timer:tween(4, self, {hp_alpha = 0}, 'in-out-cubic') end)
            end
        end
         if self.player.x > 800 then
            if not self.keep_going then
                 self.keep_going = true
                 timer:tween(2, self, {arrow_alpha_2 = 255}, 'in-out-cubic')
                 timer:after(2, function() timer:tween(20, self, {arrow_alpha_2 = 0}, 'in-out-cubic') end)
            end
        end

        self.depth = (mapn-1)*(1950) + self.player.x
    end,

    renderResize = function(self, w, h)
        game_width = w
        game_height = h
        self.game_width = w 
        self.game_height = h 
        self.canvas_1 = love.graphics.newCanvas(4*game_width, 4*game_height)
        self.canvas_2 = love.graphics.newCanvas(4*game_width, 4*game_height)
        self.canvas_3 = love.graphics.newCanvas(4*game_width, 4*game_height)
        self.heavybloom = love.graphics.newShader("game/data/shaders/heavybloom.frag", "game/data/shaders/default.vert")
        self.heavybloom:send('textureSize', {100*zoom, 100*zoom})
        self.phosphor = love.graphics.newShader("game/data/shaders/phosphor.frag", "game/data/shaders/default.vert")
        self.phosphor:send('textureSize', {800*zoom, 800*zoom})
    end,

    renderAttach = function(self)
        self.camera:attach()
    end,

    renderDetach = function(self)
        self.camera:detach()
    end,

    playerDead = function(self)
        if self.player_dead then return end
        self.player_dead = true
        timer:tween(4, self, {dead_alpha = 255}, 'in-out-cubic')
        timer:after(4, function() self.can_restart_click = true end)
    end,

    renderDraw = function(self)
        self.canvas_1:clear()
        self.canvas_1:renderTo(function()
            self:renderDetach()
            love.graphics.setColor(16, 16, 16)
            love.graphics.rectangle('fill', 0, 0, 2000, 300)
            for _, group_ro in ipairs(groups_render_order) do
                for _, group in ipairs(self.groups) do
                    if group.name == group_ro then
                        group:draw()
                    end
                end
            end
            self:renderAttach()
        end)

        self.canvas_2:clear()
        self.canvas_2:renderTo(function()
            self:renderDetach()
            love.graphics.setShader(self.heavybloom)
            love.graphics.draw(self.canvas_1, 0, 0)
            love.graphics.setShader()
            love.graphics.setColor(255, 255, 255)
            local wx, wy = self.camera:worldCoords(game_mouse.x, game_mouse.y)
            love.graphics.circle('fill', wx, wy, 3)
            self:renderAttach()
        end)

        love.graphics.setShader(self.phosphor)
        love.graphics.draw(self.canvas_2, 0, 0)
        love.graphics.setShader()

        local draw_lights = function()
            local m = 1
            if self.player.bigger_lights then m = 1 + 0.5*self.player.bigger_lights end
            for _, group in ipairs(self.groups) do
                if group.name == 'Projectile' then
                    for _, proj in ipairs(group:getEntities()) do
                        love.graphics.circle('fill', proj.x, proj.y, m*(8*proj.r + math.prandom(-1.5, 1.5)), 24)
                    end
                elseif group.name == 'Flash' then
                    for _, flash in ipairs(group:getEntities()) do
                        if flash.follow_camera_left or flash.follow_camera_right then
                            love.graphics.circle('fill', flash.x, flash.y, flash.r + math.prandom(-1, 1), 24)
                        else
                            love.graphics.circle('fill', flash.x, flash.y, m*(flash.r + math.prandom(-1, 1)), 24)
                        end
                    end
                elseif group.name == 'FlashLine' then
                    for _, fl in ipairs(group:getEntities()) do
                        love.graphics.circle('fill', fl.x1, fl.y1, m*(fl.w + math.prandom(-1.5, 1.5)), 24)
                        love.graphics.setLineWidth(fl.w + math.prandom(-1.5, 1.5))
                        love.graphics.line(fl.x1, fl.y1, fl.x2, fl.y2)
                        love.graphics.setLineWidth(1)
                    end
                elseif group.name == 'Item' then
                    for _, item in ipairs(group:getEntities()) do
                        love.graphics.circle('fill', item.x, item.y - 15, m*(60 + math.prandom(-2, 2)), 24)
                    end
                end
            end
            local wx, wy = self.camera:worldCoords(game_mouse.x, game_mouse.y)
            love.graphics.circle('fill', wx, wy, 5)
        end

        self.canvas_3:clear()
        self.canvas_3:renderTo(function()
            self:renderDetach()
            love.graphics.setInvertedStencil(draw_lights)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle('fill', 0, 0, 4*self.game_width, 4*self.game_height)
            love.graphics.setInvertedStencil()
            love.graphics.setColor(255, 255, 255, 255)
            self:renderAttach()
        end)
        love.graphics.draw(self.canvas_3, 0, 0)

        love.graphics.setFont(small_font)
        love.graphics.setColor(255, 255, 255, self.keys_alpha)
        love.graphics.print(self.keys_text, 60, 60)
        love.graphics.setColor(255, 255, 255, self.arrow_alpha)
        love.graphics.print(self.arrow_text, 300, 60)
        love.graphics.setColor(255, 255, 255, self.sanity_alpha)
        love.graphics.print(self.sanity_text, 500, 60)
        love.graphics.setColor(255, 255, 255, self.hp_alpha)
        local cx, cy = self.camera:pos()
        love.graphics.print(self.hp_text, cx - 95, cy + 105)
        love.graphics.print(self.ammo_text, cx + 65, cy + 105)

        local texts = self:getEntitiesFromGroup('Text')
        for _, text in ipairs(texts) do text:draw() end

        love.graphics.setColor(255, 255, 255, self.arrow_alpha_2)
        love.graphics.print(self.survive_text, 950, 60)

        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(self.arrow_text, 1900, 60)

        local cx, cy = self.camera:pos()
        local w = small_font:getWidth(tostring(math.round(self.depth), 0))
        love.graphics.print(tostring(math.round(self.depth, 0)) .. 'm', cx - w/2, cy + 100)
        local w = small_font:getWidth(self.dead_text)
        love.graphics.setColor(255, 255, 255, self.dead_alpha)
        love.graphics.print(self.dead_text, cx - w/2, cy + 80)
    end
}
