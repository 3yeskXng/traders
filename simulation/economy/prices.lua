local Utils = require("core.utils")

local Prices = {}

local MIN_PRICE_FACTOR = 0.3
local MAX_PRICE_FACTOR = 3.0
local STOCK_INFLUENCE = 0.7
local BASE_CAPACITY = 500

function Prices.calculate(basePrice, stock, population, randomFactor)
  local capacity = math.max(BASE_CAPACITY, population * 0.2)
  local ratio = stock / capacity
  local priceFactor = 1 + (1 - ratio) * STOCK_INFLUENCE
  priceFactor = Utils.clamp(priceFactor, MIN_PRICE_FACTOR, MAX_PRICE_FACTOR)
  local price = basePrice * priceFactor * (1 + randomFactor)
  return math.max(1, math.floor(price))
end

function Prices.updateCityPrices(city, goods, randomFactor)
  city.prevPrices = {}
  for _, good in ipairs(goods) do
    city.prevPrices[good.id] = city.prices[good.id] or Prices.calculate(good.basePrice, city:getStock(good.id), city.population, randomFactor)
    local stock = city:getStock(good.id)
    city.prices[good.id] = Prices.calculate(good.basePrice, stock, city.population, randomFactor)
  end
end

return Prices
