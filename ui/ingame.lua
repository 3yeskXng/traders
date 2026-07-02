local EventBus = require("core.eventbus")
local Logger = require("core.logger")
local State = require("ui.ingame.state")
local Keyboard = require("ui.ingame.keyboard")
local Mouse = require("ui.ingame.mouse")
local Draw = require("ui.ingame.draw")
local Notifications = require("ui.ingame.notifications")
local log = Logger.new("ingame")

local InGame = {}

function InGame.enter()
  State.enter(InGame)
end

function InGame.leave()
  State.leave(InGame)
end

function InGame.update(dt)
  InGame.world = InGame.world or EventBus.world
  if InGame.marketUI then
    InGame.marketUI:update(dt)
  end
  if InGame.mapRenderer and InGame.world then
    InGame.mapRenderer:update(dt, InGame.world)
  end
  Notifications.update(InGame.notifications, dt)
  State.updateCurrentCity(InGame, InGame.world)
end

function InGame:notify(text, color)
  Notifications.add(InGame.notifications, text, color)
  log:info(text)
end

function InGame.draw()
  Draw.render(InGame)
end

function InGame.keypressed(key)
  Keyboard.keypressed(InGame, key)
end

function InGame.mousepressed(x, y, button)
  Mouse.pressed(InGame, x, y, button)
end

function InGame.mousemoved(x, y, dx, dy)
  Mouse.moved(InGame, x, y, dx, dy)
end

function InGame.mousereleased(x, y, button)
  Mouse.released(InGame, x, y, button)
end

return InGame
