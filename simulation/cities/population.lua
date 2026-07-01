local Population = {}

function Population.update(city, goodsManager)
  local foodSupply = 0
  local foodNeeded = city.population * 0.01
  for _, good in ipairs(goodsManager:getAll()) do
    if good.category == "food" then
      foodSupply = foodSupply + (city.inventory[good.id] or 0)
    end
  end
  local growthRate = 0
  if foodSupply >= foodNeeded then
    growthRate = 0.001 * (foodSupply / foodNeeded)
  else
    growthRate = -0.002 * (foodNeeded - foodSupply) / foodNeeded
  end
  city.population = math.max(100, city.population + city.population * growthRate)
  city.population = math.floor(city.population)
end

return Population
