local Logger = require("src.core.logger")
local json = require("src.lib.json")
local log = Logger:new("goods")

local GoodsManager = {}
GoodsManager.__index = GoodsManager

function GoodsManager:new()
    return setmetatable({goods = {}, goodsById = {}}, self)
end

function GoodsManager:load(path)
    local path = path or "data/goods.json"
    local ok, data = pcall(love.filesystem.read, path)
    if not ok then
        log:error("Failed to load goods from %s", path)
        return false
    end
    local decoded, err = json.decode(data)
    if not decoded then
        log:error("Failed to parse goods JSON: %s", tostring(err))
        return false
    end
    self.goods = decoded
    for _, good in ipairs(self.goods) do
        self.goodsById[good.id] = good
    end
    log:info("Loaded %d goods", #self.goods)
    return true
end

function GoodsManager:getAll()
    return self.goods
end

function GoodsManager:getById(id)
    return self.goodsById[id]
end

function GoodsManager:getCategories()
    local cats = {}
    for _, good in ipairs(self.goods) do
        if not cats[good.category] then
            cats[good.category] = {}
        end
        table.insert(cats[good.category], good)
    end
    return cats
end

return GoodsManager
