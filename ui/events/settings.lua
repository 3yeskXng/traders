local EventBus = require("core.eventbus")
local Config = require("core.config")
local Translator = require("core.translator")
local Fonts = require("core.fonts")

local Settings = {}

function Settings.register()
  EventBus:on("language:change", function(code)
    if Translator:setLanguage(code) then
      Config.language = code
      Fonts.setGlobalFont(code)
      Config:save("data/settings.json")
    end
  end)

  EventBus:on("settings:apply", function()
    Config:save("data/settings.json")
    local fullscreen = Config.fullscreen or false
    if love.window and love.window.setFullscreen then
      love.window.setFullscreen(fullscreen, "desktop")
    end
    if love.window and love.window.setMode and love.graphics.getDimensions then
      local w, h = love.graphics.getDimensions()
      love.window.setMode(w, h, {
        fullscreen = fullscreen, resizable = true, vsync = true
      })
    end
  end)
end

return Settings
