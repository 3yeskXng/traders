local Player = {}
Player.__index = Player

function Player.new(id, name)
  return setmetatable({
    id = id or "player",
    name = name or "Spieler",
    gold = 5000,
    inventory = {},
    currentCityId = nil,
  }, Player)
end

function Player:getStock(goodId)
  return self.inventory[goodId] or 0
end

function Player:addStock(goodId, amount)
  self.inventory[goodId] = (self.inventory[goodId] or 0) + amount
end

function Player:removeStock(goodId, amount)
  local current = self.inventory[goodId] or 0
  if current < amount then return false end
  self.inventory[goodId] = current - amount
  return true
end

function Player:serialize()
  return {
    id = self.id, name = self.name, gold = self.gold,
    inventory = self.inventory, currentCityId = self.currentCityId,
  }
end

return Player
