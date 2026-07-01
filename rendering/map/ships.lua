--- Rendering player ships on the map.
-- Handles ship visualization during travel and at ports.
local MapShips = {}

function MapShips.drawPlayerShip(w, h, world, time)
  -- Check if player is traveling
  local tx, ty = world.travel:getPosition()
  if tx then
    local px, py = tx * w, ty * h
    local angle = time * 2
    
    -- Draw rotating ship during travel
    love.graphics.setColor(0.6, 0.45, 0.2)
    love.graphics.push()
    love.graphics.translate(px, py)
    love.graphics.rotate(angle)
    love.graphics.polygon("fill", 0, -8, -5, 5, 5, 5)
    
    -- Ship sail/cargo indicator
    love.graphics.setColor(0.9, 0.8, 0.3)
    love.graphics.polygon("fill", 0, -6, -3, 3, 3, 3)
    love.graphics.pop()
    
    -- Glow effect around ship
    love.graphics.setColor(1, 1, 0.5, 0.3)
    love.graphics.circle("fill", px, py, 12)
    return
  end
  
  -- Ship at port - draw in city location
  local player = world.players[1]
  if player and player.currentCityId then
    local city = world.cities:getById(player.currentCityId)
    if city then
      local cx, cy = city.x * w, city.y * h
      
      -- Static ship at city
      love.graphics.setColor(0.6, 0.45, 0.2)
      love.graphics.push()
      love.graphics.translate(cx, cy)
      love.graphics.polygon("fill", 0, -8, -5, 5, 5, 5)
      
      -- Ship sail
      love.graphics.setColor(0.9, 0.8, 0.3)
      love.graphics.polygon("fill", 0, -6, -3, 3, 3, 3)
      love.graphics.pop()
    end
  end
end

return MapShips
