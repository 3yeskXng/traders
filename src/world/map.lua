local Logger = require("src.core.logger")
local log = Logger:new("map")

local WorldMap = {}
WorldMap.__index = WorldMap

function WorldMap:new(worldWidth, worldHeight)
    return setmetatable({
        width = worldWidth or 880,
        height = worldHeight or 480,
        time = 0,
        hoveredCity = nil
    }, self)
end

function WorldMap:update(dt)
    self.time = self.time + dt
end

function WorldMap:draw(cities, playerCity, travel, notifications)
    local ww, wh = love.graphics.getDimensions()
    local mx, my = (ww - self.width) / 2, (wh - self.height) / 2 + 18

    love.graphics.setColor(0.04, 0.06, 0.12)
    love.graphics.rectangle("fill", mx - 12, my - 12, self.width + 24, self.height + 24)

    love.graphics.setColor(0.06, 0.12, 0.25)
    love.graphics.rectangle("fill", mx, my, self.width, self.height)

    for x = mx, mx + self.width, 40 do
        local wave = math.sin(x * 0.05 + self.time * 0.8) * 1.5
        love.graphics.setColor(0.05, 0.1, 0.2, 0.3)
        love.graphics.rectangle("fill", x, my + wave, 20, self.height)
    end

    love.graphics.setColor(0.12, 0.28, 0.12, 0.9)
    local landAreas = {
        {0.05, 0.2, 0.5, 0.75}, {0.55, 0.1, 0.4, 0.85},
        {0.2, 0.35, 0.6, 0.55}, {0.35, 0.5, 0.3, 0.4},
        {0.0, 0.5, 0.15, 0.45}, {0.85, 0.1, 0.15, 0.8}
    }
    for _, area in ipairs(landAreas) do
        love.graphics.ellipse("fill",
            mx + area[1] * self.width, my + area[2] * self.height,
            area[3] * self.width / 2, area[4] * self.height / 2)
    end

    love.graphics.setColor(0.15, 0.32, 0.15, 0.5)
    for _, area in ipairs(landAreas) do
        love.graphics.ellipse("fill",
            mx + area[1] * self.width + math.sin(self.time * 0.2 + area[1]) * 2,
            my + area[2] * self.height + math.cos(self.time * 0.3 + area[2]) * 2,
            area[3] * self.width / 2.5, area[4] * self.height / 2.5)
    end

    if cities then
        for i, city in ipairs(cities) do
            for j = i + 1, #cities do
                local c1, c2 = cities[i], cities[j]
                local dist = math.sqrt((c2.x - c1.x)^2 + (c2.y - c1.y)^2)
                if dist < 0.5 then
                    love.graphics.setColor(0.2, 0.25, 0.15, 0.15)
                    love.graphics.setLineWidth(0.5)
                    love.graphics.line(
                        mx + c1.x * self.width, my + c1.y * self.height,
                        mx + c2.x * self.width, my + c2.y * self.height)
                end
            end
        end

        if travel and travel.traveling then
            local pos = travel:getCurrentPosition()
            if pos then
                love.graphics.setColor(0.8, 0.6, 0.2, 0.4)
                love.graphics.setLineWidth(2)
                love.graphics.line(
                    mx + travel.fromCity.x * self.width, my + travel.fromCity.y * self.height,
                    mx + travel.toCity.x * self.width, my + travel.toCity.y * self.height)
                love.graphics.setColor(1, 0.8, 0.3, 0.8)
                love.graphics.circle("fill", mx + pos.x * self.width, my + pos.y * self.height, 5)
                love.graphics.setLineWidth(1)
            end
        end

        for _, city in ipairs(cities) do
            local cx = mx + city.x * self.width
            local cy = my + city.y * self.height
            local r = 6 + math.sqrt(city.population) / 60

            if city == playerCity then
                love.graphics.setColor(0.9, 0.8, 0.3, 0.6)
                love.graphics.circle("fill", cx, cy, r + 6)
                love.graphics.setColor(1, 0.9, 0.4, 0.3)
                love.graphics.circle("fill", cx, cy, r + 10 + math.sin(self.time * 3) * 2)
            end

            if city == self.hoveredCity then
                love.graphics.setColor(0.4, 0.6, 0.8, 0.3)
                love.graphics.circle("fill", cx, cy, r + 4)
            end

            if city.hasPort then
                love.graphics.setColor(0.2, 0.45, 0.7)
                love.graphics.circle("fill", cx, cy, r)
                love.graphics.setColor(0.3, 0.55, 0.8)
                love.graphics.circle("line", cx, cy, r, 8)
                love.graphics.setColor(0.5, 0.7, 1.0, 0.4)
                love.graphics.rectangle("fill", cx - r * 0.4, cy - r * 0.8, r * 0.8, r * 0.6)
            else
                love.graphics.setColor(0.45, 0.35, 0.2)
                love.graphics.circle("fill", cx, cy, r)
                love.graphics.setColor(0.55, 0.45, 0.3)
                love.graphics.circle("line", cx, cy, r)
            end
        end
    end

    love.graphics.setColor(0.2, 0.22, 0.3, 0.3)
    love.graphics.setLineWidth(0.5)
    love.graphics.rectangle("line", mx - 12, my - 12, self.width + 24, self.height + 24)
    love.graphics.setLineWidth(1)
end

function WorldMap:getCityAt(sx, sy, cities)
    local ww, wh = love.graphics.getDimensions()
    local mx, my = (ww - self.width) / 2, (wh - self.height) / 2 + 18
    local rx, ry = (sx - mx) / self.width, (sy - my) / self.height
    if rx < 0 or rx > 1 or ry < 0 or ry > 1 then return nil end
    for _, city in ipairs(cities) do
        local dx, dy = rx - city.x, ry - city.y
        if dx * dx + dy * dy < 0.002 then
            return city
        end
    end
    return nil
end

function WorldMap:screenToMap(sx, sy)
    local ww, wh = love.graphics.getDimensions()
    local mx, my = (ww - self.width) / 2, (wh - self.height) / 2 + 18
    return (sx - mx) / self.width, (sy - my) / self.height
end

return WorldMap
