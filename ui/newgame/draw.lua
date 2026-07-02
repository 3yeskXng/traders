local Components = require("ui.components")
local Translator = require("core.translator")

local Draw = {}

function Draw.render(newgame)
  local w, h = love.graphics.getDimensions()

  if newgame.world then
    newgame.mapRenderer.selectedCity = newgame.selectedCity
    newgame.mapRenderer:draw(w, h, newgame.world)
  end

  Components.drawPanel(
    w * 0.1, h * 0.08, w * 0.8, h * 0.14,
    Translator:t("newgame.title")
  )
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(
    Translator:t("newgame.description"),
    w * 0.12, h * 0.12, w * 0.76, "left"
  )

  local infoY = h * 0.24
  if newgame.selectedCity then
    love.graphics.printf(
      Translator:t("newgame.start_city", newgame.selectedCity.name),
      w * 0.12, infoY, w * 0.76, "left"
    )
    love.graphics.printf(
      Translator:t("city.population", newgame.selectedCity.population),
      w * 0.12, infoY + 22, w * 0.76, "left"
    )
    love.graphics.printf(
      Translator:t("city.wealth", newgame.selectedCity.wealth),
      w * 0.12, infoY + 44, w * 0.76, "left"
    )
  else
    love.graphics.printf(
      Translator:t("newgame.select_city"),
      w * 0.12, infoY, w * 0.76, "left"
    )
  end

  local buttonW, buttonH = 220, 44
  local bx, by = w * 0.7, h * 0.9 - buttonH
  local startHover = newgame.buttonHover == "start"
  local backHover = newgame.buttonHover == "back"
  Components.drawButton(Translator:t("newgame.start"), bx, by, buttonW, buttonH, startHover)
  Components.drawButton(Translator:t("newgame.back"), bx - buttonW - 20, by, buttonW, buttonH, backHover)
end

return Draw
