local EventBus = require("core.eventbus")
local Components = require("ui.components")
local Logger = require("core.logger")
local log = Logger.new("marketui")

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
  if not self.visible or not self.city then return end
  local px, py, pw = w * 0.2, h * 0.1, w * 0.6
  local ph = h * 0.8
  Components.drawPanel(px, py, pw, ph, self.city.name .. " - Markt")

  local goods = EventBus.world and EventBus.world.goods and EventBus.world.goods:getAll() or {}
  local gy = py + 30
  local rowHeight = 28
  local goodsCount = #goods

  for i, good in ipairs(goods) do
    local price = self.city.prices[good.id] or 0
    local stock = self.city:getStock(good.id)
    local playerStock = self.player and (self.player.inventory[good.id] or 0) or 0
    local ry = gy + (i - 1) * rowHeight

    love.graphics.setColor(0.9, 0.9, 0.8)
    love.graphics.print(good.name, px + 10, ry)

    local prevPrice = (self.city.prevPrices or {})[good.id] or price
    if price > prevPrice then
      love.graphics.setColor(0.8, 0.3, 0.3)
      love.graphics.print("+", px + 95, ry)
    elseif price < prevPrice then
      love.graphics.setColor(0.3, 0.8, 0.3)
      love.graphics.print("-", px + 95, ry)
    else
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.print("=", px + 95, ry)
    end

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print(Components.formatNumber(price) .. " G", px + 110, ry)

    love.graphics.setColor(0.6, 0.6, 0.6)
    local stockLabel = "L: " .. Components.formatNumber(stock)
    if stock <= 0 then
      love.graphics.setColor(0.8, 0.3, 0.3)
    end
    love.graphics.print(stockLabel, px + 200, ry)

    love.graphics.setColor(0.6, 0.7, 0.6)
    love.graphics.print("S: " .. Components.formatNumber(playerStock), px + 290, ry)

    local bx = px + 370
    if stock > 0 and self.player and price > 0 and self.player.gold >= price then
      if Components.isInRect(self._hoverX or -1, self._hoverY or -1, bx, ry, 40, rowHeight) then
        love.graphics.setColor(0.3, 0.7, 0.3)
      else
        love.graphics.setColor(0.2, 0.5, 0.2)
      end
      love.graphics.rectangle("fill", bx, ry, 40, rowHeight)
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf("Kauf", bx, ry + rowHeight / 2 - 7, 40, "center")
    end

    local sx = bx + 45
    if playerStock > 0 then
      if Components.isInRect(self._hoverX or -1, self._hoverY or -1, sx, ry, 40, rowHeight) then
        love.graphics.setColor(0.8, 0.3, 0.3)
      else
        love.graphics.setColor(0.6, 0.2, 0.2)
      end
      love.graphics.rectangle("fill", sx, ry, 40, rowHeight)
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf("Verk", sx, ry + rowHeight / 2 - 7, 40, "center")
    end
  end

  local totalHeight = goodsCount * rowHeight
  local amountY = py + 30 + totalHeight + 10
  local panelBottom = py + ph - 35
  if amountY + 30 < panelBottom then
    Components.drawPanel(px + 10, amountY, pw - 20, 25, nil)
    love.graphics.setColor(0.9, 0.9, 0.8)
    love.graphics.print("Menge:", px + 15, amountY + 5)
    for i, amt in ipairs(AMOUNT_CHOICES) do
      local ax = px + 80 + (i - 1) * 50
      local label = amt == 0 and "Max" or tostring(amt)
      if self.selectedAmount == amt then
        love.graphics.setColor(0.4, 0.6, 0.4)
        love.graphics.rectangle("fill", ax, amountY + 2, 45, 20)
      end
      if Components.isInRect(self._hoverX or -1, self._hoverY or -1, ax, amountY + 2, 45, 20) then
        love.graphics.setColor(0.5, 0.5, 0.3)
        love.graphics.rectangle("line", ax, amountY + 2, 45, 20)
      end
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(label, ax, amountY + 4, 45, "center")
    end
  end

  if self.message and self.messageTimer > 0 then
    love.graphics.setColor(0.9, 0.9, 0.6, math.min(1, self.messageTimer))
    love.graphics.printf(self.message, px + 10, panelBottom + 5, pw - 20, "center")
  end

  love.graphics.setColor(0.8, 0.2, 0.2)
  love.graphics.printf("X", px + pw - 20, py + 5, 15, "center")
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
        self:showMessage("Gekauft: " .. buyAmt .. " " .. good.name)
        return true
      end
    end

    if playerStock > 0 then
      if Components.isInRect(x, y, sx, ry, 40, rowHeight) then
        local sellAmt = math.min(amount, playerStock)
        EventBus:emit("trade:sell", { city = self.city, goodId = good.id, amount = sellAmt })
        self:showMessage("Verkauft: " .. sellAmt .. " " .. good.name)
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