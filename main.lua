local Logger = require("core.logger")
local EventBus = require("core.eventbus")
local Config = require("core.config")
local StateMachine = require("core.statemachine")
local ModLoader = require("core.modloader")
local json = require("core.json")
local World = require("simulation.world")
local Player = require("simulation.player")
local Renderer = require("rendering.renderer")
local MainMenu = require("ui.mainmenu")
local Settings = require("ui.settings")
local InGame = require("ui.ingame")
local SaveManager = require("savegame.savemanager")

local log = Logger.new("main")
local stateMachine
local world
local player
local renderer
local saveManager

function love.load()
  math.randomseed(os.time())
  love.graphics.setDefaultFilter("nearest", "nearest")
  Config:load("data/settings.json")
  saveManager = SaveManager.new()
  stateMachine = StateMachine.new()
  stateMachine:add("mainmenu", MainMenu)
  stateMachine:add("settings", Settings)
  stateMachine:add("game", InGame)
  EventBus:on("state:change", function(data) stateMachine:change(data) end)
  EventBus:on("game:new", function()
    world = World.new()
    local goodsData, _ = love.filesystem.read("data/goods.json")
    local citiesData, _ = love.filesystem.read("data/cities.json")
    local shipsData, _ = love.filesystem.read("data/ships.json")
    if goodsData then world:init({ goods = json.decode(goodsData), cities = citiesData and json.decode(citiesData), ships = shipsData and json.decode(shipsData) }) end
    player = Player.new("player", "Spieler")
    world:addPlayer(player)
    local cities = world.cities:getAll()
    if #cities > 0 then player.currentCityId = cities[1].id end
    renderer = Renderer.new(world)
    InGame.world = world
    EventBus.world = world
    stateMachine:change("game")
    ModLoader:loadAll()
    log:info("New game started")
  end)
  EventBus:on("game:load", function()
    world = World.new()
    local goodsData, _ = love.filesystem.read("data/goods.json")
    local citiesData, _ = love.filesystem.read("data/cities.json")
    local shipsData, _ = love.filesystem.read("data/ships.json")
    if goodsData then world:init({ goods = json.decode(goodsData), cities = citiesData and json.decode(citiesData), ships = shipsData and json.decode(shipsData) }) end
    local ok = saveManager:load(world, 1)
    if not ok then log:warn("No save found, starting new game") EventBus:emit("game:new") return end
    player = world.players[1] or Player.new("player", "Spieler")
    world:addPlayer(player)
    renderer = Renderer.new(world)
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
  stateMachine:change("mainmenu")
  log:info("Traders started")
end

function love.update(dt)
  stateMachine:update(dt)
  if world then world:update(dt) end
end

function love.draw()
  if stateMachine.current == "game" and renderer then
    renderer:draw()
  end
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

function love.resize(w, h) end

function love.quit()
  log:info("Shutting down")
  if world then EventBus:emit("game:save") end
  EventBus:clear()
end
