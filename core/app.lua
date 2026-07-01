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
local Fonts = require("core.fonts")

local log = Logger.new("main")
local App = {}

function App.readJSON(path)
  local file = love.filesystem.newFile(path, "r")
  if not file then log:warn("Could not open %s", path) return nil end
  local data = file:read()
  file:close()
  local ok, result = pcall(json.decode, data)
  if ok then return result end
  log:warn("Failed to parse %s: %s", path, tostring(result))
  return nil
end

function App.applyGraphicsSettings()
  local fullscreen = Config.fullscreen or false
  if love.window and love.window.setFullscreen then
    love.window.setFullscreen(fullscreen, "desktop")
  end
  if love.window and love.window.setMode and love.graphics.getDimensions then
    local w, h = love.graphics.getDimensions()
    love.window.setMode(w, h, { fullscreen = fullscreen, resizable = true, vsync = true })
  end
end

function App.load()
  math.randomseed(os.time())
  love.graphics.setDefaultFilter("nearest", "nearest")
  Config:load("data/settings.json")
  Config.language = Config.language or "de"
  Config.uiStyle = Config.uiStyle or "retro"
  Fonts.setGlobalFont(Config.language)
  Translator:loadLanguage("en", "data/lang/en.json")
  Translator:loadLanguage("de", "data/lang/de.json")
  Translator:loadLanguage("zh", "data/lang/zh.json")
  Translator:setLanguage(Config.language)
  App.applyGraphicsSettings()
  local Components = require("ui.components")
  Components.setTheme(Config.uiStyle)
  App.pluginManager = PluginManager.new()
  ModLoader:loadAll(App.pluginManager)
  App.saveManager = SaveManager.new()
  App.stateMachine = StateMachine.new()
  App.stateMachine:add("mainmenu", MainMenu)
  App.stateMachine:add("settings", Settings)
  App.stateMachine:add("newgame", NewGame)
  App.stateMachine:add("game", InGame)
  EventBus:on("state:change", function(data) App.stateMachine:change(data) end)
  EventBus:on("language:change", function(code)
    if Translator:setLanguage(code) then
      Config.language = code
      Fonts.setGlobalFont(code)
      Config:save("data/settings.json")
    end
  end)
  EventBus:on("settings:apply", function()
    Config:save("data/settings.json")
    App.applyGraphicsSettings()
  end)
  EventBus:on("game:new", function()
    App.world = World.new()
    local goods = App.readJSON("data/goods.json")
    local cities = App.readJSON("data/cities.json")
    local ships = App.readJSON("data/ships.json")
    if goods then App.world:init({ goods = goods, cities = cities, ships = ships }) end
    App.player = Player.new("player", "Spieler")
    App.world:addPlayer(App.player)
    NewGame.world = App.world
    NewGame.player = App.player
    EventBus.world = App.world
    App.stateMachine:change("newgame")
    log:info("New game initialized")
  end)

  EventBus:on("game:start", function(data)
    if not App.world or not App.player or not data or not data.city then return end
    App.player.currentCityId = data.city.id
    local startShip = App.world.ships:createShip("cog", App.player.id)
    if startShip then startShip.currentCityId = App.player.currentCityId end
    InGame.world = App.world
    EventBus.world = App.world
    App.stateMachine:change("game")
    log:info("Game started in %s", data.city.name)
  end)

  EventBus:on("game:load", function()
    App.world = World.new()
    local goods = App.readJSON("data/goods.json")
    local cities = App.readJSON("data/cities.json")
    local ships = App.readJSON("data/ships.json")
    if goods then App.world:init({ goods = goods, cities = cities, ships = ships }) end
    local ok = App.saveManager:load(App.world, 1)
    if not ok then log:warn("No save found, starting new game") EventBus:emit("game:new") return end
    App.player = App.world.players[1] or Player.new("player", "Spieler")
    App.world:addPlayer(App.player)
    InGame.world = App.world
    EventBus.world = App.world
    App.stateMachine:change("game")
    log:info("Game loaded")
  end)

  EventBus:on("game:save", function()
    if App.world then App.saveManager:save(App.world, 1) end
  end)

  EventBus:on("trade:buy", function(data)
    if App.world and App.world.trade and data.city and data.goodId then
      local amount = App.world.trade:buy(App.player, data.city, data.goodId, data.amount or 1, data.city.prices[data.goodId] or 0)
      if amount > 0 then log:info("Bought %d x %s", amount, data.goodId) end
    end
  end)

  EventBus:on("trade:sell", function(data)
    if App.world and App.world.trade and data.city and data.goodId then
      local city = data.city
      local amount = App.world.trade:sell(App.player, city, data.goodId, data.amount or 1, city.prices[data.goodId] or 0)
      if amount > 0 then log:info("Sold %d x %s", amount, data.goodId) end
    end
  end)

  EventBus:on("travel:start", function(data)
    if App.world and App.world.travel and data.from and data.to then
      App.world.travel:start(data.from, data.to)
    end
  end)

  EventBus:on("travel:arrived", function(data)
    if App.player and App.world and data.city then
      App.player.currentCityId = data.city.id
      if InGame and InGame.notify then
        InGame:notify(Translator:t("status.arrived", data.city.name), { 0.4, 1, 0.4 })
      end
      if InGame and InGame.mapRenderer then
        InGame.mapRenderer._centerOnArrival = true
      end
      log:info("Travel arrived at %s", data.city.name)
    end
  end)

  App.stateMachine:change("mainmenu")
  log:info("Traders started")
end

function App.update(dt)
  if App.stateMachine then App.stateMachine:update(dt) end
  if App.world then App.world:update(dt) end
end

function App.draw()
  if App.stateMachine then App.stateMachine:draw() end
  if Config.showFPS then
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
  end
end

function App.keypressed(key, scancode, isrepeat)
  if App.stateMachine then App.stateMachine:keypressed(key, scancode, isrepeat) end
end

function App.mousepressed(x, y, button)
  if App.stateMachine then App.stateMachine:mousepressed(x, y, button) end
end

function App.mousemoved(x, y, dx, dy)
  if App.stateMachine then App.stateMachine:mousemoved(x, y, dx, dy) end
end

function App.mousereleased(x, y, button)
  if App.stateMachine then App.stateMachine:mousereleased(x, y, button) end
end

function App.resize(w, h) end

function App.quit()
  log:info("Shutting down")
  if App.world then EventBus:emit("game:save") end
  EventBus:clear()
end

return App
