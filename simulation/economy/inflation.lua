local Utils = require("core.utils")

local Inflation = {}

local BASE_INFLATION_RATE = 0.001
local SUPPLY_SHORTAGE_FACTOR = 0.01

function Inflation.calculate(goods, cities)
  local totalMoney = 0
  local totalGoods = 0
  for _, city in ipairs(cities) do
    totalMoney = totalMoney + city.wealth
    for _, amount in pairs(city.inventory) do
      totalGoods = totalGoods + amount
    end
  end
  if totalGoods == 0 then return 1.0 end
  local ratio = totalMoney / totalGoods
  return 1 + (ratio - 1) * 0.001
end

return Inflation
