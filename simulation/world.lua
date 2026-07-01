local Logger = require("core.logger")
local EventBus = require("core.eventbus")
local GoodsManager = require("simulation.goods.goodsmanager")
local CityManager = require("simulation.cities.citymanager")
local Population = require("simulation.cities.population")
local Prices = require("simulation.economy.prices")
local Production = require("simulation.economy.production")
local Consumption = require("simulation.economy.consumption")
local TradeSystem = require("simulation.trade.trading")
local TravelSystem = require("simulation.travel.travel")
local ShipManager = require("simulation.ships.shipmanager")
local TimeSystem = require("simulation.time")
local CityTax = require("simulation.taxes.citytax")
local log = Logger.new("world")

local World = {}
World.__index = World

function World.new()
  return setmetatable({
    goods = nil, cities = nil, ships = nil,
    time = nil, trade = nil, travel = nil,
    players = {}, aiTraders = {},
  }, World)
end

function World:init(data)
  self.goods = GoodsManager.new()
  self.cities = CityManager.new()
  self.ships = ShipManager.new()
  self.time = TimeSystem.new()
  self.trade = TradeSystem.new()
  self.travel = TravelSystem.new()
  if data.goods then self.goods:load(data.goods) end
  if data.cities then self.cities:load(data.cities) end
  if data.ships then self.ships:loadTypes(data.ships) end
  self:updateEconomy()
  log:info("World initialized")
  return true
end

function World:update(dt)
  local dayPassed = self.time:update(dt)
  self.travel:update(dt, self.time:getSpeed())
  if dayPassed then
    self:updateEconomy()
    for _, trader in ipairs(self.aiTraders) do
      trader:update(self)
    end
  end
end

function World:updateEconomy()
  for _, city in ipairs(self.cities:getAll()) do
    Production.run(city, self.goods)
    Consumption.run(city, self.goods)
    Prices.updateCityPrices(city, self.goods:getAll(), math.random(-5, 5) * 0.01)
    Population.update(city, self.goods)
    CityTax.collect(city)
  end
end

function World:addPlayer(player)
  table.insert(self.players, player)
end

function World:addAITrader(trader)
  table.insert(self.aiTraders, trader)
end

function World:serialize()
  return {
    cities = self.cities:serialize(),
    ships = self.ships:serialize(),
    time = self.time:serialize(),
    travel = self.travel:serialize(),
  }
end

return World
