local Logger = require("core.logger")
local Bootstrap = require("simulation.world.bootstrap")
local Serialize = require("simulation.world.serialize")
local Update = require("simulation.world.update")
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
  local world = Bootstrap.createWorld()
  self.goods = world.goods
  self.cities = world.cities
  self.ships = world.ships
  self.time = world.time
  self.trade = world.trade
  self.travel = world.travel
  Bootstrap.initializeWorld(self, data)
  log:info("World initialized")
  return true
end

function World:update(dt)
  Update.tick(self, dt)
end

function World:updateEconomy()
  Bootstrap.updateEconomy(self)
end

function World:addPlayer(player)
  table.insert(self.players, player)
end

function World:addAITrader(trader)
  table.insert(self.aiTraders, trader)
end

function World:serialize()
  return Serialize.snapshot(self)
end

return World
