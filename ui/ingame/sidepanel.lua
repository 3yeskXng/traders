local Components = require("ui.components")
local Translator = require("core.translator")
local Utils = require("core.utils")

local SidePanel = {}

function SidePanel.draw(InGame, w, h, world)
  local panelWidth = math.min(260, w * 0.2)
  local panelHeight = h - 40 - 35
  Components.drawPanel(10, 40, panelWidth, panelHeight, Translator:t("status.title"))

  local x = 20
  local y = 70
  love.graphics.setColor(1, 1, 1)
  local player = world.players[1]
  love.graphics.print(Translator:t("status.gold", Utils.formatNumber(player.gold)), x, y)
  y = y + 22

  if InGame.currentCity then
    love.graphics.print(Translator:t("status.city", InGame.currentCity.name), x, y)
    y = y + 20
    love.graphics.print(Translator:t("status.population", Utils.formatNumber(InGame.currentCity.population)), x, y)
    y = y + 20
    love.graphics.print(Translator:t("status.wealth", Utils.formatNumber(InGame.currentCity.wealth)), x, y)
    y = y + 20
    love.graphics.print(Translator:t("status.port", InGame.currentCity.hasPort and Translator:t("common.yes") or Translator:t("common.no")), x, y)
    y = y + 24
    love.graphics.setColor(0.8, 0.9, 1)
    love.graphics.print(Translator:t("status.production"), x, y)
    y = y + 18
    love.graphics.setColor(1, 1, 1)
    for _, goodId in ipairs(InGame.currentCity.produces) do
      love.graphics.print("• " .. goodId, x + 6, y)
      y = y + 16
    end
    y = y + 6
    love.graphics.setColor(0.9, 0.8, 0.7)
    love.graphics.print(Translator:t("status.demand"), x, y)
    y = y + 18
    love.graphics.setColor(1, 1, 1)
    for _, goodId in ipairs(InGame.currentCity.consumes) do
      love.graphics.print("• " .. goodId, x + 6, y)
      y = y + 16
    end
    y = y + 8
  end

  love.graphics.setColor(0.6, 0.8, 0.6)
  love.graphics.print(Translator:t("status.fleet"), x, y)
  y = y + 18
  love.graphics.setColor(1, 1, 1)
  local ships = world.ships:getShipsByOwner(player.id)
  if #ships == 0 then
    love.graphics.print(Translator:t("status.no_ships"), x, y)
    y = y + 18
  else
    for _, ship in ipairs(ships) do
      local locationLabel = ship.currentCityId and (world.cities:getById(ship.currentCityId) and world.cities:getById(ship.currentCityId).name or Translator:t("status.unknown")) or Translator:t("status.traveling")
      love.graphics.print(ship.name .. " (" .. locationLabel .. ")", x, y)
      y = y + 16
      love.graphics.print(Translator:t("status.cargo", ship.cargoUsed, ship.cargoCapacity), x + 8, y)
      y = y + 16
      love.graphics.print(Translator:t("status.speed_condition", ship.speed, ship.condition), x + 8, y)
      y = y + 20
      if y > panelHeight - 40 then break end
    end
  end

  if world.travel.traveling and world.travel.to then
    love.graphics.setColor(0.8, 0.9, 1)
    love.graphics.print(Translator:t("status.travel_to"), x, y)
    y = y + 18
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(world.travel.to.name, x + 6, y)
    y = y + 18
    love.graphics.print(Translator:t("status.progress", math.floor(world.travel.progress * 100)), x + 6, y)
  end
end

return SidePanel
