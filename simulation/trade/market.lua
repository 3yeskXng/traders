local Market = {}

function Market.getBuyPrice(city, goodId)
  return city.prices[goodId] or 0
end

function Market.getSellPrice(city, goodId)
  local price = city.prices[goodId] or 0
  return math.floor(price * 0.9)
end

function Market.isAccessible(city, player)
  return true
end

function Market.getSpread(cityA, cityB, goodId)
  local priceA = Market.getBuyPrice(cityA, goodId)
  local priceB = Market.getBuyPrice(cityB, goodId)
  if priceA <= 0 or priceB <= 0 then return 0 end
  return math.abs(priceA - priceB)
end

return Market
