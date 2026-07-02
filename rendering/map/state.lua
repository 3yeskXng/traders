local Camera = require("rendering.camera")

local MapRenderer = {}
MapRenderer.__index = MapRenderer

function MapRenderer.new()
  return setmetatable({
    hoveredCity = nil,
    selectedCity = nil,
    camera = Camera.new(),
    dragging = false,
    dragStartX = 0,
    dragStartY = 0,
    dragCamX = 0,
    dragCamY = 0,
    mapConfig = nil,
    time = 0,
    routeAnimProgress = 0,
    _centerOnArrival = false,
    _world = nil,
  }, MapRenderer)
end

return MapRenderer
