local Logger = require("core.logger")
local EventBus = require("core.eventbus")
local Prices = require("simulation.economy.prices")
local log = Logger.new("trading")

local TradeSystem = {}
TradeSystem.__index = TradeSystem

function TradeSystem.new()
  return setmetatable({ log = {} }, TradeSystem)
end

-- Build a minimal city view for live price calculation during trade execution
local function getTempCityState(city, goodId, stockOffset)
  return {
    population = city.population,
    getStock = function() return math.max(0, city:getStock(goodId) + stockOffset) end
  }
end

function TradeSystem:buy(buyer, city, goodId, maxAmount, baseGoodData, randomFactor)
  local totalCost = 0
  local actualTraded = 0

  local availableStock = city:getStock(goodId)
  if availableStock <= 0 or buyer.gold <= 0 then return 0 end

  local loopAmount = math.min(maxAmount, availableStock)

  for i = 1, loopAmount do
    local tempCity = getTempCityState(city, goodId, -actualTraded)
    local currentUnitPrice = Prices.calculate(baseGoodData.basePrice, tempCity:getStock(), city.population, randomFactor)

    if buyer.gold >= (totalCost + currentUnitPrice) then
      totalCost = totalCost + currentUnitPrice
      actualTraded = actualTraded + 1
    else
      break
    end
  end

  if actualTraded > 0 then
    buyer.gold = buyer.gold - totalCost
    city.gold = (city.gold or 0) + totalCost

    city:removeStock(goodId, actualTraded)
    buyer.inventory[goodId] = (buyer.inventory[goodId] or 0) + actualTraded

    city.prices[goodId] = Prices.calculate(baseGoodData.basePrice, city:getStock(goodId), city.population, randomFactor)

    table.insert(self.log, { type = "buy", goodId = goodId, amount = actualTraded, totalPrice = totalCost, avgPrice = totalCost / actualTraded })
    EventBus:emit("trade:completed", { type = "buy", goodId = goodId, amount = actualTraded, totalPrice = totalCost, city = city })
  end

  return actualTraded
end

function TradeSystem:sell(seller, city, goodId, maxAmount, baseGoodData, randomFactor)
  local totalRevenue = 0
  local actualTraded = 0

  local currentInventory = seller.inventory[goodId] or 0
  if currentInventory <= 0 or (city.gold or 0) <= 0 then return 0 end

  local loopAmount = math.min(maxAmount, currentInventory)

  for i = 1, loopAmount do
    local tempCity = getTempCityState(city, goodId, actualTraded)
    local currentUnitPrice = Prices.calculate(baseGoodData.basePrice, tempCity:getStock(), city.population, randomFactor)

    if city.gold >= (totalRevenue + currentUnitPrice) then
      totalRevenue = totalRevenue + currentUnitPrice
      actualTraded = actualTraded + 1
    else
      break
    end
  end

  if actualTraded > 0 then
    seller.gold = (seller.gold or 0) + totalRevenue
    city.gold = city.gold - totalRevenue

    seller.inventory[goodId] = currentInventory - actualTraded
    city:addStock(goodId, actualTraded)

    city.prices[goodId] = Prices.calculate(baseGoodData.basePrice, city:getStock(goodId), city.population, randomFactor)

    table.insert(self.log, { type = "sell", goodId = goodId, amount = actualTraded, totalPrice = totalRevenue, avgPrice = totalRevenue / actualTraded })
    EventBus:emit("trade:completed", { type = "sell", goodId = goodId, amount = actualTraded, totalPrice = totalRevenue, city = city })
  end

  return actualTraded
end

return TradeSystem
