local EventBus = require("core.eventbus")
local Components = require("ui.components")
local Translator = require("core.translator")

local AMOUNT_CHOICES = { 1, 5, 10, 50, 100 }

local Logic = {}

function Logic.handleMousePress(market, x, y, w, h)
  if not market.visible then
    return false
  end

  local px, py, pw = w * 0.2, h * 0.1, w * 0.6
  local ph = h * 0.8

  if Components.isInRect(x, y, px + pw - 30, py + 5, 25, 25) then
    market:close()
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
      market.selectedAmount = amt
      return true
    end
  end

  for i, good in ipairs(goods) do
    local price = market.city.prices[good.id] or 0
    local stock = market.city:getStock(good.id)
    local playerStock = market.player and (market.player.inventory[good.id] or 0) or 0
    local ry = py + 30 + (i - 1) * rowHeight
    local bx = px + 370
    local sx = bx + 45

    local amount = market.selectedAmount
    if amount == 0 then
      amount = stock
    end

    if stock > 0 and price > 0 and market.player and market.player.gold >= price then
      if Components.isInRect(x, y, bx, ry, 40, rowHeight) then
        local buyAmt = math.min(amount, stock, math.floor(market.player.gold / price))
        EventBus:emit("trade:buy", {
          city = market.city,
          goodId = good.id,
          amount = buyAmt,
        })
        market:showMessage(Translator:t("market.message.buy", buyAmt, good.name))
        return true
      end
    end

    if playerStock > 0 then
      if Components.isInRect(x, y, sx, ry, 40, rowHeight) then
        local sellAmt = math.min(amount, playerStock)
        EventBus:emit("trade:sell", {
          city = market.city,
          goodId = good.id,
          amount = sellAmt,
        })
        market:showMessage(Translator:t("market.message.sell", sellAmt, good.name))
        return true
      end
    end
  end

  return false
end

return Logic
