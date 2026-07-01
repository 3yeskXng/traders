local Components = require("ui.components")

local MapCities = {}

function MapCities.drawCities(mapRenderer, w, h, world)
  for _, city in ipairs(world.cities:getAll()) do
    local sx, sy = city.x * w, city.y * h
    local isHover = city == mapRenderer.hoveredCity
    local player = world.players[1]
    local isPlayer = player and player.currentCityId == city.id
    local isSelected = mapRenderer.selectedCity and city.id == mapRenderer.selectedCity.id

    MapCities.drawCityIcon(sx, sy, city, isHover, isPlayer, isSelected)
  end
end

function MapCities.drawCityIcon(sx, sy, city, isHover, isPlayer, isSelected)
  local scale = (isHover or isSelected) and 1.3 or 1
  local size = 10 * scale

  if isSelected then
    love.graphics.setColor(1, 0.8, 0.3, 0.25)
    love.graphics.circle("fill", sx, sy, size * 2.5)
  end

  if isPlayer then
    love.graphics.setColor(1, 0.9, 0.3, 0.2)
    love.graphics.circle("fill", sx, sy, size * 1.8)
  end

  if city.hasPort then
    love.graphics.setColor(0.15, 0.5, 0.85)
    love.graphics.rectangle("fill", sx - size * 0.5, sy - size * 0.3, size, size * 0.6)
    love.graphics.setColor(0.25, 0.65, 0.95)
    love.graphics.rectangle("fill", sx - size * 0.35, sy - size * 0.5, size * 0.7, size * 0.7)
    love.graphics.setColor(0.12, 0.4, 0.7)
    love.graphics.rectangle("line", sx - size * 0.35, sy - size * 0.5, size * 0.7, size * 0.7)

    love.graphics.setColor(0.5, 0.3, 0.15)
    love.graphics.rectangle("fill", sx - size * 0.15, sy + size * 0.2, size * 0.3, size * 0.3)
  else
    love.graphics.setColor(0.6, 0.35, 0.15)
    love.graphics.rectangle("fill", sx - size * 0.4, sy - size * 0.2, size * 0.8, size * 0.5)
    love.graphics.setColor(0.7, 0.4, 0.2)
    love.graphics.polygon("fill", sx, sy - size * 0.6, sx - size * 0.4, sy - size * 0.15, sx + size * 0.4, sy - size * 0.15)
    love.graphics.setColor(0.5, 0.3, 0.12)
    love.graphics.rectangle("line", sx - size * 0.4, sy - size * 0.2, size * 0.8, size * 0.5)
    love.graphics.rectangle("line", sx - size * 0.3, sy - size * 0.1, size * 0.25, size * 0.2)
    love.graphics.rectangle("line", sx + size * 0.05, sy - size * 0.1, size * 0.25, size * 0.2)
  end

  if isHover then
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.circle("fill", sx, sy, 2)
  end
end

function MapCities.drawCityLabel(w, h, world, mapRenderer)
  for _, city in ipairs(world.cities:getAll()) do
    local sx, sy = city.x * w, city.y * h
    local isHover = city == mapRenderer.hoveredCity
    local player = world.players[1]
    local isPlayer = player and player.currentCityId == city.id

    local label = city.name
    local labelY = sy - 16

    if isHover then
      labelY = sy - 22
      love.graphics.setColor(0.9, 0.85, 0.4)
      love.graphics.setFont(love.graphics.newFont(14))
      label = city.name .. " (" .. Components.formatNumber(city.population) .. ")"
    elseif isPlayer then
      love.graphics.setColor(1, 0.9, 0.5)
      love.graphics.setFont(love.graphics.newFont(12))
    else
      love.graphics.setColor(0.95, 0.9, 0.7)
      love.graphics.setFont(love.graphics.newFont(11))
    end

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(label, sx + 10, labelY - 1)
    love.graphics.print(label, sx + 12, labelY + 1)
    love.graphics.print(label, sx + 10, labelY + 1)
    love.graphics.print(label, sx + 12, labelY - 1)

    love.graphics.setColor(isHover and 1 or 0.95, (isHover or isPlayer) and 0.9 or 0.9, isPlayer and 0.5 or 0.7)
    love.graphics.print(label, sx + 11, labelY)
  end

  love.graphics.setFont(love.graphics.newFont(12))
end

return MapCities
