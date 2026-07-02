local EventBus = require("core.eventbus")
local Components = require("ui.components")

local Keyboard = {}

function Keyboard.keypressed(settings, key)
  if key == "escape" then
    EventBus:emit("state:change", "mainmenu")
    return
  end

  if key == "up" then
    settings.selected = math.max(1, settings.selected - 1)
    return
  end

  if key == "down" then
    settings.selected = math.min(#settings.items, settings.selected + 1)
    return
  end

  if key == "left" or key == "right" then
    local item = settings.items[settings.selected]
    if item.type == "slider" then
      item.value = math.max(
        item.min,
        math.min(item.max, item.value + (key == "right" and 5 or -5))
      )
    elseif item.type == "toggle" then
      item.value = not item.value
    elseif item.type == "choice" then
      local index = 1
      for i, option in ipairs(item.options) do
        if option == item.value then
          index = i
          break
        end
      end
      index = index + (key == "right" and 1 or -1)
      if index < 1 then
        index = #item.options
      end
      if index > #item.options then
        index = 1
      end
      item.value = item.options[index]
      if item.key == "language" then
        EventBus:emit("language:change", item.value)
      elseif item.key == "uiStyle" then
        Components.setTheme(item.value)
      end
    end
    if item.key == "fullscreen" or item.key == "showFPS" then
      EventBus:emit("settings:apply")
    end
    return
  end

  if key == "return" then
    EventBus:emit("state:change", "mainmenu")
  end
end

return Keyboard
