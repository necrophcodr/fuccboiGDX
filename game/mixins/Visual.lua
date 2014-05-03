-- Requires PhysicsRectangle
Visual = {
    visualInit = function(self, visual, offset, wiggle)
        self.visual = visual
        self.wiggle = wiggle
        self.offset = offset or Vector(0, 0)
        self.combine = shaders['combine']
    end,

    visualDraw = function(self, offset_x, offset_y)

        if not self.visual then return end
        local x, y = self.body:getPosition()
        local w, h = self.visual:getWidth(), self.visual:getHeight()
        local ox, oy = offset_x or 0, offset_y or 0
        pushRotateScale(x, y, self.body:getAngle(), self.scale)
        x, y = x - w/2 - self.offset.x + ox, y - h/2 - self.offset.y + oy
        if self.selected then 
            love.graphics.setShader(self.combine)
            love.graphics.setColor(200, 200, 200, 255)
        end
        if self.wiggle then love.graphics.draw(self.visual, x + self.wiggle_direction*self.wiggle_x, y)
        else love.graphics.draw(self.visual, x, y) end
        love.graphics.pop()
        love.graphics.setShader()
        love.graphics.setColor(255, 255, 255, 255)
    end
}
