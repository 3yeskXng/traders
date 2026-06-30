local Logger = require("src.core.logger")
local EventBus = require("src.core.event")
local log = Logger:new("travel")

local TravelSystem = {}
TravelSystem.__index = TravelSystem

function TravelSystem:new()
    return setmetatable({
        traveling = false,
        fromCity = nil,
        toCity = nil,
        progress = 0,
        duration = 0,
        speed = 1.0,
        route = {}
    }, self)
end

function TravelSystem:startTravel(fromCity, toCity)
    if not fromCity or not toCity then return false end
    if fromCity == toCity then
        log:warn("Already in %s", fromCity.name)
        return false
    end
    local dx = toCity.x - fromCity.x
    local dy = toCity.y - fromCity.y
    local dist = math.sqrt(dx * dx + dy * dy)

    self.traveling = true
    self.fromCity = fromCity
    self.toCity = toCity
    self.progress = 0
    self.duration = dist * 8 + 2
    self.route = {
        {x = fromCity.x, y = fromCity.y},
        {x = toCity.x, y = toCity.y}
    }
    log:info("Travel started: %s -> %s (%.1f days)", fromCity.name, toCity.name, self.duration)
    return true
end

function TravelSystem:update(dt, gameSpeed)
    if not self.traveling then return end
    local speed = (gameSpeed or 1) * 0.5
    self.progress = self.progress + dt * speed / self.duration
    if self.progress >= 1.0 then
        self.progress = 1.0
        self.traveling = false
        EventBus:emit("travel:arrived", {
            from = self.fromCity,
            to = self.toCity
        })
        log:info("Travel completed: arrived at %s", self.toCity.name)
    end
end

function TravelSystem:cancel()
    if not self.traveling then return end
    log:info("Travel cancelled: %s -> %s", self.fromCity and self.fromCity.name or "?",
        self.toCity and self.toCity.name or "?")
    self.traveling = false
    self.fromCity = nil
    self.toCity = nil
    self.progress = 0
end

function TravelSystem:getCurrentPosition()
    if not self.traveling or not self.fromCity or not self.toCity then return nil end
    local t = self.progress
    return {
        x = self.fromCity.x + (self.toCity.x - self.fromCity.x) * t,
        y = self.fromCity.y + (self.toCity.y - self.fromCity.y) * t
    }
end

function TravelSystem:getInfo()
    if not self.traveling then return nil end
    return {
        from = self.fromCity.name,
        to = self.toCity.name,
        progress = self.progress,
        remaining = (1 - self.progress) * self.duration
    }
end

function TravelSystem:serialize()
    return {
        traveling = self.traveling,
        fromCity = self.fromCity and self.fromCity.id,
        toCity = self.toCity and self.toCity.id,
        progress = self.progress,
        duration = self.duration
    }
end

function TravelSystem:deserialize(data, cities)
    self.traveling = data.traveling
    self.progress = data.progress
    self.duration = data.duration
    if data.fromCity and cities then
        for _, c in ipairs(cities) do
            if c.id == data.fromCity then self.fromCity = c; break end
        end
    end
    if data.toCity and cities then
        for _, c in ipairs(cities) do
            if c.id == data.toCity then self.toCity = c; break end
        end
    end
end

return TravelSystem
