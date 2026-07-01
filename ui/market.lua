local EventBus = require("core.eventbus")
local Components = require("ui.components")

local MarketUI = {}
MarketUI.__index = MarketUI

function MarketUI.new()
  return setmetatable({
    city = nil, player = nil,
    selectedAmount = 5,
    amounts = { 1, 5, 10, 50, 0 },
    visible = false,
  }, MarketUI)
end

function MarketUI:open(city, player)
  self.city = city
  self.player = player
  self.visible = true
end

function MarketUI:close()
  self.visible = false
end

function MarketUI:draw(w, h)
  if not self.visible or not self.city then return end
  local px, py, pw, ph = w * 0.25, h * 0.15, w * 0.5, h * 0.7
  Components.drawPanel(px, py, pw, ph, self.city.name .. " - Markt")
  local goods = EventBus.world and EventBus.world.goods and EventBus.world.goods:getAll() or {}
  local gy = py + 30
  for _, good in ipairs(goods) do
    local price = self.city.prices[good.id] or 0
    local stock = self.city:getStock(good.id)
    local playerStock = self.player and (self.player.inventory[good.id] or 0) or 0
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(good.name, px + 10, gy)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print(price .. " G", px + 120, gy)
    love.graphics.print("Lager: " .. stock, px + 200, gy)
    love.graphics.print("Spieler: " .. playerStock, px + 320, gy)
    gy = gy + 25
  end
  Components.drawLabel("X", px + pw - 20, py + 5, { 0.8, 0.2, 0.2 })
end

function MarketUI:mousepressed(x, y, w, h)
  if not self.visible then return false end
  local px, py, pw = w * 0.25, h * 0.15, w * 0.5
  if Components.isInRect(x, y, px + pw - 30, py + 5, 25, 25) then
    self:close()
    return true
  end
  return false
end

return MarketUI
