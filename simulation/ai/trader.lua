local Logger = require("core.logger")
local log = Logger.new("trader")

local Trader = {}
Trader.__index = Trader

function Trader.new(data)
  return setmetatable({
    id = data.id,
    name = data.name,
    gold = data.gold or 5000,
    inventory = {},
    strategy = nil,
    currentCityId = data.cityId,
    ships = {},
  }, Trader)
end

function Trader:setStrategy(strategy)
  self.strategy = strategy
end

function Trader:update(world)
  if self.strategy then
    self.strategy:execute(self, world)
  end
end

function Trader:serialize()
  return {
    id = self.id, name = self.name, gold = self.gold,
    inventory = self.inventory, currentCityId = self.currentCityId,
  }
end

return Trader
