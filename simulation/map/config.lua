local Logger = require("core.logger")
local log = Logger.new("mapconfig")

local MapConfig = {}
MapConfig.__index = MapConfig

function MapConfig.new(data)
  return setmetatable({
    name = data.name or "Unknown",
    backgroundColor = data.backgroundColor or { 0.88, 0.82, 0.72 },
    waterColor = data.waterColor or { 0.72, 0.78, 0.82 },
    coastColor = data.coastColor or { 0.35, 0.25, 0.15 },
    landColor = data.landColor or { 0.82, 0.75, 0.55 },
    forestColor = data.forestColor or { 0.5, 0.45, 0.25 },
    landPolygons = data.landPolygons or {},
    islands = data.islands or {},
    rivers = data.rivers or {},
    compassRose = data.compassRose or { x = 0.08, y = 0.8, size = 30 },
    decorations = data.decorations or {},
  }, MapConfig)
end

function MapConfig:isLand(x, y)
  for _, poly in ipairs(self.landPolygons) do
    if self:pointInPolygon(x, y, poly.points) then
      return true
    end
  end
  for _, island in ipairs(self.islands) do
    if self:pointInPolygon(x, y, island.points) then
      return true
    end
  end
  return false
end

function MapConfig:pointInPolygon(px, py, points)
  local inside = false
  local n = #points
  local j = n
  for i = 1, n do
    local xi, yi = points[i][1], points[i][2]
    local xj, yj = points[j][1], points[j][2]
    if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then
      inside = not inside
    end
    j = i
  end
  return inside
end

return MapConfig