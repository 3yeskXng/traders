--- Rendering overlay elements like compass rose and decorations.
-- Handles UI overlays on top of the map.
local CompassRose = require("rendering.compass")
local MapOverlay = {}

function MapOverlay.drawOverlay(w, h, mapConfig)
  if not mapConfig then return end
  
  -- Draw compass rose if configured
  if mapConfig.compassRose then
    local cr = mapConfig.compassRose
    local cx, cy = cr.x * w, cr.y * h
    
    -- Compass background
    love.graphics.push()
    love.graphics.setColor(0.88, 0.82, 0.72, 0.6)
    love.graphics.rectangle("fill", cx - cr.size - 10, cy - cr.size - 10, (cr.size + 10) * 2, (cr.size + 10) * 2)
    love.graphics.pop()
    
    -- Draw the compass rose itself
    CompassRose.draw(cx, cy, cr.size)
  end
  
  -- Draw map decorations (text labels, markers, etc.)
  for _, dec in ipairs(mapConfig.decorations or {}) do
    if dec.type == "text" then
      local dx, dy = dec.x * w, dec.y * h
      love.graphics.setColor(0.25, 0.18, 0.1, 0.6)
      love.graphics.setFont(require("core.fonts").getFont(24))
      love.graphics.printf(dec.text, dx - 100, dy - 15, 200, "center")
      love.graphics.setFont(require("core.fonts").getFont(12))
    end
  end
end

return MapOverlay
