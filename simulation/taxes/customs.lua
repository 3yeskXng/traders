local Customs = {}

function Customs.calculate(goodValue, rate)
  rate = rate or 0.03
  return math.floor(goodValue * rate)
end

function Customs.calculateForGoods(goods, prices, rate)
  local total = 0
  for goodId, amount in pairs(goods) do
    local goodValue = (prices[goodId] or 0) * amount
    total = total + Customs.calculate(goodValue, rate)
  end
  return total
end

return Customs
