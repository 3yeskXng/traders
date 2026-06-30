local Logger = require("src.core.logger")
local log = Logger:new("city")

local City = {}
City.__index = City

function City:new(data)
    local inventory = {}
    if data.initialGoods then
        for id, amount in pairs(data.initialGoods) do
            inventory[id] = amount
        end
    end
    return setmetatable({
        id = data.id,
        name = data.name,
        x = data.x,
        y = data.y,
        population = data.population or 3000,
        wealth = data.wealth or 50,
        gold = data.gold or 10000,
        hasPort = data.hasPort or false,
        description = data.description or "",
        inventory = inventory,
        prices = {},
        produces = data.produces or {},
        consumes = data.consumes or {},
        basePrices = {}
    }, self)
end

function City:updatePrices(goods)
    for _, good in ipairs(goods) do
        local stock = self.inventory[good.id] or 0
        local production = good.baseProduction or 50
        local ratio = stock / (production * 3)
        local fluctuation = 1.0 + (love.math.random() - 0.5) * 0.1
        local priceVar = (1 - ratio) * 0.5
        local price = math.max(1, math.floor(good.basePrice * (1 + priceVar) * fluctuation))
        self.prices[good.id] = price
    end
end

function City:getPrice(goodId)
    return self.prices[goodId]
end

function City:getStock(goodId)
    return self.inventory[goodId] or 0
end

function City:buyGood(goodId, amount)
    local stock = self.inventory[goodId] or 0
    if stock < amount then return 0 end
    local price = self.prices[goodId] or 999
    local cost = price * amount
    if self.gold < cost then
        amount = math.floor(self.gold / price)
        cost = price * amount
    end
    self.inventory[goodId] = stock - amount
    self.gold = self.gold - cost
    return amount
end

function City:sellGood(goodId, amount)
    local price = self.prices[goodId] or 1
    local revenue = price * amount
    self.inventory[goodId] = (self.inventory[goodId] or 0) + amount
    self.gold = self.gold + revenue
    return revenue
end

function City:updateEconomy(dt, goods)
    for _, good in ipairs(goods) do
        local produces = false
        for _, pid in ipairs(self.produces) do
            if pid == good.id then produces = true; break end
        end
        if produces then
            local prodAmount = math.ceil((good.baseProduction or 50) * 0.05)
            self.inventory[good.id] = (self.inventory[good.id] or 0) + prodAmount
        end
    end
    for _, good in ipairs(goods) do
        local consumes = false
        for _, cid in ipairs(self.consumes) do
            if cid == good.id then consumes = true; break end
        end
        if consumes then
            local consAmount = math.ceil((self.population / 5000) * (good.baseProduction or 50) * 0.03)
            self.inventory[good.id] = math.max(0, (self.inventory[good.id] or 0) - consAmount)
        end
    end
    self:updatePrices(goods)
end

function City:serialize()
    return {
        id = self.id, name = self.name, x = self.x, y = self.y,
        population = self.population, wealth = self.wealth,
        gold = self.gold, hasPort = self.hasPort, description = self.description,
        inventory = self.inventory, prices = self.prices,
        produces = self.produces, consumes = self.consumes
    }
end

function City:deserialize(data)
    self.population = data.population
    self.wealth = data.wealth
    self.gold = data.gold
    self.inventory = data.inventory or {}
    self.prices = data.prices or {}
end

return City
