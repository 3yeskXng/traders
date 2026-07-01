local Logger = require("core.logger")
local EventBus = require("core.eventbus")
local log = Logger.new("time")

local TimeSystem = {}
TimeSystem.__index = TimeSystem

local MONTH_NAMES = { "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember" }
local SPEEDS = { 0, 1, 2, 4, 8 }
local DAYS_PER_MONTH = 30
local MONTHS_PER_YEAR = 12

function TimeSystem.new()
  return setmetatable({
    year = 1300, month = 1, day = 1, hour = 6,
    speedIndex = 2,
    accumulator = 0,
    paused = false,
  }, TimeSystem)
end

function TimeSystem:getSpeed()
  return self.paused and 0 or SPEEDS[self.speedIndex]
end

function TimeSystem:getSpeedLabel()
  if self.paused then return "Pause" end
  return tostring(SPEEDS[self.speedIndex]) .. "x"
end

function TimeSystem:nextSpeed()
  if self.speedIndex < #SPEEDS then self.speedIndex = self.speedIndex + 1 end
  if self.paused then self.paused = false end
end

function TimeSystem:prevSpeed()
  if self.speedIndex > 1 then self.speedIndex = self.speedIndex - 1 end
  if self.speedIndex == 1 then self.paused = true end
end

function TimeSystem:togglePause()
  self.paused = not self.paused
end

function TimeSystem:update(dt)
  if self.paused then return false end
  local speed = SPEEDS[self.speedIndex]
  self.accumulator = self.accumulator + dt * speed
  local dayDuration = 1
  if self.accumulator >= dayDuration then
    self.accumulator = self.accumulator - dayDuration
    self:advance()
    return true
  end
  return false
end

function TimeSystem:advance()
  self.day = self.day + 1
  if self.day > DAYS_PER_MONTH then
    self.day = 1
    self.month = self.month + 1
    if self.month > MONTHS_PER_YEAR then
      self.month = 1
      self.year = self.year + 1
    end
  end
  EventBus:emit("day:passed", { year = self.year, month = self.month, day = self.day })
end

function TimeSystem:getDateString()
  return string.format("%d. %s %d", self.day, MONTH_NAMES[self.month], self.year)
end

function TimeSystem:serialize()
  return { year = self.year, month = self.month, day = self.day, hour = self.hour, speedIndex = self.speedIndex, paused = self.paused }
end

function TimeSystem:deserialize(data)
  self.year = data.year; self.month = data.month; self.day = data.day
  self.hour = data.hour; self.speedIndex = data.speedIndex; self.paused = data.paused
end

return TimeSystem
