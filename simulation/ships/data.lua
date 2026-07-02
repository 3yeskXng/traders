local Ship = {}
Ship.__index = Ship

function Ship.new(data, ownerId)
  return setmetatable({
    id = data.id,
    name = data.name,
    type = data.type or data.id,
    cargoCapacity = data.cargo,
    speed = data.speed,
    crew = data.crew,
    price = data.price,
    description = data.description or "",
    ownerId = ownerId,
    cargo = {},
    cargoUsed = 0,
    currentCityId = nil,
    condition = 100,
  }, Ship)
end

function Ship:getFreeCargo()
  return self.cargoCapacity - self.cargoUsed
end

function Ship:loadCargo(goodId, amount)
  local free = self:getFreeCargo()
  local actual = math.min(amount, free)
  if actual <= 0 then return 0 end
  self.cargo[goodId] = (self.cargo[goodId] or 0) + actual
  self.cargoUsed = self.cargoUsed + actual
  return actual
end

function Ship:unloadCargo(goodId, amount)
  local available = self.cargo[goodId] or 0
  local actual = math.min(amount, available)
  if actual <= 0 then return 0 end
  self.cargo[goodId] = available - actual
  self.cargoUsed = self.cargoUsed - actual
  return actual
end

function Ship:serialize()
  return {
    id = self.id, name = self.name, type = self.type,
    cargo = self.cargo, cargoUsed = self.cargoUsed,
    ownerId = self.ownerId, currentCityId = self.currentCityId,
    condition = self.condition,
  }
end

return Ship
