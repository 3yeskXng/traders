local Logger = require("core.logger")
local Components = require("ui.components")
local Camera = require("rendering.camera")
local CompassRose = require("rendering.compass")
local MapConfig = require("simulation.map.config")
local log = Logger.new("maprenderer")

local MapRenderer = {}
MapRenderer.__index = MapRenderer

function MapRenderer.new()
  return setmetatable({
    hoveredCity = nil, selectedCity = nil,
    camera = Camera.new(), dragging = false,
    dragStartX = 0, dragStartY = 0, dragCamX = 0, dragCamY = 0,
    mapConfig = nil, parchmentNoise = nil,
    time = 0,
    routeAnimProgress = 0,
  }, MapRenderer)
end

function MapRenderer:update(dt, world)
  self.time = self.time + dt
  self.routeAnimProgress = (self.routeAnimProgress + dt * 0.1) % 1
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
  if not self.mapConfig then
    self.mapConfig = MapConfig.new({
      landPolygons = {},
      islands = {},
      rivers = {},
      compassRose = { x = 0.08, y = 0.85, size = 30 },
      decorations = {},
    })
  end
  self.camera:apply()
  self:drawBackground(w, h)
  self:drawWaterTint(w, h)
  self:drawLandPolygons(w, h)
  self:drawCoastlines(w, h)
  self:drawForests(w, h)
  self:drawRivers(w, h)
  self:drawIslands(w, h)
  self:drawRoutes(w, h, world)
  self:drawCities(w, h, world)
  self:drawPlayerShip(w, h, world)
  self:drawCityLabel(w, h, world)
  self.camera:endApply()
  self:drawOverlay(w, h)
end

function MapRenderer:drawBackground(w, h)
  love.graphics.setColor(0.88, 0.82, 0.72)
  love.graphics.rectangle("fill", -w, -h, w * 3, h * 3)
  local seed = 12345
  local rng = love.math.newRandomGenerator(seed)
  for i = 1, w * h * 0.002 do
    local px = rng:random() * w * 3 - w
    local py = rng:random() * h * 3 - h
    local shade = 0.82 + rng:random() * 0.12
    love.graphics.setColor(shade, shade * 0.95, shade * 0.85, 0.3)
    love.graphics.rectangle("fill", px, py, 4 + rng:random() * 8, 2 + rng:random() * 4)
  end
end

function MapRenderer:drawWaterTint(w, h)
  love.graphics.setColor(0.72, 0.78, 0.82, 0.15)
  love.graphics.rectangle("fill", -w, -h, w * 3, h * 3)
end

function MapRenderer:drawLandPolygons(w, h)
  for _, poly in ipairs(self.mapConfig.landPolygons) do
    local coords = {}
    for _, pt in ipairs(poly.points) do
      table.insert(coords, pt[1] * w)
      table.insert(coords, pt[2] * h)
    end
    if #coords >= 6 then
      love.graphics.setColor(0.82, 0.75, 0.55)
      love.graphics.polygon("fill", coords)
      love.graphics.setColor(0.55, 0.45, 0.3, 0.6)
      love.graphics.setLineWidth(3)
      love.graphics.polygon("line", coords)
      love.graphics.setLineWidth(1)
    end
  end
end

