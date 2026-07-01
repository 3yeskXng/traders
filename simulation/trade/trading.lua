local Logger = require("core.logger")
local EventBus = require("core.eventbus")
local Prices = require("simulation.economy.prices") -- Wichtig: Wir brauchen die Preisberechnung live!
local log = Logger.new("trading")

local TradeSystem = {}
TradeSystem.__index = TradeSystem

function TradeSystem.new()
  return setmetatable({ log = {} }, TradeSystem)
end

-- Hilfsfunktion, um die Stadt-Struktur für die Live-Preisberechnung zu faken
local function getTempCityState(city, goodId, stockOffset)
  return {
    population = city.population,
    getStock = function() return math.max(0, city:getStock(goodId) + stockOffset) end
  }
end

function TradeSystem:buy(buyer, city, goodId, maxAmount, baseGoodData, randomFactor)
  local totalCost = 0
  local actualTraded = 0
  
  -- 1. Vorab-Checks: Hat die Stadt überhaupt Ware? Hat der Käufer überhaupt Gold?
  local availableStock = city:getStock(goodId)
  if availableStock <= 0 or buyer.gold <= 0 then return 0 end
  
  -- Wir begrenzen die Kaufabsicht auf das, was maximal im Lager ist
  local loopAmount = math.min(maxAmount, availableStock)

  -- 2. Der "Patrizier-Loop": Wir simulieren den Kauf Einheit für Einheit (bzw. in kleinen Schritten)
  -- Für bessere Performance bei riesigen Mengen simulieren wir hier stückweise
  for i = 1, loopAmount do
    -- Berechne den Preis für GENAU diese nächste Einheit basierend auf dem schrumpfenden Lager
    -- stockOffset ist negativ, weil das Lager durch unseren Kauf sinkt
    local tempCity = getTempCityState(city, goodId, -actualTraded)
    local currentUnitPrice = Prices.calculate(baseGoodData.basePrice, tempCity:getStock(), city.population, randomFactor)
    
    -- Kann sich der Käufer diese EINE nächste Einheit noch leisten?
    if buyer.gold >= (totalCost + currentUnitPrice) then
      totalCost = totalCost + currentUnitPrice
      actualTraded = actualTraded + 1
    else
      -- Transaktion abbrechen, wenn das Geld ausgeht
      break
    end
  end

  -- 3. Transaktion physisch ausführen, falls Einheiten gekauft wurden
  if actualTraded > 0 then
    buyer.gold = buyer.gold - totalCost
    city.gold = (city.gold or 0) + totalCost -- Konsistent .gold statt .wealth verwendet!
    
    city:removeStock(goodId, actualTraded)
    buyer.inventory[goodId] = (buyer.inventory[goodId] or 0) + actualTraded
    
    -- Den finalen Preis in der Stadt nach dem Trade sofort aktualisieren
    city.prices[goodId] = Prices.calculate(baseGoodData.basePrice, city:getStock(goodId), city.population, randomFactor)

    table.insert(self.log, { type = "buy", goodId = goodId, amount = actualTraded, totalPrice = totalCost, avgPrice = totalCost / actualTraded })
    EventBus:emit("trade:completed", { type = "buy", goodId = goodId, amount = actualTraded, totalPrice = totalCost, city = city })
  end

  return actualTraded
end

function TradeSystem:sell(seller, city, goodId, maxAmount, baseGoodData, randomFactor)
  local totalRevenue = 0
  local actualTraded = 0
  
  -- 1. Vorab-Checks: Hat der Verkäufer die Ware? Hat die Stadt überhaupt Gold, um zu zahlen?
  local currentInventory = seller.inventory[goodId] or 0
  if currentInventory <= 0 or (city.gold or 0) <= 0 then return 0 end
  
  -- Wir begrenzen die Verkaufsabsicht auf das, was der Spieler im Inventar hat
  local loopAmount = math.min(maxAmount, currentInventory)

  -- 2. Der "Patrizier-Loop": Wir simulieren den Verkauf Einheit für Einheit
  for i = 1, loopAmount do
    -- Berechne den Preis für GENAU diese nächste Einheit basierend auf dem wachsenden Lager der Stadt
    -- stockOffset ist positiv, weil das Lager durch unseren Verkauf steigt
    local tempCity = getTempCityState(city, goodId, actualTraded)
    local currentUnitPrice = Prices.calculate(baseGoodData.basePrice, tempCity:getStock(), city.population, randomFactor)
    
    -- Kann die Stadt sich diese EINE nächste Einheit noch leisten?
    if city.gold >= (totalRevenue + currentUnitPrice) then
      totalRevenue = totalRevenue + currentUnitPrice
      actualTraded = actualTraded + 1
    else
      -- Abbrechen, wenn der Stadt das Geld ausgeht
      break
    end
  end

  -- 3. Transaktion physisch ausführen, falls Einheiten verkauft wurden
  if actualTraded > 0 then
    seller.gold = (seller.gold or 0) + totalRevenue
    city.gold = city.gold - totalRevenue
    
    seller.inventory[goodId] = currentInventory - actualTraded
    city:addStock(goodId, actualTraded)
    
    -- Den finalen Preis in der Stadt nach dem Trade sofort aktualisieren
    city.prices[goodId] = Prices.calculate(baseGoodData.basePrice, city:getStock(goodId), city.population, randomFactor)

    table.insert(self.log, { type = "sell", goodId = goodId, amount = actualTraded, totalPrice = totalRevenue, avgPrice = totalRevenue / actualTraded })
    EventBus:emit("trade:completed", { type = "sell", goodId = goodId, amount = actualTraded, totalPrice = totalRevenue, city = city })
  end

  return actualTraded
end

return TradeSystem