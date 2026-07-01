local Logger = require("core.logger")
local Camera = require("rendering.camera")
local MapConfig = require("simulation.map.config")
local MapBackgrounds = require("rendering.map.backgrounds")
local MapLandmass = require("rendering.map.landmass")
local MapRoutes = require("rendering.map.routes")
local MapCities = require("rendering.map.cities")
local MapTooltip = require("rendering.map.tooltip")
local MapShips = require("rendering.map.ships")
local MapOverlay = require("rendering.map.overlay")

local log = Logger.new("maprenderer")

local MapRenderer = {}
MapRenderer.__index = MapRenderer

function MapRenderer.new()
  return setmetatable({
    hoveredCity = nil, selectedCity = nil,
    camera = Camera.new(), dragging = false,
    dragStartX = 0, dragStartY = 0, dragCamX = 0, dragCamY = 0,
    mapConfig = nil,
    time = 0,
    routeAnimProgress = 0,
    _centerOnArrival = false,
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
  self._world = world
  if not self.mapConfig then
    self.mapConfig = MapConfig.new({})
  end
  self.camera:apply()
  MapBackgrounds.drawBackground(self, w, h)
  MapBackgrounds.drawWaterTint(w, h)
  MapLandmass.drawLandPolygons(self.mapConfig, w, h)
  MapLandmass.drawCoastlines(self.mapConfig, w, h)
  MapLandmass.drawForests(self.mapConfig, w, h)
  MapLandmass.drawRivers(self.mapConfig, w, h)
  MapLandmass.drawIslands(self.mapConfig, w, h)
  MapRoutes.drawRoutes(world, w, h)
  MapCities.drawCities(self, w, h, world)
  MapShips.drawPlayerShip(w, h, world, self.time)
  MapCities.drawCityLabel(w, h, world, self)
  self.camera:endApply()
  MapOverlay.drawOverlay(w, h, self.mapConfig)
  if self.hoveredCity then
    local mx, my = love.mouse.getPosition()
    MapTooltip.drawCityTooltip(w, h, self.hoveredCity, self._world, mx, my)
  end
end

function MapRenderer:screenToWorld(sx, sy)
  local scale = self.camera.scale or 1
  return sx / scale + self.camera.x, sy / scale + self.camera.y
end

function MapRenderer:getCityAt(sx, sy, w, h, world)
  local wx, wy = self:screenToWorld(sx, sy)
  for _, city in ipairs(world.cities:getAll()) do
    local cx, cy = city.x * w, city.y * h
    local dx, dy = wx - cx, wy - cy
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
