local Logger = require("src.core.logger")
local EventBus = require("src.core.event")
local Utils = require("src.core.utils")
local json = require("src.lib.json")
local log = Logger:new("game")

local Game = {}
Game.__index = Game

function Game:new()
    return setmetatable({
        player = {
            gold = 5000,
            inventory = {},
            city = nil
        },
        cities = {},
        goods = {},
        goodsManager = nil,
        time = nil,
        trade = nil,
        save = nil,
        map = nil,
        travel = nil,
        notifications = nil,
        audio = nil,
        running = false
    }, self)
end

function Game:init()
    local GoodsManager = require("src.economy.goods"):new()
    if not GoodsManager:load("data/goods.json") then
        log:error("Failed to load goods")
        return false
    end
    self.goods = GoodsManager:getAll()
    self.goodsManager = GoodsManager

    self.time = require("src.world.time"):new()

    local City = require("src.cities.city")
    local ok, cityData = pcall(love.filesystem.read, "data/cities.json")
    if ok then
        local decoded, err = json.decode(cityData)
        if decoded then
            for _, data in ipairs(decoded) do
                local city = City:new(data)
                table.insert(self.cities, city)
            end
        end
    end
    for _, city in ipairs(self.cities) do
        city:updatePrices(self.goods)
    end
    self.player.city = self.cities[1]
    log:info("Loaded %d cities", #self.cities)

    self.trade = require("src.trade.trading"):new()
    self.save = require("src.save.serializer"):new()
    self.map = require("src.world.map"):new()
    self.travel = require("src.travel.travel"):new()
    self.notifications = require("src.notification.notify"):new()
    self.audio = require("src.audio.audio"):new()

    self.running = true
    log:info("Game initialized successfully")
    return true
end

function Game:update(dt)
    if not self.running then return end
    if self.map then self.map:update(dt) end
    if self.notifications then self.notifications:update(dt) end
    if self.travel then
        local wasTraveling = self.travel.traveling
        local travelSpeed = math.max(self.time:getSpeed(), 1)
        self.travel:update(dt, travelSpeed)
        if wasTraveling and not self.travel.traveling and self.travel.toCity then
            self.player.city = self.travel.toCity
            if self.notifications then
                self.notifications:add("Angekommen in " .. self.travel.toCity.name, "travel")
            end
        end
    end
    local ticked = self.time:update(dt)
    if ticked then
        self:onDayPassed()
    end
end

function Game:onDayPassed()
    for _, city in ipairs(self.cities) do
        city:updateEconomy(0.1, self.goods)
    end
end

function Game:cleanup()
    self.running = false
    self.cities = {}
    self.goods = {}
    log:info("Game cleaned up")
end

return Game
