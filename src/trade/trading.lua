local Logger = require("src.core.logger")
local EventBus = require("src.core.event")
local log = Logger:new("trade")

local TradeSystem = {}
TradeSystem.__index = TradeSystem

function TradeSystem:new()
    return setmetatable({trades = {}}, self)
end

function TradeSystem:buy(player, city, goodId, amount)
    if not player or not city then
        log:error("Buy failed: invalid player or city")
        return 0
    end
    local price = city:getPrice(goodId)
    if not price then
        log:error("Buy failed: no price for %s in %s", goodId, city.name)
        return 0
    end
    local stock = city:getStock(goodId)
    if stock < amount then
        amount = stock
    end
    if amount <= 0 then return 0 end

    local totalCost = price * amount
    if player.gold < totalCost then
        amount = math.floor(player.gold / price)
        totalCost = price * amount
    end
    if amount <= 0 then return 0 end

    city.inventory[goodId] = city.inventory[goodId] - amount
    city.gold = city.gold + totalCost
    player.gold = player.gold - totalCost
    player.inventory[goodId] = (player.inventory[goodId] or 0) + amount

    EventBus:emit("trade:completed", {
        type = "buy", city = city, goodId = goodId,
        amount = amount, totalCost = totalCost, price = price
    })
    log:info("%s bought %dx %s from %s for %d gold",
        "Player", amount, goodId, city.name, totalCost)
    return amount
end

function TradeSystem:sell(player, city, goodId, amount)
    if not player or not city then
        log:error("Sell failed: invalid player or city")
        return 0
    end
    local playerStock = player.inventory[goodId] or 0
    if playerStock < amount then
        amount = playerStock
    end
    if amount <= 0 then return 0 end

    local price = city:getPrice(goodId)
    if not price then
        log:error("Sell failed: no price for %s in %s", goodId, city.name)
        return 0
    end

    local totalRevenue = price * amount
    player.inventory[goodId] = playerStock - amount
    player.gold = player.gold + totalRevenue
    city.inventory[goodId] = (city.inventory[goodId] or 0) + amount
    city.gold = city.gold - totalRevenue

    EventBus:emit("trade:completed", {
        type = "sell", city = city, goodId = goodId,
        amount = amount, totalRevenue = totalRevenue, price = price
    })
    log:info("%s sold %dx %s to %s for %d gold",
        "Player", amount, goodId, city.name, totalRevenue)
    return amount
end

function TradeSystem:serialize()
    return {trades = self.trades}
end

function TradeSystem:deserialize(data)
    self.trades = data.trades or {}
end

return TradeSystem
