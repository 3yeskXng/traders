local Components = require("ui.components")
local Translator = require("core.translator")

local Draw = {}

function Draw.render(settings)
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0.1, 0.12, 0.2)
  love.graphics.rectangle("fill", 0, 0, w, h)
  Components.drawPanel(
    w * 0.3, h * 0.15, w * 0.4, h * 0.5,
    Translator:t("settings.title")
  )

  local px, py = w * 0.35, h * 0.25
  for i, item in ipairs(settings.items) do
    local hover = i == settings.selected
    love.graphics.setColor(
      hover and 0.8 or 0.6,
      hover and 0.7 or 0.5,
      hover and 0.3 or 0.2
    )
    love.graphics.print(Translator:t(item.labelKey), px, py)

    if item.type == "slider" then
      Components.drawSlider(px + 200, py, 150, item.value, item.min, item.max)
    elseif item.type == "toggle" then
      love.graphics.printf(
        item.value and Translator:t("common.yes") or Translator:t("common.no"),
        px + 300, py, 50, "left"
      )
    elseif item.type == "choice" then
      local choiceText = Translator:t("language." .. item.value)
      love.graphics.printf(choiceText, px + 300, py, 100, "left")
    end

    py = py + 35
  end

  Components.drawButton(
    Translator:t("menu.back"),
    w * 0.45, h * 0.7, 150, 35, false
  )
end

return Draw
