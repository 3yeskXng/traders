local Updater = {}

function Updater.update(renderer, dt, world)
  renderer.time = renderer.time + dt
  renderer.routeAnimProgress = (renderer.routeAnimProgress + dt * 0.1) % 1
  renderer.camera:update(dt)

  if renderer._centerOnArrival and world and world.players[1] then
    local player = world.players[1]
    local city = player.currentCityId and world.cities:getById(player.currentCityId)
    if city then
      local w, h = love.graphics.getDimensions()
      renderer.camera:setTarget(city.x * w - w / 2, city.y * h - h / 2)
      local dist = math.abs(renderer.camera.x - renderer.camera.targetX)
        + math.abs(renderer.camera.y - renderer.camera.targetY)
      if dist < 5 then
        renderer._centerOnArrival = false
      end
    else
      renderer._centerOnArrival = false
    end
  end
end

return Updater
