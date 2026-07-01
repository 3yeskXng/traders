local City = {}
City.__index = City

function City.new(data)
  local inventory = {}
  if data.initialGoods then
    for id, amount in pairs(data.initialGoods) do
      inventory[id] = amount
    end
  end
  return setmetatable({
    id = data.id,
    name = data.name,
    x = data.x,
    y = data.y,
    population = data.population,
    wealth = data.wealth,
    hasPort = data.hasPort,
    description = data.description or "",
    inventory = inventory,
    prices = {},
    produces = data.produces or {},
    consumes = data.consumes or {},
    taxRate = data.taxRate or 0.05,
    portFee = data.portFee or 2,
  }, City)
end

function City:getStock(goodId)
  return self.inventory[goodId] or 0
end

function City:addStock(goodId, amount)
  self.inventory[goodId] = (self.inventory[goodId] or 0) + amount
end

function City:removeStock(goodId, amount)
  local current = self.inventory[goodId] or 0
  if current < amount then return false end
  self.inventory[goodId] = current - amount
  return true
end

function City:serialize()
  return {
    id = self.id, population = self.population, wealth = self.wealth,
    inventory = self.inventory, prices = self.prices,
  }
end

function City:deserialize(data)
  self.population = data.population
  self.wealth = data.wealth
  self.inventory = data.inventory
  if data.prices then self.prices = data.prices end
end

return City
