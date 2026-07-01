--- Rendering backgrounds and water effects for the map.
-- Handles decorative background elements and water visualization.
local MapBackgrounds = {}

function MapBackgrounds.drawBackground(mapRenderer, w, h)
  -- Main ocean background with gradient colors
  love.graphics.setColor(0.11, 0.2, 0.32)
  love.graphics.rectangle("fill", -w, -h, w * 3, h * 3)

  -- Animated horizontal wave lines
  for i = 1, 12 do
    local y = (i / 12) * h + math.sin(mapRenderer.time * 0.7 + i) * 8
    love.graphics.setColor(0.2, 0.34, 0.5, 0.16)
    love.graphics.line(0, y, w, y + 8)
  end

  -- Scattered floating particles
  for i = 1, 20 do
    local x = (i / 20) * w + math.sin(mapRenderer.time * 0.5 + i * 0.5) * 12
    local y = h * 0.2 + (i % 4) * 18
    love.graphics.setColor(0.25, 0.42, 0.62, 0.08)
    love.graphics.circle("fill", x, y, 2 + (i % 3))
  end

  -- Bottom horizon shadow
  love.graphics.setColor(0.16, 0.3, 0.42, 0.22)
  love.graphics.rectangle("fill", -w, h * 0.72, w * 3, h * 0.38)
  love.graphics.setColor(0.24, 0.38, 0.5, 0.3)
  love.graphics.rectangle("fill", -w, h * 0.78, w * 3, h * 0.08)
end

function MapBackgrounds.drawWaterTint(w, h)
  -- Overlay water effect with transparency
  love.graphics.setColor(0.72, 0.78, 0.82, 0.15)
  love.graphics.rectangle("fill", -w, -h, w * 3, h * 3)
end

return MapBackgrounds
