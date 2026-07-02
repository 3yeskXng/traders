local EventBus = require("core.eventbus")
local Lifecycle = require("ui.events.lifecycle")
local Game = require("ui.events.game")
local Trade = require("ui.events.trade")
local Travel = require("ui.events.travel")
local Settings = require("ui.events.settings")
local Logger = require("core.logger")
local log = Logger.new("events")

local Events = {}

function Events.register(stateMachine, worldRef, saveManager)
  Lifecycle.register(stateMachine, worldRef, saveManager)
  Game.register(stateMachine, worldRef)
  Trade.register(worldRef)
  Travel.register(worldRef)
  Settings.register()
  log:info("All event handlers registered")
end

return Events
