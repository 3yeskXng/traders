local Components = require("ui.components")
local Translator = require("core.translator")

local BottomBar = {}

function BottomBar.draw(InGame, w, h, world)
  Components.drawPanel(0, h - 35, w, 35, nil)
  local speedLabel = world.time:getSpeedLabel()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(Translator:t("status.speed", speedLabel), 10, h - 27)
  love.graphics.print(Translator:t("status.pause_hint"), 200, h - 27)
  if world.travel.traveling and InGame.currentCity then
    love.graphics.setColor(1, 0.8, 0.2)
    local progress = math.floor(world.travel.progress * 100)
    love.graphics.printf(Translator:t("status.traveling_to", world.travel.to.name, progress), 0, h - 27, w - 10, "right")
  elseif InGame.currentCity then
    love.graphics.setColor(0.5, 0.8, 0.5)
    love.graphics.printf(Translator:t("status.in_city", InGame.currentCity.name), 0, h - 27, w - 10, "right")
  end
end

return BottomBar
