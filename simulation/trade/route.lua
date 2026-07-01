local TradeRoute = {}
TradeRoute.__index = TradeRoute

function TradeRoute.new(data)
  return setmetatable({
    name = data.name or "Unnamed Route",
    originId = data.originId,
    destinationId = data.destinationId,
    goodId = data.goodId,
    buyAmount = data.buyAmount or 10,
    sellAmount = data.sellAmount or 10,
    active = data.active or false,
    shipId = data.shipId,
  }, TradeRoute)
end

function TradeRoute:serialize()
  return {
    name = self.name, originId = self.originId, destinationId = self.destinationId,
    goodId = self.goodId, buyAmount = self.buyAmount, sellAmount = self.sellAmount,
    active = self.active, shipId = self.shipId,
  }
end

return TradeRoute
