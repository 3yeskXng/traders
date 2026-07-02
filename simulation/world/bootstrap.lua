local Logger = require("core.logger")
local GoodsManager = require("simulation.goods.manager")
local CityManager = require("simulation.cities.manager")
local ShipManager = require("simulation.ships.manager")
local TimeSystem = require("simulation.time")
local TradeSystem = require("simulation.trade.trading")
local TravelSystem = require("simulation.travel.travel")
local Production = require("simulation.economy.production")
local Consumption = require("simulation.economy.consumption")
local Prices = require("simulation.economy.prices")
local Population = require("simulation.cities.population")
local CityTax = require("simulation.taxes.citytax")
local log = Logger.new("world.bootstrap")

local Bootstrap = {}

function Bootstrap.createWorld()
  local world = {
    goods = GoodsManager.new(),
    cities = CityManager.new(),
    ships = ShipManager.new(),
    time = TimeSystem.new(),
    trade = TradeSystem.new(),
    travel = TravelSystem.new(),
    players = {},
    aiTraders = {},
  }
  return world
end

function Bootstrap.initializeWorld(world, data)
  if data.goods then world.goods:load(data.goods) end
  if data.cities then world.cities:load(data.cities) end
  if data.ships then world.ships:loadTypes(data.ships) end
  Bootstrap.updateEconomy(world)
  log:info("World initialized")
  return world
end

function Bootstrap.updateEconomy(world)
  for _, city in ipairs(world.cities:getAll()) do
    Production.run(city, world.goods)
    Consumption.run(city, world.goods)
    Prices.updateCityPrices(city, world.goods:getAll(), math.random(-5, 5) * 0.01)
    Population.update(city, world.goods)
    CityTax.collect(city)
  end
end

function Bootstrap.addPlayer(world, player)
  table.insert(world.players, player)
end

function Bootstrap.addAITrader(world, trader)
  table.insert(world.aiTraders, trader)
end

return Bootstrap
