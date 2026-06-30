local Logger = require("src.core.logger")
local log = Logger:new("inventory")

local Inventory = {}
Inventory.__index = Inventory

function Inventory:new(owner)
    return setmetatable({
        owner = owner,
        items = {},
        capacity = 100,
        gold = 0
    }, self)
end

function Inventory:add(goodId, amount)
    self.items[goodId] = (self.items[goodId] or 0) + amount
end

function Inventory:remove(goodId, amount)
    local current = self.items[goodId] or 0
    if current < amount then return false end
    self.items[goodId] = current - amount
    return true
end

function Inventory:getCount(goodId)
    return self.items[goodId] or 0
end

function Inventory:getTotalItems()
    local total = 0
    for _, count in pairs(self.items) do
        total = total + count
    end
    return total
end

function Inventory:serialize()
    return {items = self.items, capacity = self.capacity, gold = self.gold}
end

function Inventory:deserialize(data)
    self.items = data.items or {}
    self.capacity = data.capacity or 100
    self.gold = data.gold or 0
end

return Inventory
