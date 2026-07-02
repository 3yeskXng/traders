local Components = require("ui.components")
local Translator = require("core.translator")

local MapTooltip = {}

function MapTooltip.drawCityTooltip(w, h, city, world, mx, my)
  local goods = world and world.goods
  if not goods then return end

  local tw, th = 200, 80
  local tx = math.min(mx + 15, w - tw - 10)
  local ty = math.min(my + 15, h - th - 10)

  love.graphics.setColor(0.88, 0.82, 0.72, 0.95)
  love.graphics.rectangle("fill", tx, ty, tw, th)
  love.graphics.setColor(0.35, 0.25, 0.15)
  love.graphics.rectangle("line", tx, ty, tw, th)

  love.graphics.setColor(0.3, 0.2, 0.1)
  love.graphics.setFont(require("core.fonts").getFont(13))
  love.graphics.print(city.name, tx + 5, ty + 3)
  love.graphics.setFont(require("core.fonts").getFont(11))

  love.graphics.setColor(0.4, 0.3, 0.15)
  love.graphics.print(Translator:t("tooltip.population", Components.formatNumber(city.population)), tx + 5, ty + 20)
  love.graphics.print(Translator:t("tooltip.wealth", Components.formatNumber(city.wealth)), tx + 5, ty + 33)

  local produces = {}
  for _, pid in ipairs(city.produces) do
    local g = goods.byId and goods.byId[pid]
    table.insert(produces, g and g.name or pid)
  end
  if #produces > 0 then
    love.graphics.setColor(0.3, 0.55, 0.2)
    love.graphics.print(Translator:t("tooltip.produces", table.concat(produces, ", ")), tx + 5, ty + 48)
  end

  local consumes = {}
  for _, cid in ipairs(city.consumes) do
    local g = goods.byId and goods.byId[cid]
    table.insert(consumes, g and g.name or cid)
  end
  if #consumes > 0 then
    love.graphics.setColor(0.7, 0.25, 0.2)
    love.graphics.print(Translator:t("tooltip.consumes", table.concat(consumes, ", ")), tx + 5, ty + 63)
  end

  love.graphics.setFont(require("core.fonts").getFont(12))
end

return MapTooltip
