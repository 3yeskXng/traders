local Camera = {}
Camera.__index = Camera

function Camera.new()
  return setmetatable({
    x = 0, y = 0,
    scale = 1,
    targetX = 0, targetY = 0,
    smooth = true,
  }, Camera)
end

function Camera:setTarget(x, y)
  self.targetX = x
  self.targetY = y
end

function Camera:update(dt)
  if self.smooth then
    self.x = self.x + (self.targetX - self.x) * 0.1
    self.y = self.y + (self.targetY - self.y) * 0.1
  else
    self.x, self.y = self.targetX, self.targetY
  end
end

function Camera:apply()
  love.graphics.push()
  love.graphics.translate(-self.x, -self.y)
  love.graphics.scale(self.scale)
end

function Camera:endApply()
  love.graphics.pop()
end

return Camera
