local EventBus = require("core.eventbus")
local Components = require("ui.components")

local Mouse = {}

function Mouse.pressed(settings, x, y, button)
  local w, h = love.graphics.getDimensions()

  if Components.isInRect(x, y, w * 0.45, h * 0.7, 150, 35) then
    EventBus:emit("state:change", "mainmenu")
    return
  end

  local px, py = w * 0.35, h * 0.25
  for i, item in ipairs(settings.items) do
    local itemY = py + (i - 1) * 35
    local rowRect = { x = px, y = itemY, w = 280, h = 20 }
    if Components.isInRect(x, y, rowRect.x, rowRect.y, rowRect.w, rowRect.h) then
      if item.type == "toggle" then
        item.value = not item.value
        if item.key == "fullscreen" or item.key == "showFPS" then
          EventBus:emit("settings:apply")
        end
      elseif item.type == "choice" then
        local index = 1
        for j, option in ipairs(item.options) do
          if option == item.value then
            index = j
            break
          end
        end
        index = index % #item.options + 1
        item.value = item.options[index]
        if item.key == "language" then
          EventBus:emit("language:change", item.value)
        elseif item.key == "uiStyle" then
          Components.setTheme(item.value)
        end
      elseif item.type == "slider" then
        item.value = math.max(
          item.min,
          math.min(item.max, item.value + 5)
        )
      end
      settings.selected = i
      return
    end
  end
end

return Mouse
