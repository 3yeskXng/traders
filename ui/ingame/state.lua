local EventBus = require("core.eventbus")
local MapRenderer = require("rendering.map")
local MarketUI = require("ui.market")
local MapConfig = require("simulation.map.config")
local json = require("core.json")
local Logger = require("core.logger")
local Notifications = require("ui.ingame.notifications")
local log = Logger.new("ingame.state")

local State = {}

function State.enter(ingame)
  ingame.mapRenderer = MapRenderer.new()
  ingame.marketUI = MarketUI.new()
  ingame.notifications = {}
  ingame.currentCity = nil

  if ingame.world and ingame.world.players[1] then
    local player = ingame.world.players[1]
    local city = player.currentCityId and ingame.world.cities:getById(player.currentCityId)
    if city then
      local w, h = love.graphics.getDimensions()
      ingame.mapRenderer.camera:setTarget(city.x * w - w / 2, city.y * h - h / 2)
      ingame.mapRenderer._centerOnArrival = false
    end
  end

  if love.filesystem then
    local file = love.filesystem.newFile("data/map.json", "r")
    if file then
      local data = file:read()
      file:close()
      local ok, parsed = pcall(json.decode, data)
      if ok and parsed then
        ingame.mapRenderer.mapConfig = MapConfig.new(parsed)
        log:info("Map loaded: %s", parsed.name or "unknown")
      else
        log:warn("Could not parse map.json")
      end
    else
      log:warn("Could not open data/map.json")
    end
  end
end

function State.leave(ingame)
  ingame.marketUI = nil
  ingame.mapRenderer = nil
  ingame.notifications = nil
end

function State.updateCurrentCity(ingame, world)
  if not world then
    return
  end
  if world.travel.traveling then
    ingame.currentCity = nil
    return
  end
  local player = world.players[1]
  if not player then
    return
  end
  if player.currentCityId then
    local city = world.cities:getById(player.currentCityId)
    if city then
      ingame.currentCity = city
      return
    end
  end
  local cities = world.cities:getAll()
  if #cities > 0 then
    player.currentCityId = cities[1].id
    ingame.currentCity = cities[1]
  end
end

return State
