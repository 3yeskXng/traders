local Logger = require("core.logger")
local log = Logger.new("renderer")

local Renderer = {}
Renderer.__index = Renderer

function Renderer.new(world)
  return setmetatable({ world = world }, Renderer)
end

function Renderer:draw()
  self:drawBackground()
  self:drawCities()
  self:drawTravel()
end

function Renderer:drawBackground()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0.2, 0.3, 0.5)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0.15, 0.25, 0.1)
  local tileSize = 40
  for x = 0, w, tileSize do
    for y = 0, h, tileSize do
      if math.random() > 0.7 then
        love.graphics.ellipse("fill", x + math.random() * tileSize, y + math.random() * tileSize, tileSize * 0.6, tileSize * 0.3)
      end
    end
  end
  math.randomseed(os.time())
end

function Renderer:drawCities()
  local w, h = love.graphics.getDimensions()
  for _, city in ipairs(self.world.cities:getAll()) do
    local sx, sy = city.x * w, city.y * h
    if city.hasPort then
      love.graphics.setColor(0.2, 0.4, 0.8)
    else
      love.graphics.setColor(0.6, 0.4, 0.2)
    end
    love.graphics.circle("fill", sx, sy, 8)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(city.name, sx + 12, sy - 6)
  end
end

function Renderer:drawTravel()
  local w, h = love.graphics.getDimensions()
  local tx, ty = self.world.travel:getPosition()
  if tx then
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.circle("fill", tx * w, ty * h, 6)
  end
end

return Renderer
