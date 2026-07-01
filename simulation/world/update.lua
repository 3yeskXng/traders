local Bootstrap = require("simulation.world.bootstrap")

local Update = {}

function Update.tick(world, dt)
  local dayPassed = world.time:update(dt)
  world.travel:update(dt, world.time:getSpeed())
  if dayPassed then
    Bootstrap.updateEconomy(world)
    for _, trader in ipairs(world.aiTraders) do
      trader:update(world)
    end
  end
end

return Update
