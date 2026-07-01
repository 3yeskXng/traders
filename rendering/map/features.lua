local MapFeatures = {}

function MapFeatures.drawForests(mapConfig, w, h)
  local seed = 54321
  local rng = love.math.newRandomGenerator(seed)

  for _, poly in ipairs(mapConfig.landPolygons) do
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
      if mapConfig:isLand(fx, fy) then
        love.graphics.setColor(0.5, 0.45, 0.25, 0.4)
        love.graphics.circle("fill", fx * w, fy * h, 8 + rng:random() * 12)
      end
    end
  end
end

function MapFeatures.drawRivers(mapConfig, w, h)
  for _, river in ipairs(mapConfig.rivers) do
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

return MapFeatures
