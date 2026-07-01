local Logger = require("core.logger")
local Goods = require("simulation.goods.goods")
local log = Logger.new("goodsmanager")

local GoodsManager = {}
GoodsManager.__index = GoodsManager

function GoodsManager.new()
  return setmetatable({ list = {}, byId = {} }, GoodsManager)
end

function GoodsManager:load(data)
  for _, entry in ipairs(data) do
    local good = Goods.new(entry)
    table.insert(self.list, good)
    self.byId[good.id] = good
  end
  log:info("Loaded %d goods", #self.list)
end

function GoodsManager:getAll()
  return self.list
end

function GoodsManager:getById(id)
  return self.byId[id]
end

function GoodsManager:getCategories()
  local cats = {}
  for _, good in ipairs(self.list) do
    cats[good.category] = cats[good.category] or {}
    table.insert(cats[good.category], good)
  end
  return cats
end

return GoodsManager
