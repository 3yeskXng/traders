local MarketDraw = require("ui.market.draw")
local Logic = require("ui.market.logic")

local MarketUI = {}
MarketUI.__index = MarketUI

local AMOUNT_CHOICES = { 1, 5, 10, 50, 100 }

function MarketUI.new()
  return setmetatable({
    city = nil,
    player = nil,
    selectedAmount = 5,
    visible = false,
    message = nil,
    messageTimer = 0,
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
  return Logic.handleMousePress(self, x, y, w, h)
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
