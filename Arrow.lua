Arrow = Class{}

function Arrow:init(x,y, dx, dy)
    self.x = x
    self.y = y
    self.dx = dx
    self.dy = dy
    self.width = 32
    self.height = 16
    self.texture = love.graphics.newImage('Sprites/arrow.png')
    self.timer = 1
    self.remove = false
end
function Arrow:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    self.timer = self.timer - dt

    if self.timer <= 0 then
        self.remove = true
    end
end
function Arrow:render()
    love.graphics.draw(self.texture, love.graphics.newQuad(0, 0, self.width, self.height, self.texture:getDimensions()), self.x , self.y)
end