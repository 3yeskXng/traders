local Components = require("ui.components")
local Translator = require("core.translator")
local Utils = require("core.utils")

local TopBar = {}

function TopBar.draw(InGame, w, h, world)
  Components.drawPanel(0, 0, w, 30, nil)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(world.time:getDateString(), 10, 7)
  if InGame.currentCity then
    love.graphics.setColor(0.6, 0.8, 1)
    love.graphics.print(Translator:t("status.city", InGame.currentCity.name), 220, 7)
  end
  love.graphics.setColor(0.8, 0.7, 0.2)
  if world.players[1] then
    love.graphics.printf(Translator:t("status.gold", Utils.formatNumber(world.players[1].gold)), 0, 7, w - 10, "right")
  end
end

return TopBar
