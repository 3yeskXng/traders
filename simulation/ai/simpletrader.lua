local Strategy = require("simulation.ai.strategy")
local Market = require("simulation.trade.market")

local BUY_THRESHOLD = 0.7
local SELL_THRESHOLD = 1.4
local MAX_TRADE_AMOUNT = 20

function SimpleTrader()
  local strategy = Strategy.new("simple")
  function strategy:execute(trader, world)
    local city = world.cities:getById(trader.currentCityId)
    if not city then return end
    for _, good in ipairs(world.goods:getAll()) do
      local price = city.prices[good.id]
      if not price then goto continue end
      if price < good.basePrice * BUY_THRESHOLD and trader.gold > price then
        local amount = math.min(MAX_TRADE_AMOUNT, math.floor(trader.gold / price))
        if amount > 0 then
          trader.gold = trader.gold - amount * price
          trader.inventory[good.id] = (trader.inventory[good.id] or 0) + amount
        end
      elseif price > good.basePrice * SELL_THRESHOLD then
        local stock = trader.inventory[good.id] or 0
        if stock > 0 then
          local amount = math.min(stock, MAX_TRADE_AMOUNT)
          trader.gold = trader.gold + amount * price
          trader.inventory[good.id] = stock - amount
        end
      end
      ::continue::
    end
  end
  return strategy
end

return SimpleTrader
