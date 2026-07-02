local Goods = {}
Goods.__index = Goods

function Goods.new(data)
  return setmetatable({
    id = data.id,
    name = data.name,
    basePrice = data.basePrice,
    baseProduction = data.baseProduction,
    unit = data.unit,
    category = data.category,
    weight = data.weight or 1,
    perishable = data.perishable or false,
  }, Goods)
end

return Goods
