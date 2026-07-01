local Supply = {}

function Supply.calculate(good, city)
  local isProduced = false
  for _, pid in ipairs(city.produces) do
    if pid == good.id then isProduced = true break end
  end
  if not isProduced then return 0 end
  return good.baseProduction * (city.population / 1000)
end

function Supply.calculateAll(goods, city)
  local supplies = {}
  for _, good in ipairs(goods) do
    supplies[good.id] = Supply.calculate(good, city)
  end
  return supplies
end

return Supply
