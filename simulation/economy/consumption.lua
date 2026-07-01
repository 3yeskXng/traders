local Logger = require("core.logger")
local log = Logger.new("consumption")

local Consumption = {}

local CONSUMPTION_RATE = 0.12

function Consumption.run(city, goods)
  for _, goodId in ipairs(city.consumes) do
    local stock = city:getStock(goodId)
    if stock > 0 then
      local consumed = math.max(1, math.floor(stock * CONSUMPTION_RATE))
      city:removeStock(goodId, consumed)
    end
  end
end

return Consumption
