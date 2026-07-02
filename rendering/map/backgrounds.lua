local Satellite = require("rendering.map.satellite")

local MapBackgrounds = {}

function MapBackgrounds.drawBackground(mapRenderer, w, h)
  love.graphics.setColor(0.06, 0.15, 0.28)
  love.graphics.rectangle("fill", -w, -h, w * 3, h * 3)

  Satellite.draw(w, h, mapRenderer.mapConfig)

  love.graphics.setColor(0.12, 0.25, 0.40, 0.10)
  love.graphics.rectangle("fill", -w, -h, w * 3, h * 3)
end

function MapBackgrounds.drawAtmosphere(w, h)
  love.graphics.setColor(0.18, 0.32, 0.48, 0.06)
  love.graphics.rectangle("fill", -w, -h, w * 3, h * 3)
end

return MapBackgrounds
