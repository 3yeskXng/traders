local Demand = {}

-- Verbrauchskonstanten pro Kopf und Tag (Beispielwerte für das Balancing)
local DEMAND_RATES = {
  GRAIN = 0.015,  -- Grundbedarf (wird von allen konsumiert)
  BEER  = 0.020,  -- Grundbedarf
  MEAT  = 0.005,  -- Gehobener Bedarf
  WINE  = 0.003,  -- Luxusbedarf (nur Wohlhabende & Reiche)
  SPICES = 0.001  -- Reiner Luxus (fast nur Reiche)
}

function Demand.calculate(good, city)
  -- 1. Prüfen, ob die Ware in dieser Stadt überhaupt konsumiert wird
  local isConsumed = false
  for _, cid in ipairs(city.consumes or {}) do
    if cid == good.id then isConsumed = true break end
  end
  if not isConsumed then return 0 end

  -- 2. Bevölkerungsschichten bestimmen (Fallback auf Gesamtbevölkerung, falls nicht definiert)
  -- In deiner city-Struktur kannst du diese drei Werte prozentual oder absolut pflegen:
  local poor = city.pop_poor or math.floor(city.population * 0.70)
  local wellOff = city.pop_well_off or math.floor(city.population * 0.25)
  local rich = city.pop_rich or math.floor(city.population * 0.05)

  -- 3. Spezifischen Konsum je nach Warentyp berechnen
  local baseRate = DEMAND_RATES[good.id] or 0.01
  local totalDemand = 0

  if good.category == "LUXURY" then
    -- Luxusgüter werden von Armen ignoriert, Wohlhabende kaufen etwas, Reiche kaufen viel
    totalDemand = (wellOff * baseRate * 0.5) + (rich * baseRate * 2.0)
    
    -- Wenn die Stadt unzufrieden ist (Wohlstand sinkt), bricht der Luxuskonsum ein
    local stability = city.stability or 1.0 -- Wert von 0.0 bis 1.0
    totalDemand = totalDemand * stability
  elseif good.category == "PROSPERITY" then
    -- Gehobene Güter (z.B. Fleisch, feiner Stoff)
    totalDemand = (poor * baseRate * 0.2) + (wellOff * baseRate * 1.0) + (rich * baseRate * 1.5)
  else
    -- Grundnahrungsmittel/Existenzgüter (Korn, Bier, Fisch, Holz)
    -- Jeder Mensch verbraucht hier die Basis-Rate
    totalDemand = (poor + wellOff + rich) * baseRate
  end

  -- 4. Lokale Produktion dämpft den externen Marktbedarf (Patrizier-Logik)
  -- Wenn die Stadt die Ware selbst produziert, wird ein Teil direkt intern gesättigt
  local isProduced = false
  for _, pid in ipairs(city.produces or {}) do
    if pid == good.id then isProduced = true break end
  end
  if isProduced then 
    totalDemand = totalDemand * 0.6 -- 40% werden direkt über lokale Betriebe gedeckt
  end

  return math.max(0, totalDemand)
end

function Demand.calculateAll(goods, city)
  local demands = {}
  for _, good in ipairs(goods) do
    demands[good.id] = Demand.calculate(good, city)
  end
  return demands
end

return Demand