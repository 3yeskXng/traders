local EventBus = require("core.eventbus")
local Components = require("ui.components")
local Config = require("core.config")
local Translator = require("core.translator")

local Settings = {}

function Settings.enter()
  Settings.items = {
    { labelKey = "settings.language", key = "language", type = "choice", options = { "de", "en", "zh" }, value = Config.language or "de" },
    { labelKey = "settings.ui_style", key = "uiStyle", type = "choice", options = { "retro", "clean" }, value = Config.uiStyle or "retro" },
    { labelKey = "settings.master_volume", key = "masterVolume", type = "slider", min = 0, max = 100, value = Config.masterVolume or 80 },
    { labelKey = "settings.music_volume", key = "musicVolume", type = "slider", min = 0, max = 100, value = Config.musicVolume or 70 },
    { labelKey = "settings.sfx_volume", key = "sfxVolume", type = "slider", min = 0, max = 100, value = Config.sfxVolume or 80 },
    { labelKey = "settings.show_fps", key = "showFPS", type = "toggle", value = Config.showFPS or false },
    { labelKey = "settings.fullscreen", key = "fullscreen", type = "toggle", value = Config.fullscreen or false },
  }
  Settings.selected = 1
end

function Settings.leave()
  for _, item in ipairs(Settings.items) do Config[item.key] = item.value end
  Config:save("data/settings.json")
end

function Settings.update(dt) end

function Settings.draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0.1, 0.12, 0.2)
  love.graphics.rectangle("fill", 0, 0, w, h)
  Components.drawPanel(w * 0.3, h * 0.15, w * 0.4, h * 0.5, Translator:t("settings.title"))
  local px, py = w * 0.35, h * 0.25
  for i, item in ipairs(Settings.items) do
    local hover = i == Settings.selected
    love.graphics.setColor(hover and 0.8 or 0.6, hover and 0.7 or 0.5, hover and 0.3 or 0.2)
    love.graphics.print(Translator:t(item.labelKey), px, py)
    if item.type == "slider" then
      Components.drawSlider(px + 200, py, 150, item.value, item.min, item.max)
    elseif item.type == "toggle" then
      love.graphics.printf(item.value and Translator:t("common.yes") or Translator:t("common.no"), px + 300, py, 50, "left")
    elseif item.type == "choice" then
      local choiceText = Translator:t("language." .. item.value)
      love.graphics.printf(choiceText, px + 300, py, 100, "left")
    end
    py = py + 35
  end
  Components.drawButton(Translator:t("menu.back"), w * 0.45, h * 0.7, 150, 35, false)
end

function Settings.keypressed(key)
  if key == "escape" then EventBus:emit("state:change", "mainmenu")
  elseif key == "up" then Settings.selected = math.max(1, Settings.selected - 1)
  elseif key == "down" then Settings.selected = math.min(#Settings.items, Settings.selected + 1)
  elseif key == "left" or key == "right" then
    local item = Settings.items[Settings.selected]
    if item.type == "slider" then
      item.value = math.max(item.min, math.min(item.max, item.value + (key == "right" and 5 or -5)))
    elseif item.type == "toggle" then
      item.value = not item.value
    elseif item.type == "choice" then
      local index = 1
      for i, option in ipairs(item.options) do
        if option == item.value then index = i break end
      end
      index = index + (key == "right" and 1 or -1)
      if index < 1 then index = #item.options end
      if index > #item.options then index = 1 end
      item.value = item.options[index]
      if item.key == "language" then
        EventBus:emit("language:change", item.value)
      elseif item.key == "uiStyle" then
        Components.setTheme(item.value)
      end
    end
  elseif key == "return" then EventBus:emit("state:change", "mainmenu") end
end

function Settings.mousepressed(x, y, button)
  local w, h = love.graphics.getDimensions()
  if Components.isInRect(x, y, w * 0.45, h * 0.7, 150, 35) then
    EventBus:emit("state:change", "mainmenu")
  end
  local px, py = w * 0.35, h * 0.25
  for i, item in ipairs(Settings.items) do
    if item.type == "choice" then
      local itemY = py + (i - 1) * 35
      if Components.isInRect(x, y, px + 300, itemY, 100, 20) then
        local index = 1
        for j, option in ipairs(item.options) do
          if option == item.value then index = j break end
        end
        index = index % #item.options + 1
        item.value = item.options[index]
        if item.key == "language" then
          EventBus:emit("language:change", item.value)
        elseif item.key == "uiStyle" then
          Components.setTheme(item.value)
        end
      end
    end
  end
end

function Settings.mousemoved(x, y, dx, dy) end

return Settings
