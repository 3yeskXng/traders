local Logger = require("core.logger")
local Distance = require("simulation.travel.distance")
local log = Logger.new("maprenderer")

local MapRenderer = {}
MapRenderer.__index = MapRenderer

function MapRenderer.new()
  return setmetatable({ hoveredCity = nil, selectedCity = nil, cities = {} }, MapRenderer)
end

function MapRenderer:setCities(cities)
  self.cities = cities
end

function MapRenderer:draw(w, h, world)
  self:drawRoutes(w, h, world)
  self:drawCities(w, h, world)
  self:drawPlayerShip(w, h, world)
end

function MapRenderer:drawRoutes(w, h, world)
  local cities = world.cities:getAll()
  love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
  for i, a in ipairs(cities) do
    for j = i + 1, #cities do
      local b = cities[j]
      if Distance.isNearby(a, b, 0.25) then
        love.graphics.line(a.x * w, a.y * h, b.x * w, b.y * h)
      end
    end
  end
end

function MapRenderer:drawCities(w, h, world)
  for _, city in ipairs(world.cities:getAll()) do
    local sx, sy = city.x * w, city.y * h
    local radius = 7
    if city == self.hoveredCity then radius = 10 end
    if city == self.selectedCity then radius = 10 end
    if city.hasPort then
      love.graphics.setColor(0.2, 0.5, 0.9)
    else
      love.graphics.setColor(0.6, 0.4, 0.2)
    end
    love.graphics.circle("fill", sx, sy, radius)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(city.name, sx + radius + 3, sy - 5)
  end
end

function MapRenderer:drawPlayerShip(w, h, world)
  local tx, ty = world.travel:getPosition()
  if tx then
    love.graphics.setColor(1, 0.8, 0.2)
    love.graphics.circle("fill", tx * w, ty * h, 5)
  end
end

function MapRenderer:getCityAt(sx, sy, w, h, world)
  for _, city in ipairs(world.cities:getAll()) do
    local cx, cy = city.x * w, city.y * h
    local dx, dy = sx - cx, sy - cy
    if dx * dx + dy * dy <= 225 then
      return city
    end
  end
  return nil
end

return MapRenderer
