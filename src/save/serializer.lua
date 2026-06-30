local Logger = require("src.core.logger")
local json = require("src.lib.json")
local log = Logger:new("save")

local SaveManager = {}
SaveManager.__index = SaveManager

function SaveManager:new()
    return setmetatable({saveSlots = 5, currentSlot = nil}, self)
end

function SaveManager:save(game, slot)
    local slot = slot or self.currentSlot or 1
    local data = {
        version = "0.1.0",
        timestamp = os.time(),
        player = {
            gold = game.player.gold,
            inventory = game.player.inventory,
            city = game.player.city
        },
        time = game.time:serialize(),
        cities = {}
    }
    for _, city in ipairs(game.cities) do
        table.insert(data.cities, city:serialize())
    end
    local jsonStr = json.encode(data)
    local filename = string.format("save_%d.json", slot)
    local ok, err = pcall(love.filesystem.write, filename, jsonStr)
    if ok then
        self.currentSlot = slot
        log:info("Game saved to slot %d", slot)
        return true
    else
        log:error("Failed to save: %s", tostring(err))
        return false
    end
end

function SaveManager:load(game, slot)
    local slot = slot or self.currentSlot or 1
    local filename = string.format("save_%d.json", slot)
    local ok, data = pcall(love.filesystem.read, filename)
    if not ok then
        log:error("No save found in slot %d", slot)
        return false
    end
    local decoded, err = json.decode(data)
    if not decoded then
        log:error("Failed to parse save data")
        return false
    end
    if decoded.version ~= "0.1.0" then
        log:warn("Save version mismatch: %s", decoded.version or "unknown")
    end
    game.player.gold = decoded.player.gold
    game.player.inventory = decoded.player.inventory or {}
    game.player.city = decoded.player.city
    if decoded.time then
        game.time:deserialize(decoded.time)
    end
    if decoded.cities then
        for i, cityData in ipairs(decoded.cities) do
            if game.cities[i] then
                game.cities[i]:deserialize(cityData)
            end
        end
    end
    self.currentSlot = slot
    log:info("Game loaded from slot %d", slot)
    return true
end

function SaveManager:listSaves()
    local saves = {}
    for i = 1, self.saveSlots do
        local filename = string.format("save_%d.json", i)
        local ok, data = pcall(love.filesystem.read, filename)
        if ok and data then
            local decoded, err = json.decode(data)
            if decoded then
                table.insert(saves, {
                    slot = i,
                    timestamp = decoded.timestamp,
                    date = os.date("%c", decoded.timestamp),
                    gold = decoded.player and decoded.player.gold or 0,
                    day = decoded.time and string.format("%d.%d.%d",
                        decoded.time.day, decoded.time.month, decoded.time.year) or "?"
                })
            end
        end
    end
    return saves
end

function SaveManager:deleteSave(slot)
    local filename = string.format("save_%d.json", slot)
    local ok, err = pcall(os.remove, filename)
    if ok then
        log:info("Save slot %d deleted", slot)
        return true
    end
    return false
end

return SaveManager
