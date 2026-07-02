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
      if not good then return end
      local amount = worldRef.world.trade:sell(
        worldRef.player, data.city, data.goodId, data.amount or 1, good
      )
      if amount > 0 then
        log:info("Sold %d x %s", amount, data.goodId)
      end
    end
  end)
end

return Trade
