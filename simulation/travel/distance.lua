local Distance = {}

local DAYS_PER_UNIT = 8
local BASE_DAYS = 2

function Distance.between(cityA, cityB)
  local dx = cityA.x - cityB.x
  local dy = cityA.y - cityB.y
  return math.sqrt(dx * dx + dy * dy)
end

function Distance.calculateTravelDays(from, to)
  local dist = Distance.between(from, to)
  return math.max(1, math.floor(dist * DAYS_PER_UNIT + BASE_DAYS))
end

function Distance.isNearby(cityA, cityB, threshold)
  return Distance.between(cityA, cityB) <= (threshold or 0.2)
end

return Distance
