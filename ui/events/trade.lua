local EventBus = require("core.eventbus")
local Logger = require("core.logger")
local log = Logger.new("events.trade")

local Trade = {}

function Trade.register(worldRef)
  EventBus:on("trade:buy", function(data)
    if worldRef.world and worldRef.world.trade and worldRef.world.goods and data.city and data.goodId then
      local good = worldRef.world.goods:getById(data.goodId)
      if not good then return end
      local amount = worldRef.world.trade:buy(
        worldRef.player, data.city, data.goodId, data.amount or 1, good
      )
      if amount > 0 then
        log:info("Bought %d x %s", amount, data.goodId)
      end
    end
  end)

  EventBus:on("trade:sell", function(data)
    if worldRef.world and worldRef.world.trade and worldRef.world.goods and data.city and data.goodId then
      local good = worldRef.world.goods:getById(data.goodId)
      if not good then log:warn("sell: good not found for %s", data.goodId) return end
      log:warn("sell: player=%s, city=%s, goodId=%s, amount=%d, inventory=%d, cityGold=%s",
        worldRef.player and worldRef.player.id or "nil",
        data.city and data.city.id or "nil",
        data.goodId, data.amount or 1,
        (worldRef.player.inventory[data.goodId] or 0),
        tostring(data.city.gold))
      local amount = worldRef.world.trade:sell(
        worldRef.player, data.city, data.goodId, data.amount or 1, good
      )
      log:warn("sell: result=%d", amount)
      if amount > 0 then
        log:info("Sold %d x %s", amount, data.goodId)
      end
    end
  end)
end

return Trade
