local EventBus = require("core.eventbus")
local Config = require("core.config")
local Translator = require("core.translator")
local Fonts = require("core.fonts")
local StateMachine = require("core.statemachine")
local World = require("simulation.world")
local Player = require("simulation.player")
local NewGame = require("ui.newgame")
local InGame = require("ui.ingame")
local SaveManager = require("savegame.savemanager")
local json = require("core.json")
local Logger = require("core.logger")
local log = Logger.new("events")

local Events = {}

local function readJSON(path)
  local log = Logger.new("json")
  local file = love.filesystem.newFile(path, "r")
  if not file then log:warn("Could not open %s", path) return nil end
  local data = file:read()
  file:close()
  local ok, result = pcall(json.decode, data)
  if ok then return result end
  log:warn("Failed to parse %s: %s", path, tostring(result))
  return nil
end

function Events.register(stateMachine, worldRef, playerRef, saveManager)
  EventBus:on("state:change", function(data) stateMachine:change(data) end)

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
      love.window.setMode(w, h, { fullscreen = fullscreen, resizable = true, vsync = true })
    end
  end)

  EventBus:on("game:new", function()
    worldRef.world = World.new()
    local goods = readJSON("data/goods.json")
    local cities = readJSON("data/cities.json")
    local ships = readJSON("data/ships.json")
    if goods then worldRef.world:init({ goods = goods, cities = cities, ships = ships }) end
    worldRef.player = Player.new("player", "Spieler")
    worldRef.world:addPlayer(worldRef.player)
    NewGame.world = worldRef.world
    NewGame.player = worldRef.player
    EventBus.world = worldRef.world
    stateMachine:change("newgame")
    log:info("New game initialized")
  end)

  EventBus:on("game:start", function(data)
    if not worldRef.world or not worldRef.player or not data or not data.city then return end
    worldRef.player.currentCityId = data.city.id
    local startShip = worldRef.world.ships:createShip("cog", worldRef.player.id)
    if startShip then startShip.currentCityId = worldRef.player.currentCityId end
    InGame.world = worldRef.world
    EventBus.world = worldRef.world
    stateMachine:change("game")
    log:info("Game started in %s", data.city.name)
  end)

  EventBus:on("game:load", function()
    worldRef.world = World.new()
    local goods = readJSON("data/goods.json")
    local cities = readJSON("data/cities.json")
    local ships = readJSON("data/ships.json")
    if goods then worldRef.world:init({ goods = goods, cities = cities, ships = ships }) end
    local ok = saveManager:load(worldRef.world, 1)
    if not ok then
      log:warn("No save found, starting new game")
      EventBus:emit("game:new")
      return
    end
    worldRef.player = worldRef.world.players[1] or Player.new("player", "Spieler")
    worldRef.world:addPlayer(worldRef.player)
    InGame.world = worldRef.world
    EventBus.world = worldRef.world
    stateMachine:change("game")
    log:info("Game loaded")
  end)

  EventBus:on("game:save", function()
    if worldRef.world then saveManager:save(worldRef.world, 1) end
  end)

  EventBus:on("trade:buy", function(data)
    if worldRef.world and worldRef.world.trade and data.city and data.goodId then
      local amount = worldRef.world.trade:buy(worldRef.player, data.city, data.goodId, data.amount or 1, data.city.prices[data.goodId] or 0)
      if amount > 0 then log:info("Bought %d x %s", amount, data.goodId) end
    end
  end)

  EventBus:on("trade:sell", function(data)
    if worldRef.world and worldRef.world.trade and data.city and data.goodId then
      local amount = worldRef.world.trade:sell(worldRef.player, data.city, data.goodId, data.amount or 1, data.city.prices[data.goodId] or 0)
      if amount > 0 then log:info("Sold %d x %s", amount, data.goodId) end
    end
  end)

  EventBus:on("travel:start", function(data)
    if worldRef.world and worldRef.world.travel and data.from and data.to then
      worldRef.world.travel:start(data.from, data.to)
    end
  end)

  EventBus:on("travel:arrived", function(data)
    if worldRef.player and worldRef.world and data.city then
      worldRef.player.currentCityId = data.city.id
      if InGame and InGame.notify then
        InGame:notify(Translator:t("status.arrived", data.city.name), { 0.4, 1, 0.4 })
      end
      if InGame and InGame.mapRenderer then
        InGame.mapRenderer._centerOnArrival = true
      end
      log:info("Travel arrived at %s", data.city.name)
    end
  end)
end

return Events
