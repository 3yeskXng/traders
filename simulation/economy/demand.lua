local Demand = {}

local BASE_DEMAND_PER_PERSON = 0.01

function Demand.calculate(good, city)
  local isProduced = false
  for _, pid in ipairs(city.produces) do
    if pid == good.id then isProduced = true break end
  end
  local isConsumed = false
  for _, cid in ipairs(city.consumes) do
    if cid == good.id then isConsumed = true break end
  end
  if not isConsumed then return 0 end
  local demand = city.population * BASE_DEMAND_PER_PERSON
  if isProduced then demand = demand * 0.5 end
  return demand
end

function Demand.calculateAll(goods, city)
  local demands = {}
  for _, good in ipairs(goods) do
    demands[good.id] = Demand.calculate(good, city)
  end
  return demands
end

return Demand
