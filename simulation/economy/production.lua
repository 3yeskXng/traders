local Logger = require("core.logger")
local log = Logger.new("production")

local Production = {}

local EFFICIENCY_FACTOR = 0.1

function Production.run(city, goods)
  for _, goodId in ipairs(city.produces) do
    local good = goods.byId[goodId]
    if good then
      local output = good.baseProduction * EFFICIENCY_FACTOR * (city.population / 1000)
      output = math.max(1, math.floor(output))
      city:addStock(goodId, output)
    end
  end
end

return Production
