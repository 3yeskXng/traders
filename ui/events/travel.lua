local EventBus = require("core.eventbus")
local Logger = require("core.logger")
local InGame = require("ui.ingame")
local Translator = require("core.translator")
local log = Logger.new("events.travel")

local Travel = {}

function Travel.register(worldRef)
  EventBus:on("travel:start", function(data)
    if worldRef.world and worldRef.world.travel and data.from and data.to then
      worldRef.world.travel:start(data.from, data.to)
    end
  end)

  EventBus:on("travel:arrived", function(data)
    if worldRef.player and worldRef.world and data.city then
      worldRef.player.currentCityId = data.city.id
      if InGame and InGame.notify then
        InGame:notify(
          Translator:t("status.arrived", data.city.name),
          { 0.4, 1, 0.4 }
        )
      end
      if InGame and InGame.mapRenderer then
        InGame.mapRenderer._centerOnArrival = true
      end
      log:info("Travel arrived at %s", data.city.name)
    end
  end)
end

return Travel
