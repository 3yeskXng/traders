local ShipCargo = {}

function ShipCargo.getTotalWeight(cargo, goods)
  local weight = 0
  for goodId, amount in pairs(cargo) do
    local good = goods.byId[goodId]
    weight = weight + (good and good.weight or 1) * amount
  end
  return weight
end

function ShipCargo.getValue(cargo, prices)
  local value = 0
  for goodId, amount in pairs(cargo) do
    value = value + (prices[goodId] or 0) * amount
  end
  return value
end

function ShipCargo.isEmpty(cargo)
  for _ in pairs(cargo) do return false end
  return true
end

function ShipCargo.count(cargo)
  local total = 0
  for _ in pairs(cargo) do total = total + 1 end
  return total
end

return ShipCargo
