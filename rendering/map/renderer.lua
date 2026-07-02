local MapConfig = require("simulation.map.config")
local MapBackgrounds = require("rendering.map.backgrounds")
local MapLandmass = require("rendering.map.landmass")
local MapRoutes = require("rendering.map.routes")
local MapCities = require("rendering.map.cities")
local MapShips = require("rendering.map.ships")
local MapOverlay = require("rendering.map.overlay")
local MapTooltip = require("rendering.map.tooltip")

local Renderer = {}

function Renderer.draw(renderer, w, h, world)
  renderer._world = world
  if not renderer.mapConfig then
    renderer.mapConfig = MapConfig.new({})
  end
  renderer.camera:apply()
  MapBackgrounds.drawBackground(renderer, w, h)
  MapBackgrounds.drawWaterTint(w, h)
  MapLandmass.drawLandPolygons(renderer.mapConfig, w, h)
  MapLandmass.drawCoastlines(renderer.mapConfig, w, h)
  MapLandmass.drawForests(renderer.mapConfig, w, h)
  MapLandmass.drawRivers(renderer.mapConfig, w, h)
  MapLandmass.drawIslands(renderer.mapConfig, w, h)
  MapRoutes.drawRoutes(world, w, h)
  MapCities.drawCities(renderer, w, h, world)
  MapShips.drawPlayerShip(w, h, world, renderer.time)
  MapCities.drawCityLabel(w, h, world, renderer)
  renderer.camera:endApply()
  MapOverlay.drawOverlay(w, h, renderer.mapConfig)
  if renderer.hoveredCity then
    local mx, my = love.mouse.getPosition()
    MapTooltip.drawCityTooltip(w, h, renderer.hoveredCity, renderer._world, mx, my)
  end
end

return Renderer
