local Utils = require("core.utils")

local Prices = {}

local MIN_PRICE_FACTOR = 0.30
local MAX_PRICE_FACTOR = 12.0
local BASE_CAPACITY_DAYS = 14

function Prices.calculate(basePrice, stock, population, randomFactor, dailyDemand)
  local targetCapacity = (dailyDemand or 0) * BASE_CAPACITY_DAYS
  if targetCapacity <= 0 then
    targetCapacity = math.max(300, population * 0.2)
  end

  local ratio = stock / targetCapacity
  local priceFactor = 1.0

  if ratio >= 1.0 then
    priceFactor = MIN_PRICE_FACTOR + (1.0 - MIN_PRICE_FACTOR) / (1.0 + (ratio - 1.0) * 0.5)
  else
    priceFactor = 0.5 + (0.5 / (ratio + 0.08))
    if ratio < 0.25 then
      priceFactor = priceFactor * (1.2 + (0.25 - ratio) * 4.0)
    end
  end

  priceFactor = Utils.clamp(priceFactor, MIN_PRICE_FACTOR, MAX_PRICE_FACTOR)

  local price = basePrice * priceFactor * (1 + (randomFactor or 0))
  return math.max(1, math.floor(price))
end

function Prices.updateCityPrices(city, goods, randomFactor)
  city.prevPrices = city.prevPrices or {}
  local Demand = require("simulation.economy.demand")

  for _, good in ipairs(goods) do
    local dailyDemand = Demand.calculate(good, city)
    local currentStock = city:getStock(good.id)

    city.prevPrices[good.id] = city.prices[good.id] or Prices.calculate(good.basePrice, currentStock, city.population, randomFactor, dailyDemand)
    city.prices[good.id] = Prices.calculate(good.basePrice, currentStock, city.population, randomFactor, dailyDemand)
  end
end

return Prices
