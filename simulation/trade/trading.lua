local Logger = require("core.logger")
local EventBus = require("core.eventbus")
local log = Logger.new("trading")

local TradeSystem = {}
TradeSystem.__index = TradeSystem

function TradeSystem.new()
  return setmetatable({ log = {} }, TradeSystem)
end

function TradeSystem:buy(buyer, seller, goodId, amount, price)
  local stock = seller:getStock(goodId)
  if stock <= 0 then return 0 end
  local maxCanAfford = math.floor(buyer.gold / price)
  local actual = math.min(amount, stock, maxCanAfford)
  if actual <= 0 then return 0 end
  local cost = actual * price
  buyer.gold = buyer.gold - cost
  seller.wealth = (seller.wealth or 0) + cost
  seller:removeStock(goodId, actual)
  buyer.inventory[goodId] = (buyer.inventory[goodId] or 0) + actual
  table.insert(self.log, { type = "buy", goodId = goodId, amount = actual, price = price })
  EventBus:emit("trade:completed", { type = "buy", goodId = goodId, amount = actual, price = price, city = seller })
  return actual
end

function TradeSystem:sell(seller, buyer, goodId, amount, price)
  local stock = seller.inventory[goodId] or 0
  if stock <= 0 then return 0 end
  local maxBuyerCanAfford = math.floor((buyer.wealth or buyer.gold or 0) / price)
  local actual = math.min(amount, stock, maxBuyerCanAfford)
  if actual <= 0 then return 0 end
  local revenue = actual * price
  seller.gold = (seller.gold or 0) + revenue
  buyer.wealth = (buyer.wealth or 0) - revenue
  seller.inventory[goodId] = stock - actual
  buyer:addStock(goodId, actual)
  table.insert(self.log, { type = "sell", goodId = goodId, amount = actual, price = price })
  EventBus:emit("trade:completed", { type = "sell", goodId = goodId, amount = actual, price = price, city = buyer })
  return actual
end

return TradeSystem
