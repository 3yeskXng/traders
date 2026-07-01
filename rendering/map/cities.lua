--- Rendering cities, their icons, labels, and tooltips.
-- Handles all city-related visual elements on the map.
local Components = require("ui.components")
local Translator = require("core.translator")
local MapCities = {}

function MapCities.drawCities(mapRenderer, w, h, world)
  -- Draw all cities on the map
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
  -- Highlight when selected or hovered
  local scale = (isHover or isSelected) and 1.3 or 1
  local size = 10 * scale

  -- Selection highlight circle
  if isSelected then
    love.graphics.setColor(1, 0.8, 0.3, 0.25)
    love.graphics.circle("fill", sx, sy, size * 2.5)
  end

  -- Player location highlight
  if isPlayer then
    love.graphics.setColor(1, 0.9, 0.3, 0.2)
    love.graphics.circle("fill", sx, sy, size * 1.8)
  end

  -- Draw port or town icon
  if city.hasPort then
    -- Port icon: anchor symbol
    love.graphics.setColor(0.15, 0.5, 0.85)
    love.graphics.rectangle("fill", sx - size * 0.5, sy - size * 0.3, size, size * 0.6)
    love.graphics.setColor(0.25, 0.65, 0.95)
    love.graphics.rectangle("fill", sx - size * 0.35, sy - size * 0.5, size * 0.7, size * 0.7)
    love.graphics.setColor(0.12, 0.4, 0.7)
    love.graphics.rectangle("line", sx - size * 0.35, sy - size * 0.5, size * 0.7, size * 0.7)

    -- Anchor base
    love.graphics.setColor(0.5, 0.3, 0.15)
    love.graphics.rectangle("fill", sx - size * 0.15, sy + size * 0.2, size * 0.3, size * 0.3)
  else
    -- Town icon: house with roof
    love.graphics.setColor(0.6, 0.35, 0.15)
    love.graphics.rectangle("fill", sx - size * 0.4, sy - size * 0.2, size * 0.8, size * 0.5)
    love.graphics.setColor(0.7, 0.4, 0.2)
    love.graphics.polygon("fill", sx, sy - size * 0.6, sx - size * 0.4, sy - size * 0.15, sx + size * 0.4, sy - size * 0.15)
    love.graphics.setColor(0.5, 0.3, 0.12)
    love.graphics.rectangle("line", sx - size * 0.4, sy - size * 0.2, size * 0.8, size * 0.5)
    love.graphics.rectangle("line", sx - size * 0.3, sy - size * 0.1, size * 0.25, size * 0.2)
    love.graphics.rectangle("line", sx + size * 0.05, sy - size * 0.1, size * 0.25, size * 0.2)
  end

  -- Hover indicator dot
  if isHover then
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.circle("fill", sx, sy, 2)
  end
end

function MapCities.drawCityLabel(w, h, world, mapRenderer)
  -- Draw city names on the map with dynamic styling
  for _, city in ipairs(world.cities:getAll()) do
    local sx, sy = city.x * w, city.y * h
    local isHover = city == mapRenderer.hoveredCity
    local player = world.players[1]
    local isPlayer = player and player.currentCityId == city.id

    local label = city.name
    local labelY = sy - 16

    -- Adjust styling and label content based on state
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

    -- Draw shadow for text legibility
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(label, sx + 10, labelY - 1)
    love.graphics.print(label, sx + 12, labelY + 1)
    love.graphics.print(label, sx + 10, labelY + 1)
    love.graphics.print(label, sx + 12, labelY - 1)
    
    -- Draw main text
    love.graphics.setColor(isHover and 1 or 0.95, (isHover or isPlayer) and 0.9 or 0.9, isPlayer and 0.5 or 0.7)
    love.graphics.print(label, sx + 11, labelY)
  end
  
  -- Reset font
  love.graphics.setFont(love.graphics.newFont(12))
end

function MapCities.drawCityTooltip(w, h, city, world, mx, my)
  -- Draw detailed tooltip for hovered city
  local goods = world and world.goods
  if not goods then return end

  local tw, th = 200, 80
  local tx = math.min(mx + 15, w - tw - 10)
  local ty = math.min(my + 15, h - th - 10)

  -- Tooltip background
  love.graphics.setColor(0.88, 0.82, 0.72, 0.95)
  love.graphics.rectangle("fill", tx, ty, tw, th)
  love.graphics.setColor(0.35, 0.25, 0.15)
  love.graphics.rectangle("line", tx, ty, tw, th)

  -- City name
  love.graphics.setColor(0.3, 0.2, 0.1)
  love.graphics.setFont(love.graphics.newFont(13))
  love.graphics.print(city.name, tx + 5, ty + 3)
  love.graphics.setFont(love.graphics.newFont(11))
  
  -- Population and wealth
  love.graphics.setColor(0.4, 0.3, 0.15)
  love.graphics.print(Translator:t("tooltip.population", Components.formatNumber(city.population)), tx + 5, ty + 20)
  love.graphics.print(Translator:t("tooltip.wealth", Components.formatNumber(city.wealth)), tx + 5, ty + 33)

  -- Produced goods
  local produces = {}
  for _, pid in ipairs(city.produces) do
    local g = goods.byId and goods.byId[pid]
    table.insert(produces, g and g.name or pid)
  end
  if #produces > 0 then
    love.graphics.setColor(0.3, 0.55, 0.2)
    love.graphics.print(Translator:t("tooltip.produces", table.concat(produces, ", ")), tx + 5, ty + 48)
  end

  -- Consumed goods
  local consumes = {}
  for _, cid in ipairs(city.consumes) do
    local g = goods.byId and goods.byId[cid]
    table.insert(consumes, g and g.name or cid)
  end
  if #consumes > 0 then
    love.graphics.setColor(0.7, 0.25, 0.2)
    love.graphics.print(Translator:t("tooltip.consumes", table.concat(consumes, ", ")), tx + 5, ty + 63)
  end
  
  love.graphics.setFont(love.graphics.newFont(12))
end

return MapCities
