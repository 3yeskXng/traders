local Config = require("core.config")
local EventBus = require("core.eventbus")

local State = {}

function State.enter(settings)
  settings.items = {
    {
      labelKey = "settings.language", key = "language",
      type = "choice", options = { "de", "en", "zh" },
      value = Config.language or "de",
    },
    {
      labelKey = "settings.ui_style", key = "uiStyle",
      type = "choice", options = { "retro", "clean" },
      value = Config.uiStyle or "retro",
    },
    {
      labelKey = "settings.master_volume", key = "masterVolume",
      type = "slider", min = 0, max = 100,
      value = Config.masterVolume or 80,
    },
    {
      labelKey = "settings.music_volume", key = "musicVolume",
      type = "slider", min = 0, max = 100,
      value = Config.musicVolume or 70,
    },
    {
      labelKey = "settings.sfx_volume", key = "sfxVolume",
      type = "slider", min = 0, max = 100,
      value = Config.sfxVolume or 80,
    },
    {
      labelKey = "settings.show_fps", key = "showFPS",
      type = "toggle", value = Config.showFPS or false,
    },
    {
      labelKey = "settings.fullscreen", key = "fullscreen",
      type = "toggle", value = Config.fullscreen or false,
    },
  }
  settings.selected = 1
end

function State.leave(settings)
  for _, item in ipairs(settings.items) do
    Config[item.key] = item.value
  end
  Config:save("data/settings.json")
  EventBus:emit("settings:apply")
end

return State
