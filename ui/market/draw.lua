local Components = require("ui.components")
local Translator = require("core.translator")
local EventBus = require("core.eventbus")

local MarketDraw = {}

local AMOUNT_CHOICES = { 1, 5, 10, 50, 100 }

function MarketDraw.draw(market, w, h)
  if not market.visible or not market.city then return end
  local px, py, pw = w * 0.2, h * 0.1, w * 0.6
  local ph = h * 0.8
  Components.drawPanel(px, py, pw, ph, Translator:t("market.title", market.city.name))

  local goods = EventBus.world and EventBus.world.goods and EventBus.world.goods:getAll() or {}
  local rowHeight = 28
  local goodsCount = #goods

  for i, good in ipairs(goods) do
    local price = market.city.prices[good.id] or 0
    local stock = market.city:getStock(good.id)
    local playerStock = market.player and (market.player.inventory[good.id] or 0) or 0
    local ry = py + 30 + (i - 1) * rowHeight

    love.graphics.setColor(0.9, 0.9, 0.8)
    love.graphics.print(good.name, px + 10, ry)

    local prevPrice = (market.city.prevPrices or {})[good.id] or price
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
    love.graphics.print(Components.formatNumber(price) .. " " .. Translator:t("market.currency"), px + 110, ry)

    love.graphics.setColor(0.6, 0.6, 0.6)
    local stockLabel = Translator:t("market.stock", Components.formatNumber(stock))
    if stock <= 0 then
      love.graphics.setColor(0.8, 0.3, 0.3)
    end
    love.graphics.print(stockLabel, px + 200, ry)

    love.graphics.setColor(0.6, 0.7, 0.6)
    love.graphics.print(Translator:t("market.owned", Components.formatNumber(playerStock)), px + 290, ry)

    local bx = px + 370
    if stock > 0 and market.player and price > 0 and market.player.gold >= price then
      if Components.isInRect(market._hoverX or -1, market._hoverY or -1, bx, ry, 40, rowHeight) then
        love.graphics.setColor(0.3, 0.7, 0.3)
      else
        love.graphics.setColor(0.2, 0.5, 0.2)
      end
      love.graphics.rectangle("fill", bx, ry, 40, rowHeight)
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(Translator:t("market.buy"), bx, ry + rowHeight / 2 - 7, 40, "center")
    end

    local sx = bx + 45
    if playerStock > 0 then
      if Components.isInRect(market._hoverX or -1, market._hoverY or -1, sx, ry, 40, rowHeight) then
        love.graphics.setColor(0.8, 0.3, 0.3)
      else
        love.graphics.setColor(0.6, 0.2, 0.2)
      end
      love.graphics.rectangle("fill", sx, ry, 40, rowHeight)
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(Translator:t("market.sell"), sx, ry + rowHeight / 2 - 7, 40, "center")
    end
  end

  local totalHeight = goodsCount * rowHeight
  local amountY = py + 30 + totalHeight + 10
  local panelBottom = py + ph - 35
  if amountY + 30 < panelBottom then
    Components.drawPanel(px + 10, amountY, pw - 20, 25, nil)
    love.graphics.setColor(0.9, 0.9, 0.8)
    love.graphics.print(Translator:t("market.amount"), px + 15, amountY + 5)
    for i, amt in ipairs(AMOUNT_CHOICES) do
      local ax = px + 80 + (i - 1) * 50
      local label = amt == 0 and Translator:t("market.max") or tostring(amt)
      if market.selectedAmount == amt then
        love.graphics.setColor(0.4, 0.6, 0.4)
        love.graphics.rectangle("fill", ax, amountY + 2, 45, 20)
      end
      if Components.isInRect(market._hoverX or -1, market._hoverY or -1, ax, amountY + 2, 45, 20) then
        love.graphics.setColor(0.5, 0.5, 0.3)
        love.graphics.rectangle("line", ax, amountY + 2, 45, 20)
      end
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(label, ax, amountY + 4, 45, "center")
    end
  end

  if market.message and market.messageTimer > 0 then
    love.graphics.setColor(0.9, 0.9, 0.6, math.min(1, market.messageTimer))
    love.graphics.printf(market.message, px + 10, panelBottom + 5, pw - 20, "center")
  end

  love.graphics.setColor(0.8, 0.2, 0.2)
  love.graphics.printf(Translator:t("button.close"), px + pw - 20, py + 5, 15, "center")
end

return MarketDraw
