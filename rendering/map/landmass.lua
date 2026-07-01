--- Rendering land masses including coastlines, forests, and islands.
-- Handles all land-based visual elements on the map.
local MapLandmass = {}

function MapLandmass.drawLandPolygons(mapConfig, w, h)
  -- Draw filled land areas with borders
  for _, poly in ipairs(mapConfig.landPolygons) do
    local coords = {}
    for _, pt in ipairs(poly.points) do
      table.insert(coords, pt[1] * w)
      table.insert(coords, pt[2] * h)
    end
    if #coords >= 6 then
      -- Fill land with sand color
      love.graphics.setColor(0.82, 0.75, 0.55)
      love.graphics.polygon("fill", coords)
      -- Draw land border
      love.graphics.setColor(0.55, 0.45, 0.3, 0.6)
      love.graphics.setLineWidth(3)
      love.graphics.polygon("line", coords)
      love.graphics.setLineWidth(1)
    end
  end
end

function MapLandmass.drawCoastlines(mapConfig, w, h)
  -- Draw detailed coastlines around land masses
  for _, poly in ipairs(mapConfig.landPolygons) do
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

function MapLandmass.drawForests(mapConfig, w, h, time)
  -- Draw procedurally positioned forests on land masses
  local seed = 54321
  local rng = love.math.newRandomGenerator(seed)
  
  for _, poly in ipairs(mapConfig.landPolygons) do
    local count = #poly.points
    local cx, cy = 0, 0
    
    -- Calculate polygon center
    for _, pt in ipairs(poly.points) do
      cx = cx + pt[1]
      cy = cy + pt[2]
    end
    cx = cx / count
    cy = cy / count
    
    -- Place forests around center with random distribution
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

function MapLandmass.drawRivers(mapConfig, w, h)
  -- Draw rivers connecting different areas
  for _, river in ipairs(mapConfig.rivers) do
    local fx, fy = river.from[1] * w, river.from[2] * h
    local tx, ty = river.to[1] * w, river.to[2] * h
    
    -- Main river channel
    love.graphics.setColor(0.6, 0.65, 0.7, 0.5)
    love.graphics.setLineWidth(river.width * w)
    love.graphics.line(fx, fy, tx, ty)
    
    -- Highlight on river
    love.graphics.setColor(0.4, 0.5, 0.6, 0.3)
    love.graphics.setLineWidth(river.width * w * 0.5)
    love.graphics.line(fx, fy, tx, ty)
    
    love.graphics.setLineWidth(1)
  end
end

function MapLandmass.drawIslands(mapConfig, w, h)
  -- Draw island land masses with labels
  for _, island in ipairs(mapConfig.islands) do
    local coords = {}
    for _, pt in ipairs(island.points) do
      table.insert(coords, pt[1] * w)
      table.insert(coords, pt[2] * h)
    end
    if #coords >= 6 then
      -- Fill island
      love.graphics.setColor(0.82, 0.75, 0.55)
      love.graphics.polygon("fill", coords)
      -- Draw island border
      love.graphics.setColor(0.4, 0.32, 0.2, 0.8)
      love.graphics.setLineWidth(2)
      love.graphics.polygon("line", coords)
      love.graphics.setLineWidth(1)
    end
    
    -- Island name label
    love.graphics.setColor(0.4, 0.32, 0.2, 0.6)
    love.graphics.print(island.name, island.x * w + 8, island.y * h - 5)
  end
end

return MapLandmass
