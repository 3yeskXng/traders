local Logger = require("core.logger")
local EventBus = require("core.eventbus")
local Distance = require("simulation.travel.distance")
local log = Logger.new("travel")

local TravelSystem = {}
TravelSystem.__index = TravelSystem

function TravelSystem.new()
  return setmetatable({
    traveling = false,
    from = nil, to = nil,
    progress = 0, duration = 0,
    fromId = nil, toId = nil,
  }, TravelSystem)
end

function TravelSystem:start(fromCity, toCity)
  if fromCity.id == toCity.id then return false end
  self.traveling = true
  self.from = fromCity
  self.to = toCity
  self.fromId = fromCity.id
  self.toId = toCity.id
  self.progress = 0
  self.duration = Distance.calculateTravelDays(fromCity, toCity)
  EventBus:emit("travel:started", { from = fromCity.id, to = toCity.id, duration = self.duration })
  log:info("Travel started: %s -> %s (%d days)", fromCity.name, toCity.name, self.duration)
  return true
end

function TravelSystem:update(dt, gameSpeed)
  if not self.traveling then return end
  local speed = gameSpeed or 1
  self.progress = self.progress + (dt * speed) / self.duration
  if self.progress >= 1 then
    self.progress = 1
    self.traveling = false
    EventBus:emit("travel:arrived", { from = self.fromId, to = self.toId, city = self.to })
    log:info("Arrived at %s", self.to.name)
  end
end

function TravelSystem:cancel()
  if self.traveling then
    self.traveling = false
    EventBus:emit("travel:cancelled", { from = self.fromId, to = self.toId })
  end
end

function TravelSystem:getPosition()
  if not self.traveling then return nil end
  local x = self.from.x + (self.to.x - self.from.x) * self.progress
  local y = self.from.y + (self.to.y - self.from.y) * self.progress
  return x, y
end

function TravelSystem:serialize()
  if not self.traveling then return { traveling = false } end
  return { traveling = true, fromId = self.fromId, toId = self.toId, progress = self.progress, duration = self.duration }
end

function TravelSystem:deserialize(data, cityManager)
  if data.traveling then
    self.fromId = data.fromId
    self.toId = data.toId
    self.progress = data.progress
    self.duration = data.duration
    self.from = cityManager:getById(data.fromId)
    self.to = cityManager:getById(data.toId)
    self.traveling = true
  end
end

return TravelSystem