function MapRenderer:drawCoastlines(w, h)
  for _, poly in ipairs(self.mapConfig.landPolygons) do
    love.graphics.setColor(0.35, 0.25, 0.15, 0.5)
    love.graphics.setLineWidth(6)
    for i = 1, #poly.points do
      local p1 = poly.points[i]
      local p2 = poly.points[i % #poly.points + 1]
      love.graphics.line(p1[1] * w, p1[2] * h, p2[1] * w, p2[2] * h)
    end
    love.graphics.setColor(0.5, 0.38, 0.22, 0.7)
    love.graphics.setLineWidth(2)
    for i = 1, #poly.points do
      local p1 = poly.points[i]
      local p2 = poly.points[i % #poly.points + 1]
      love.graphics.line(p1[1] * w, p1[2] * h, p2[1] * w, p2[2] * h)
    end
    love.graphics.setLineWidth(1)
  end
end

function MapRenderer:drawForests(w, h)
  local seed = 54321
  local rng = love.math.newRandomGenerator(seed)
  for _, poly in ipairs(self.mapConfig.landPolygons) do
    local count = #poly.points
    local cx, cy = 0, 0
    for _, pt in ipairs(poly.points) do
      cx = cx + pt[1]
      cy = cy + pt[2]
    end
    cx = cx / count
    cy = cy / count
    for i = 1, 15 do
      local angle = rng:random() * math.pi * 2
      local dist = rng:random() * 0.15
      local fx = cx + math.cos(angle) * dist
      local fy = cy + math.sin(angle) * dist
      if self.mapConfig:isLand(fx, fy) then
        love.graphics.setColor(0.5, 0.45, 0.25, 0.4)
        love.graphics.circle("fill", fx * w, fy * h, 8 + rng:random() * 12)
      end
    end
  end
end

function MapRenderer:drawRivers(w, h)
  for _, river in ipairs(self.mapConfig.rivers) do
    local fx, fy = river.from[1] * w, river.from[2] * h
    local tx, ty = river.to[1] * w, river.to[2] * h
    love.graphics.setColor(0.6, 0.65, 0.7, 0.5)
    love.graphics.setLineWidth(river.width * w)
    love.graphics.line(fx, fy, tx, ty)
    love.graphics.setColor(0.4, 0.5, 0.6, 0.3)
    love.graphics.setLineWidth(river.width * w * 0.5)
    love.graphics.line(fx, fy, tx, ty)
    love.graphics.setLineWidth(1)
  end
end

function MapRenderer:drawIslands(w, h)
  for _, island in ipairs(self.mapConfig.islands) do
    local coords = {}
    for _, pt in ipairs(island.points) do
      table.insert(coords, pt[1] * w)
      table.insert(coords, pt[2] * h)
    end
    if #coords >= 6 then
      love.graphics.setColor(0.82, 0.75, 0.55)
      love.graphics.polygon("fill", coords)
      love.graphics.setColor(0.4, 0.32, 0.2, 0.8)
      love.graphics.setLineWidth(2)
      love.graphics.polygon("line", coords)
      love.graphics.setLineWidth(1)
    end
    love.graphics.setColor(0.4, 0.32, 0.2, 0.6)
    love.graphics.print(island.name, island.x * w + 8, island.y * h - 5)
  end
end

function MapRenderer:drawRoutes(w, h, world)
  local cities = world.cities:getAll()
  local player = world.players[1]
  local routeCities = {}
  for _, c in ipairs(cities) do
    if c.hasPort then table.insert(routeCities, c) end
  end

  for i = 1, #routeCities do
    for j = i + 1, #routeCities do
      local a, b = routeCities[i], routeCities[j]
      local ax, ay = a.x * w, a.y * h
      local bx, by = b.x * w, b.y * h

      love.graphics.setColor(0.35, 0.25, 0.15, 0.15)
      love.graphics.setLineWidth(1.5)
      local dashLen = 8
      local gapLen = 4
      local totalLen = dashLen + gapLen
      local dx, dy = bx - ax, by - ay
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist > 0 then
        local segments = math.floor(dist / totalLen)
        for k = 0, segments do
          local t1 = (k * totalLen) / dist
          local t2 = math.min((k * totalLen + dashLen) / dist, 1)
          love.graphics.line(
            ax + dx * t1, ay + dy * t1,
            ax + dx * t2, ay + dy * t2
          )
        end
      end
      love.graphics.setLineWidth(1)
    end
  end

  if player and player.currentCityId then
    local pc = world.cities:getById(player.currentCityId)
    if pc then
      love.graphics.setColor(0.8, 0.7, 0.2, 0.3)
      love.graphics.setLineWidth(2)
      for _, c in ipairs(routeCities) do
        if c.id ~= pc.id then
          love.graphics.line(pc.x * w, pc.y * h, c.x * w, c.y * h)
        end
      end
      love.graphics.setLineWidth(1)
    end
  end
end

function MapRenderer:drawCities(w, h, world)
  for _, city in ipairs(world.cities:getAll()) do
    local sx, sy = city.x * w, city.y * h
    local isHover = city == self.hoveredCity
    local player = world.players[1]
    local isPlayer = player and player.currentCityId == city.id

    self:drawCityIcon(sx, sy, city, isHover, isPlayer)
  end
end

function MapRenderer:drawCityIcon(sx, sy, city, isHover, isPlayer)
  local scale = isHover and 1.3 or 1
  local size = 10 * scale

  if isPlayer then
    love.graphics.setColor(1, 0.9, 0.3, 0.2)
    love.graphics.circle("fill", sx, sy, size * 1.8)
  end

  if city.hasPort then
    love.graphics.setColor(0.15, 0.5, 0.85)
    love.graphics.rectangle("fill", sx - size * 0.5, sy - size * 0.3, size, size * 0.6)
    love.graphics.setColor(0.25, 0.65, 0.95)
    love.graphics.rectangle("fill", sx - size * 0.35, sy - size * 0.5, size * 0.7, size * 0.7)
    love.graphics.setColor(0.12, 0.4, 0.7)
    love.graphics.rectangle("line", sx - size * 0.35, sy - size * 0.5, size * 0.7, size * 0.7)

    love.graphics.setColor(0.5, 0.3, 0.15)
    love.graphics.rectangle("fill", sx - size * 0.15, sy + size * 0.2, size * 0.3, size * 0.3)
  else
    love.graphics.setColor(0.6, 0.35, 0.15)
    love.graphics.rectangle("fill", sx - size * 0.4, sy - size * 0.2, size * 0.8, size * 0.5)
    love.graphics.setColor(0.7, 0.4, 0.2)
    love.graphics.polygon("fill", sx, sy - size * 0.6, sx - size * 0.4, sy - size * 0.15, sx + size * 0.4, sy - size * 0.15)
    love.graphics.setColor(0.5, 0.3, 0.12)
    love.graphics.rectangle("line", sx - size * 0.4, sy - size * 0.2, size * 0.8, size * 0.5)
    love.graphics.rectangle("line", sx - size * 0.3, sy - size * 0.1, size * 0.25, size * 0.2)
    love.graphics.rectangle("line", sx + size * 0.05, sy - size * 0.1, size * 0.25, size * 0.2)
  end

  if isHover then
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.circle("fill", sx, sy, 2)
  end
end

function MapRenderer:drawCityLabel(w, h, world)
  for _, city in ipairs(world.cities:getAll()) do
    local sx, sy = city.x * w, city.y * h
    local isHover = city == self.hoveredCity
    local player = world.players[1]
    local isPlayer = player and player.currentCityId == city.id

    local label = city.name
    local labelY

    labelY = sy - 16
    if isHover then
      labelY = sy - 22
      love.graphics.setColor(0.9, 0.85, 0.4)
      love.graphics.setNewFont(14)
      label = city.name .. " (" .. Components.formatNumber(city.population) .. ")"
    elseif isPlayer then
      love.graphics.setColor(1, 0.9, 0.5)
      love.graphics.setNewFont(12)
    else
      love.graphics.setColor(0.95, 0.9, 0.7)
      love.graphics.setNewFont(11)
    end

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(label, sx + 10, labelY - 1)
    love.graphics.print(label, sx + 12, labelY + 1)
    love.graphics.print(label, sx + 10, labelY + 1)
    love.graphics.print(label, sx + 12, labelY - 1)
    love.graphics.setColor(isHover and 1 or 0.95, (isHover or isPlayer) and 0.9 or 0.9, isPlayer and 0.5 or 0.7)
    love.graphics.print(label, sx + 11, labelY)
  end
  love.graphics.setNewFont(12)
end

function MapRenderer:drawPlayerShip(w, h, world)
  local tx, ty = world.travel:getPosition()
  if tx then
    local px, py = tx * w, ty * h
    local angle = self.time * 2
    love.graphics.setColor(0.6, 0.45, 0.2)
    love.graphics.push()
    love.graphics.translate(px, py)
    love.graphics.rotate(angle)
    love.graphics.polygon("fill", 0, -8, -5, 5, 5, 5)
    love.graphics.setColor(0.9, 0.8, 0.3)
    love.graphics.polygon("fill", 0, -6, -3, 3, 3, 3)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 0.5, 0.3)
    love.graphics.circle("fill", px, py, 12)
    return
  end
  local player = world.players[1]
  if player and player.currentCityId then
    local city = world.cities:getById(player.currentCityId)
    if city then
      local cx, cy = city.x * w, city.y * h
      love.graphics.setColor(0.6, 0.45, 0.2)
      love.graphics.push()
      love.graphics.translate(cx, cy)
      love.graphics.polygon("fill", 0, -8, -5, 5, 5, 5)
      love.graphics.setColor(0.9, 0.8, 0.3)
      love.graphics.polygon("fill", 0, -6, -3, 3, 3, 3)
      love.graphics.pop()
    end
  end
end

function MapRenderer:drawOverlay(w, h)
  local mr = self.mapConfig
  if mr and mr.compassRose then
    local cr = mr.compassRose
    local cx, cy = cr.x * w, cr.y * h
    love.graphics.push()
    love.graphics.setColor(0.88, 0.82, 0.72, 0.6)
    love.graphics.rectangle("fill", cx - cr.size - 10, cy - cr.size - 10, (cr.size + 10) * 2, (cr.size + 10) * 2)
    love.graphics.pop()
    CompassRose.draw(cx, cy, cr.size)
  end
  for _, dec in ipairs(mr.decorations) do
    if dec.type == "text" then
      local dx, dy = dec.x * w, dec.y * h
      love.graphics.setColor(0.25, 0.18, 0.1, 0.6)
      love.graphics.setNewFont(24)
      love.graphics.printf(dec.text, dx - 100, dy - 15, 200, "center")
      love.graphics.setNewFont(12)
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

  love.graphics.setColor(0.88, 0.82, 0.72, 0.95)
  love.graphics.rectangle("fill", tx, ty, tw, th)
  love.graphics.setColor(0.35, 0.25, 0.15)
  love.graphics.rectangle("line", tx, ty, tw, th)

  love.graphics.setColor(0.3, 0.2, 0.1)
  love.graphics.setNewFont(13)
  love.graphics.print(city.name, tx + 5, ty + 3)
  love.graphics.setNewFont(11)
  love.graphics.setColor(0.4, 0.3, 0.15)
  love.graphics.print("BW: " .. Components.formatNumber(city.population), tx + 5, ty + 20)
  love.graphics.print("Wohlstand: " .. Components.formatNumber(city.wealth), tx + 5, ty + 33)

  local produces = {}
  for _, pid in ipairs(city.produces) do
    local g = goods.byId and goods.byId[pid]
    table.insert(produces, g and g.name or pid)
  end
  if #produces > 0 then
    love.graphics.setColor(0.3, 0.55, 0.2)
    love.graphics.print("Produziert: " .. table.concat(produces, ", "), tx + 5, ty + 48)
  end

  local consumes = {}
  for _, cid in ipairs(city.consumes) do
    local g = goods.byId and goods.byId[cid]
    table.insert(consumes, g and g.name or cid)
  end
  if #consumes > 0 then
    love.graphics.setColor(0.7, 0.25, 0.2)
    love.graphics.print("Benötigt: " .. table.concat(consumes, ", "), tx + 5, ty + 63)
  end
  love.graphics.setNewFont(12)
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