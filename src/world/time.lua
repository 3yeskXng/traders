local Logger = require("src.core.logger")
local log = Logger:new("time")

local TimeSystem = {}
TimeSystem.__index = TimeSystem

local SPEEDS = {0, 1, 2, 4, 8}
local SPEED_LABELS = {"Pause", "1x", "2x", "4x", "8x"}

function TimeSystem:new()
    return setmetatable({
        year = 1300,
        month = 1,
        day = 1,
        hour = 6,
        speedIndex = 1,
        tickTimer = 0,
        tickInterval = 1.5
    }, self)
end

function TimeSystem:getSpeed() return SPEEDS[self.speedIndex] end

function TimeSystem:getSpeedLabel() return SPEED_LABELS[self.speedIndex] end

function TimeSystem:nextSpeed()
    self.speedIndex = (self.speedIndex % #SPEEDS) + 1
    log:info("Speed: %s", SPEED_LABELS[self.speedIndex])
end

function TimeSystem:prevSpeed()
    self.speedIndex = ((self.speedIndex - 2) % #SPEEDS) + 1
    log:info("Speed: %s", SPEED_LABELS[self.speedIndex])
end

function TimeSystem:setPaused(paused)
    if paused then
        self.speedIndex = 1
    end
end

function TimeSystem:isPaused()
    return self.speedIndex == 1
end

function TimeSystem:update(dt)
    local speed = self:getSpeed()
    if speed == 0 then return false end
    self.tickTimer = self.tickTimer + dt * speed
    if self.tickTimer >= self.tickInterval then
        self.tickTimer = self.tickTimer - self.tickInterval
        self:advance()
        return true
    end
    return false
end

function TimeSystem:advance()
    self.day = self.day + 1
    if self.day > 30 then
        self.day = 1
        self.month = self.month + 1
    end
    if self.month > 12 then
        self.month = 1
        self.year = self.year + 1
    end
end

function TimeSystem:getDateString()
    local months = {"Januar", "Februar", "März", "April", "Mai", "Juni",
                    "Juli", "August", "September", "Oktober", "November", "Dezember"}
    return string.format("%d. %s %d", self.day, months[self.month], self.year)
end

function TimeSystem:serialize()
    return {
        year = self.year, month = self.month, day = self.day,
        hour = self.hour, speedIndex = self.speedIndex
    }
end

function TimeSystem:deserialize(data)
    self.year = data.year
    self.month = data.month
    self.day = data.day
    self.hour = data.hour or 6
    self.speedIndex = data.speedIndex or 1
end

return TimeSystem
