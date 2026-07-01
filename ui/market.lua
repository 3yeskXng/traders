local EventBus = require("core.eventbus")
local Components = require("ui.components")
local Translator = require("core.translator")
local MarketDraw = require("ui.market.draw")

local MarketUI = {}
MarketUI.__index = MarketUI

local AMOUNT_CHOICES = { 1, 5, 10, 50, 100 }

function MarketUI.new()
  return setmetatable({
    city = nil, player = nil,
    selectedAmount = 5,
    visible = false,
    message = nil, messageTimer = 0,
  }, MarketUI)
end

function MarketUI:open(city, player)
  self.city = city
  self.player = player
  self.visible = true
  self.selectedAmount = 5
  self.message = nil
  self.messageTimer = 0
end

function MarketUI:close()
  self.visible = false
end

function MarketUI:showMessage(text)
  self.message = text
  self.messageTimer = 3
end

function MarketUI:draw(w, h)
  MarketDraw.draw(self, w, h)
end

function MarketUI:mousepressed(x, y, w, h)
  if not self.visible then return false end
  local px, py, pw = w * 0.2, h * 0.1, w * 0.6
  local ph = h * 0.8

  if Components.isInRect(x, y, px + pw - 30, py + 5, 25, 25) then
    self:close()
    return true
  end

  local goods = EventBus.world and EventBus.world.goods and EventBus.world.goods:getAll() or {}
  local rowHeight = 28
  local goodsCount = #goods
  local totalHeight = goodsCount * rowHeight
  local amountY = py + 30 + totalHeight + 10

  for i, amt in ipairs(AMOUNT_CHOICES) do
    local ax = px + 80 + (i - 1) * 50
    if Components.isInRect(x, y, ax, amountY + 2, 45, 20) then
      self.selectedAmount = amt
      return true
    end
  end

  for i, good in ipairs(goods) do
    local price = self.city.prices[good.id] or 0
    local stock = self.city:getStock(good.id)
    local playerStock = self.player and (self.player.inventory[good.id] or 0) or 0
    local ry = py + 30 + (i - 1) * rowHeight
    local bx = px + 370
    local sx = bx + 45

    local amount = self.selectedAmount
    if amount == 0 then amount = stock end

    if stock > 0 and price > 0 and self.player and self.player.gold >= price then
      if Components.isInRect(x, y, bx, ry, 40, rowHeight) then
        local buyAmt = math.min(amount, stock, math.floor(self.player.gold / price))
        EventBus:emit("trade:buy", { city = self.city, goodId = good.id, amount = buyAmt })
        self:showMessage(Translator:t("market.message.buy", buyAmt, good.name))
        return true
      end
    end

    if playerStock > 0 then
      if Components.isInRect(x, y, sx, ry, 40, rowHeight) then
        local sellAmt = math.min(amount, playerStock)
        EventBus:emit("trade:sell", { city = self.city, goodId = good.id, amount = sellAmt })
        self:showMessage(Translator:t("market.message.sell", sellAmt, good.name))
        return true
      end
    end
  end

  return false
end

function MarketUI:mousemoved(x, y)
  self._hoverX = x
  self._hoverY = y
end

function MarketUI:update(dt)
  if self.messageTimer > 0 then
    self.messageTimer = self.messageTimer - dt
  end
end

return MarketUI
