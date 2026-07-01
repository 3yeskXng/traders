local Utils = require("core.utils")

local ShipSpeed = {}

local MAX_CARGO_PENALTY = 0.5
local MIN_CONDITION_SPEED = 0.3

function ShipSpeed.calculate(baseSpeed, cargoUsed, cargoCapacity, condition)
  local cargoRatio = cargoCapacity > 0 and cargoUsed / cargoCapacity or 0
  local cargoPenalty = 1 - cargoRatio * MAX_CARGO_PENALTY
  local conditionFactor = Utils.lerp(MIN_CONDITION_SPEED, 1, condition / 100)
  return baseSpeed * cargoPenalty * conditionFactor
end

function ShipSpeed.getTravelDays(distance, effectiveSpeed)
  if effectiveSpeed <= 0 then return 999 end
  return math.max(1, math.floor(distance * 10 / effectiveSpeed))
end

return ShipSpeed
