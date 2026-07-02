local Logger = require("core.logger")
local Ship = require("simulation.ships.data")
local log = Logger.new("shipmanager")

local ShipManager = {}
ShipManager.__index = ShipManager

function ShipManager.new()
  return setmetatable({ types = {}, ships = {} }, ShipManager)
end

function ShipManager:loadTypes(data)
  for _, entry in ipairs(data) do
    self.types[entry.id] = entry
  end
  log:info("Loaded %d ship types", #data)
end

function ShipManager:getType(id)
  return self.types[id]
end

function ShipManager:createShip(typeId, ownerId)
  local typeData = self.types[typeId]
  if not typeData then return nil end
  local ship = Ship.new(typeData, ownerId)
  table.insert(self.ships, ship)
  log:info("Created ship %s for owner %s", ship.name, ownerId)
  return ship
end

function ShipManager:getShipsByOwner(ownerId)
  local owned = {}
  for _, ship in ipairs(self.ships) do
    if ship.ownerId == ownerId then table.insert(owned, ship) end
  end
  return owned
end

function ShipManager:serialize()
  local data = {}
  for _, ship in ipairs(self.ships) do
    table.insert(data, ship:serialize())
  end
  return data
end

function ShipManager:deserialize(data)
  if not data then return end
  self.ships = {}
  for _, entry in ipairs(data) do
    local ship = Ship.new(entry.typeData or {}, entry.ownerId)
    ship.id = entry.id
    ship.name = entry.name or ship.name
    ship.ownerId = entry.ownerId
    ship.currentCityId = entry.currentCityId
    ship.cargo = entry.cargo or {}
    table.insert(self.ships, ship)
  end
end

return ShipManager
