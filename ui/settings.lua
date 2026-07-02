local State = require("ui.settings.state")
local Draw = require("ui.settings.draw")
local Keyboard = require("ui.settings.keyboard")
local Mouse = require("ui.settings.mouse")

local Settings = {}

function Settings.enter()
  State.enter(Settings)
end

function Settings.leave()
  State.leave(Settings)
end

function Settings.update(dt) end

function Settings.draw()
  Draw.render(Settings)
end

function Settings.keypressed(key)
  Keyboard.keypressed(Settings, key)
end

function Settings.mousepressed(x, y, button)
  Mouse.pressed(Settings, x, y, button)
end

function Settings.mousemoved(x, y, dx, dy) end

return Settings
