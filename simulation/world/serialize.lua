local Serialize = {}

function Serialize.snapshot(world)
  return {
    cities = world.cities:serialize(),
    ships = world.ships:serialize(),
    time = world.time:serialize(),
    travel = world.travel:serialize(),
  }
end

return Serialize
