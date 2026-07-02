local EventBus = require("core.eventbus")
local Logger = require("core.logger")
local Helpers = require("ui.events.helpers")
local World = require("simulation.world")
local Player = require("simulation.player")
local NewGame = require("ui.newgame")
local InGame = require("ui.ingame")
local log = Logger.new("events.game")

local Game = {}

function Game.register(stateMachine, worldRef)
  EventBus:on("game:new", function()
    worldRef.world = World.new()
    local goods = Helpers.readJSON("data/goods.json")
    local cities = Helpers.readJSON("data/cities.json")
    local ships = Helpers.readJSON("data/ships.json")
    if goods then
      worldRef.world:init({ goods = goods, cities = cities, ships = ships })
    end
    worldRef.player = Player.new("player", "Spieler")
    worldRef.world:addPlayer(worldRef.player)
    NewGame.world = worldRef.world
    NewGame.player = worldRef.player
    EventBus.world = worldRef.world
    stateMachine:change("newgame")
    log:info("New game initialized")
  end)

  EventBus:on("game:start", function(data)
    if not worldRef.world or not worldRef.player or not data or not data.city then
      return
    end
    worldRef.player.currentCityId = data.city.id
    local startShip = worldRef.world.ships:createShip("cog", worldRef.player.id)
    if startShip then
      startShip.currentCityId = worldRef.player.currentCityId
    end
    InGame.world = worldRef.world
    EventBus.world = worldRef.world
    stateMachine:change("game")
    log:info("Game started in %s", data.city.name)
  end)
end

return Game
