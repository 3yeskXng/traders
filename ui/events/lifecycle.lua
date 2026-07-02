local EventBus = require("core.eventbus")
local Logger = require("core.logger")
local Helpers = require("ui.events.helpers")
local log = Logger.new("events.lifecycle")

local Lifecycle = {}

function Lifecycle.register(stateMachine, worldRef, saveManager)
  EventBus:on("state:change", function(data)
    stateMachine:change(data)
  end)

  EventBus:on("game:save", function()
    if worldRef.world then
      saveManager:save(worldRef.world, 1)
    end
  end)

  EventBus:on("game:load", function()
    local World = require("simulation.world")
    worldRef.world = World.new()
    local goods = Helpers.readJSON("data/goods.json")
    local cities = Helpers.readJSON("data/cities.json")
    local ships = Helpers.readJSON("data/ships.json")
    if goods then
      worldRef.world:init({ goods = goods, cities = cities, ships = ships })
    end
    local Player = require("simulation.player")
    local ok = saveManager:load(worldRef.world, 1)
    if not ok then
      log:warn("No save found, starting new game")
      EventBus:emit("game:new")
      return
    end
    worldRef.player = worldRef.world.players[1] or Player.new("player", "Spieler")
    worldRef.world:addPlayer(worldRef.player)
    EventBus.world = worldRef.world
    stateMachine:change("game")
    log:info("Game loaded")
  end)
end

return Lifecycle
