local Logger = require("core.logger")
local Distance = require("simulation.travel.distance")
local Components = require("ui.components")
local Camera = require("rendering.camera")
local log = Logger.new("maprenderer")

local MapRenderer = {}
MapRenderer.__index = MapRenderer

function MapRenderer.new()
  return setmetatable({
    hoveredCity = nil, selectedCity = nil, cities = {},
    camera = Camera.new(), dragging = false,
    dragStartX = 0, dragStartY = 0, dragCamX = 0, dragCamY = 0,
  }, MapRenderer)
end

function MapRenderer:setCities(cities)
  self.cities = cities
end

function MapRenderer:update(dt, world)
  self.camera:update(dt)
  if self._centerOnArrival and world and world.players[1] then
    local player = world.players[1]
    local city = player.currentCityId and world.cities:getById(player.currentCityId)
    if city then
      local w, h = love.graphics.getDimensions()
      self.camera:setTarget(city.x * w - w / 2, city.y * h - h / 2)
      local dist = math.abs(self.camera.x - self.camera.targetX) + math.abs(self.camera.y - self.camera.targetY)
      if dist < 5 then self._centerOnArrival = false end
    else
      self._centerOnArrival = false
    end
  end
end

function MapRenderer:draw(w, h, world)
  self.world = world
  self.camera:apply()
  self:drawBackground(w, h)
  self:drawRoutes(w, h, world)
  self:drawCities(w, h, world)
  self:drawPlayerShip(w, h, world)
  self.camera:endApply()
end

function MapRenderer:drawBackground(w, h)
  love.graphics.setColor(0.15, 0.25, 0.4)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0.1, 0.2, 0.08)
  local tileSize = 40
  for x = -tileSize, w + tileSize, tileSize do
    for y = -tileSize, h + tileSize, tileSize do
      if math.random() > 0.75 then
        love.graphics.ellipse("fill", x + math.random() * tileSize, y + math.random() * tileSize, tileSize * 0.5, tileSize * 0.25)
      end
    end
  end
  math.randomseed(os.time())
end

function MapRenderer:drawRoutes(w, h, world)
  local cities = world.cities:getAll()
  for i, a in ipairs(cities) do
    for j = i + 1, #cities do
      local b = cities[j]
      if a.hasPort and b.hasPort then
        love.graphics.setColor(0.3, 0.5, 0.7, 0.25)
        love.graphics.setLineWidth(1.5)
        love.graphics.line(a.x * w, a.y * h, b.x * w, b.y * h)
      elseif Distance.isNearby(a, b, 0.2) then
        love.graphics.setColor(0.4, 0.3, 0.2, 0.2)
        love.graphics.setLineWidth(1)
        love.graphics.line(a.x * w, a.y * h, b.x * w, b.y * h)
      end
    end
  end
  love.graphics.setLineWidth(1)
end

function MapRenderer:drawCities(w, h, world)
  local player = world.players[1]
  local playerCityId = player and player.currentCityId or nil
  for _, city in ipairs(world.cities:getAll()) do
    local sx, sy = city.x * w, city.y * h
    local radius = 7
    local isHover = city == self.hoveredCity
    local isPlayer = playerCityId and city.id == playerCityId
    if isHover or isPlayer then radius = 10 end

    if city.hasPort then
      love.graphics.setColor(0.15, 0.5, 0.85)
      love.graphics.circle("fill", sx, sy, radius)
      love.graphics.setColor(0.3, 0.6, 0.9)
      love.graphics.circle("fill", sx, sy, radius - 3)
    else
      love.graphics.setColor(0.55, 0.35, 0.15)
      love.graphics.circle("fill", sx, sy, radius)
      love.graphics.setColor(0.4, 0.25, 0.1)
      love.graphics.rectangle("fill", sx - 3, sy - 4, 6, 8)
    end

    if isPlayer then
      love.graphics.setColor(1, 0.9, 0.3, 0.3)
      love.graphics.circle("fill", sx, sy, 16)
    end

    love.graphics.setColor(1, 1, 1)
    local nameY = sy - radius - 12
    if isHover then
      love.graphics.setColor(0.9, 0.9, 0.5)
      love.graphics.print(city.name .. " (" .. Components.formatNumber(city.population) .. " EW)", sx + radius + 3, nameY)
      self:drawCityTooltip(w, h, city)
    else
      love.graphics.print(city.name, sx + radius + 3, nameY)
    end
  end
end

function MapRenderer:drawCityTooltip(w, h, city)
  local goods = self.world and self.world.goods
  if not goods then return end
  local mx, my = love.mouse.getPosition()
  local tw, th = 200, 80
  local tx = math.min(mx + 15, w - tw - 10)
  local ty = math.min(my + 15, h - th - 10)

  love.graphics.setColor(0.08, 0.08, 0.12, 0.95)
  love.graphics.rectangle("fill", tx, ty, tw, th)
  love.graphics.setColor(0.5, 0.4, 0.2)
  love.graphics.rectangle("line", tx, ty, tw, th)

  love.graphics.setColor(0.8, 0.7, 0.4)
  love.graphics.print(city.name, tx + 5, ty + 3)
  love.graphics.setColor(0.6, 0.6, 0.6)
  love.graphics.print("BW: " .. Components.formatNumber(city.population), tx + 5, ty + 18)
  love.graphics.print("Wohlstand: " .. Components.formatNumber(city.wealth), tx + 5, ty + 33)

  local produces = {}
  for _, pid in ipairs(city.produces) do
    local g = goods.byId and goods.byId[pid]
    table.insert(produces, g and g.name or pid)
  end
  if #produces > 0 then
    love.graphics.setColor(0.3, 0.7, 0.3)
    love.graphics.print("Produziert: " .. table.concat(produces, ", "), tx + 5, ty + 50)
  end

  local consumes = {}
  for _, cid in ipairs(city.consumes) do
    local g = goods.byId and goods.byId[cid]
    table.insert(consumes, g and g.name or cid)
  end
  if #consumes > 0 then
    love.graphics.setColor(0.8, 0.3, 0.3)
    love.graphics.print("Benötigt: " .. table.concat(consumes, ", "), tx + 5, ty + 65)
  end
end

function MapRenderer:drawPlayerShip(w, h, world)
  local tx, ty = world.travel:getPosition()
  if tx then
    love.graphics.setColor(1, 0.8, 0.2)
    love.graphics.circle("fill", tx * w, ty * h, 6)
    love.graphics.setColor(1, 1, 0.5, 0.4)
    love.graphics.circle("fill", tx * w, ty * h, 10)
    return
  end
  local player = world.players[1]
  if player and player.currentCityId then
    local city = world.cities:getById(player.currentCityId)
    if city then
      love.graphics.setColor(0.8, 0.8, 0.2, 0.6)
      love.graphics.circle("fill", city.x * w, city.y * h, 11)
      love.graphics.setColor(1, 0.8, 0.2)
      love.graphics.circle("fill", city.x * w, city.y * h, 6)
    end
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

function MapRenderer:cameraMoved(x, y)
  self.camera.x = x
  self.camera.y = y
end

function MapRenderer:startDrag(x, y)
  self.dragging = true
  self.dragStartX = x
  self.dragStartY = y
  self.dragCamX = self.camera.x
  self.dragCamY = self.camera.y
end

function MapRenderer:updateDrag(x, y)
  if not self.dragging then return end
  self.camera.x = self.dragCamX - (x - self.dragStartX)
  self.camera.y = self.dragCamY - (y - self.dragStartY)
end

function MapRenderer:stopDrag()
  self.dragging = false
end

return MapRenderer