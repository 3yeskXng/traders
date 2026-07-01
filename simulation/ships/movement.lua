local Logger = require("core.logger")
local Distance = require("simulation.travel.distance")
local log = Logger.new("shipmovement")

local ShipMovement = {}

function ShipMovement.calculateTravelTime(ship, from, to)
  local dist = Distance.between(from, to)
  return math.max(1, math.floor(dist * 10 / ship.speed + 1))
end

function ShipMovement.move(ship, destinationId, cities)
  if ship.currentCityId == destinationId then return false end
  ship.currentCityId = destinationId
  log:info("Ship %s moved to %s", ship.name, destinationId)
  return true
end

return ShipMovement
