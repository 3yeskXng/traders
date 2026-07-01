local Utils = require("core.utils")

local Prices = {}

-- Limits für das Preisspektrum (Patrizier hat extreme Spannen!)
local MIN_PRICE_FACTOR = 0.30   -- Bei absolutem Überfluss fällt der Preis auf max. 30%
local MAX_PRICE_FACTOR = 12.0   -- Bei Hungersnot/Mangel steigt der Preis auf bis zu 1200%
local BASE_CAPACITY_DAYS = 14   -- Wie viele Tage Vorrat soll das "ideale" Lager halten?

function Prices.calculate(basePrice, stock, population, randomFactor, dailyDemand)
  -- 1. Berechne die ideale Lagerkapazität basierend auf dem echten täglichen Verbrauch
  -- Wenn kein Verbrauch übergeben wurde, nutzen wir die alte Bevölkerungs-Formel als Fallback
  local targetCapacity = (dailyDemand or 0) * BASE_CAPACITY_DAYS
  if targetCapacity <= 0 then
    targetCapacity = math.max(300, population * 0.2)
  end

  -- 2. Verhältnis berechnen (0 = komplett leer, 1 = Zielbestand für 2 Wochen erreicht)
  local ratio = stock / targetCapacity

  -- 3. Die Patrizier-Preiskurve (Hyperbolisch-Exponentiell)
  local priceFactor = 1.0

  if ratio >= 1.0 then
    -- ÜBERFLUSS: Preis sinkt sanft ab, je voller das Lager wird
    -- Formel nähert sich langsam dem MIN_PRICE_FACTOR
    priceFactor = MIN_PRICE_FACTOR + (1.0 - MIN_PRICE_FACTOR) / (1.0 + (ratio - 1.0) * 0.5)
  else
    -- KNAPPHEIT: Preis explodiert, je näher das Lager gegen 0 geht
    -- 1 / (ratio + 0.08) sorgt dafür, dass wir niemals durch Null teilen, der Preis bei ratio=0 aber maximiert wird
    priceFactor = 0.5 + (0.5 / (ratio + 0.08))
    -- Zusätzlicher exponentieller Push bei extremer Not (unter 25% Lagerbestand)
    if ratio < 0.25 then
      priceFactor = priceFactor * (1.2 + (0.25 - ratio) * 4.0)
    end
  end

  -- 4. Absichern innerhalb der Systemgrenzen
  priceFactor = Utils.clamp(priceFactor, MIN_PRICE_FACTOR, MAX_PRICE_FACTOR)

  -- 5. Endpreis berechnen unter Einbeziehung von lokalem Markt-Rauschen (Events/Zufall)
  local price = basePrice * priceFactor * (1 + (randomFactor or 0))

  return math.max(1, math.floor(price))
end

function Prices.updateCityPrices(city, goods, randomFactor)
  city.prevPrices = city.prevPrices or {}
  
  -- Wir holen uns das Demand-Modul temporär, um den exakten Verbrauch einzubeziehen
  local Demand = require("simulation.economy.demand")

  for _, good in ipairs(goods) do
    -- Echten aktuellen Tagesbedarf ermitteln
    local dailyDemand = Demand.calculate(good, city)
    local currentStock = city:getStock(good.id)

    -- Historie sichern für UI-Indikatoren (Pfeile nach oben/unten)
    city.prevPrices[good.id] = city.prices[good.id] or Prices.calculate(good.basePrice, currentStock, city.population, randomFactor, dailyDemand)
    
    -- Neuen Preis festlegen
    city.prices[good.id] = Prices.calculate(good.basePrice, currentStock, city.population, randomFactor, dailyDemand)
  end
end

return Prices