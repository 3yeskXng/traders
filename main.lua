local Logger = require("core.logger")
local json = require("core.json")
local EventBus = require("core.eventbus")
local Config = require("core.config")
local Translator = require("core.translator")
local PluginManager = require("core.pluginmanager")
local StateMachine = require("core.statemachine")
local ModLoader = require("core.modloader")
local World = require("simulation.world")
local Player = require("simulation.player")
local MainMenu = require("ui.mainmenu")
local Settings = require("ui.settings")
local NewGame = require("ui.newgame")
local InGame = require("ui.ingame")
local SaveManager = require("savegame.savemanager")

local log = Logger.new("main")
local stateMachine
local world
local player
local saveManager
local pluginManager

local function readJSON(path)
  local file = love.filesystem.newFile(path, "r")
  if not file then log:warn("Could not open %s", path) return nil end
  local data = file:read()
  file:close()
  local ok, result = pcall(json.decode, data)
  if ok then return result end
  log:warn("Failed to parse %s: %s", path, tostring(result))
  return nil
end

function love.load()
  math.randomseed(os.time())
  love.graphics.setDefaultFilter("nearest", "nearest")
  Config:load("data/settings.json")
  Config.language = Config.language or "de"
  Translator:loadLanguage("en", "data/lang/en.json")
  Translator:loadLanguage("de", "data/lang/de.json")
  Translator:setLanguage(Config.language)
  pluginManager = PluginManager.new()
  ModLoader:loadAll(pluginManager)
  saveManager = SaveManager.new()
  stateMachine = StateMachine.new()
  stateMachine:add("mainmenu", MainMenu)
  stateMachine:add("settings", Settings)
  stateMachine:add("newgame", NewGame)
  stateMachine:add("game", InGame)
  EventBus:on("state:change", function(data) stateMachine:change(data) end)
  EventBus:on("language:change", function(code)
    if Translator:setLanguage(code) then
      Config.language = code
      Config:save("data/settings.json")
    end
  end)
  EventBus:on("game:new", function()
    world = World.new()
    local goods = readJSON("data/goods.json")
    local cities = readJSON("data/cities.json")
    local ships = readJSON("data/ships.json")
    if goods then world:init({ goods = goods, cities = cities, ships = ships }) end
    player = Player.new("player", "Spieler")
    world:addPlayer(player)
    NewGame.world = world
    NewGame.player = player
    EventBus.world = world
    stateMachine:change("newgame")
    log:info("New game initialized")
  end)

  EventBus:on("game:start", function(data)
    if not world or not player or not data or not data.city then return end
    player.currentCityId = data.city.id
    local startShip = world.ships:createShip("cog", player.id)
    if startShip then startShip.currentCityId = player.currentCityId end
    InGame.world = world
    EventBus.world = world
    stateMachine:change("game")
    log:info("Game started in %s", data.city.name)
  end)
  EventBus:on("game:load", function()
    world = World.new()
    local goods = readJSON("data/goods.json")
    local cities = readJSON("data/cities.json")
    local ships = readJSON("data/ships.json")
    if goods then world:init({ goods = goods, cities = cities, ships = ships }) end
    local ok = saveManager:load(world, 1)
    if not ok then log:warn("No save found, starting new game") EventBus:emit("game:new") return end
    player = world.players[1] or Player.new("player", "Spieler")
    world:addPlayer(player)
    InGame.world = world
    EventBus.world = world
    stateMachine:change("game")
    log:info("Game loaded")
  end)
  EventBus:on("game:save", function()
    if world then saveManager:save(world, 1) end
  end)
  EventBus:on("trade:buy", function(data)
    if world and world.trade and data.city and data.goodId then
      local amount = world.trade:buy(player, data.city, data.goodId, data.amount or 1, data.city.prices[data.goodId] or 0)
      if amount > 0 then log:info("Bought %d x %s", amount, data.goodId) end
    end
  end)
  EventBus:on("trade:sell", function(data)
    if world and world.trade and data.city and data.goodId then
      local city = data.city
      local amount = world.trade:sell(player, city, data.goodId, data.amount or 1, city.prices[data.goodId] or 0)
      if amount > 0 then log:info("Sold %d x %s", amount, data.goodId) end
    end
  end)
  EventBus:on("travel:start", function(data)
    if world and world.travel and data.from and data.to then
      world.travel:start(data.from, data.to)
    end
  end)
  EventBus:on("travel:arrived", function(data)
    if player and world and data.city then
      player.currentCityId = data.city.id
      if InGame and InGame.notify then
        InGame:notify(Translator:t("status.arrived", data.city.name), { 0.4, 1, 0.4 })
      end
      if InGame and InGame.mapRenderer then
        InGame.mapRenderer._centerOnArrival = true
      end
      log:info("Travel arrived at %s", data.city.name)
    end
  end)
  stateMachine:change("mainmenu")
  log:info("Traders started")
end

function love.update(dt)
  stateMachine:update(dt)
  if world then world:update(dt) end
end

function love.draw()
  stateMachine:draw()
end

function love.keypressed(key, scancode, isrepeat)
  stateMachine:keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button)
  stateMachine:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  stateMachine:mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
  stateMachine:mousereleased(x, y, button)
end

function love.resize(w, h) end

function love.quit()
  log:info("Shutting down")
  if world then EventBus:emit("game:save") end
  EventBus:clear()
end
