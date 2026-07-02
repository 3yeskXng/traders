local Demand = {}

local DEMAND_RATES = {
  GRAIN = 0.015,
  BEER  = 0.020,
  MEAT  = 0.005,
  WINE  = 0.003,
  SPICES = 0.001,
}

function Demand.calculate(good, city)
  local isConsumed = false
  for _, cid in ipairs(city.consumes or {}) do
    if cid == good.id then isConsumed = true break end
  end
  if not isConsumed then return 0 end

  local poor = city.pop_poor or math.floor(city.population * 0.70)
  local wellOff = city.pop_well_off or math.floor(city.population * 0.25)
  local rich = city.pop_rich or math.floor(city.population * 0.05)

  local baseRate = DEMAND_RATES[good.id] or 0.01
  local totalDemand = 0

  if good.category == "LUXURY" then
    totalDemand = (wellOff * baseRate * 0.5) + (rich * baseRate * 2.0)
    local stability = city.stability or 1.0
    totalDemand = totalDemand * stability
  elseif good.category == "PROSPERITY" then
    totalDemand = (poor * baseRate * 0.2) + (wellOff * baseRate * 1.0) + (rich * baseRate * 1.5)
  else
    totalDemand = (poor + wellOff + rich) * baseRate
  end

  local isProduced = false
  for _, pid in ipairs(city.produces or {}) do
    if pid == good.id then isProduced = true break end
  end
  if isProduced then
    totalDemand = totalDemand * 0.6
  end

  return math.max(0, totalDemand)
end

function Demand.calculateAll(goods, city)
  local demands = {}
  for _, good in ipairs(goods) do
    demands[good.id] = Demand.calculate(good, city)
  end
  return demands
end

return Demand
