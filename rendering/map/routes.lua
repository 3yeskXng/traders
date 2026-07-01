--- Rendering trade routes between ports and active routes.
-- Handles all trade route visualization on the map.
local MapRoutes = {}

function MapRoutes.drawRoutes(world, w, h)
  -- Get all port cities for route drawing
  local cities = world.cities:getAll()
  local player = world.players[1]
  local routeCities = {}
  
  for _, c in ipairs(cities) do
    if c.hasPort then table.insert(routeCities, c) end
  end

  -- Draw possible trade routes between all port cities
  for i = 1, #routeCities do
    for j = i + 1, #routeCities do
      local a, b = routeCities[i], routeCities[j]
      local ax, ay = a.x * w, a.y * h
      local bx, by = b.x * w, b.y * h

      -- Draw dashed line for possible routes
      love.graphics.setColor(0.35, 0.25, 0.15, 0.15)
      love.graphics.setLineWidth(1.5)
      
      -- Create dashed line effect
      local dashLen = 8
      local gapLen = 4
      local totalLen = dashLen + gapLen
      local dx, dy = bx - ax, by - ay
      local dist = math.sqrt(dx * dx + dy * dy)
      
      if dist > 0 then
        local segments = math.floor(dist / totalLen)
        for k = 0, segments do
          local t1 = (k * totalLen) / dist
          local t2 = math.min((k * totalLen + dashLen) / dist, 1)
          love.graphics.line(
            ax + dx * t1, ay + dy * t1,
            ax + dx * t2, ay + dy * t2
          )
        end
      end
      
      love.graphics.setLineWidth(1)
    end
  end

  -- Draw active player routes from current city
  if player and player.currentCityId then
    local pc = world.cities:getById(player.currentCityId)
    if pc then
      love.graphics.setColor(0.8, 0.7, 0.2, 0.3)
      love.graphics.setLineWidth(2)
      for _, c in ipairs(routeCities) do
        if c.id ~= pc.id then
          love.graphics.line(pc.x * w, pc.y * h, c.x * w, c.y * h)
        end
      end
      love.graphics.setLineWidth(1)
    end
  end
end

return MapRoutes
