local Camera = require("rendering.camera")

return {
  new = function()
    return {
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
    }
  end,
}
