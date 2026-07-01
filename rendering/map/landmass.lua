local MapFeatures = require("rendering.map.features")
local MapIslands = require("rendering.map.islands")

local MapLandmass = {}

function MapLandmass.drawLandPolygons(mapConfig, w, h)
  for _, poly in ipairs(mapConfig.landPolygons) do
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

function MapLandmass.drawCoastlines(mapConfig, w, h)
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

function MapLandmass.drawForests(mapConfig, w, h)
  MapFeatures.drawForests(mapConfig, w, h)
end

function MapLandmass.drawRivers(mapConfig, w, h)
  MapFeatures.drawRivers(mapConfig, w, h)
end

function MapLandmass.drawIslands(mapConfig, w, h)
  MapIslands.drawIslands(mapConfig, w, h)
end

return MapLandmass
