local EventBus = require("core.eventbus")
local Components = require("ui.components")
local Translator = require("core.translator")

local Mouse = {}

function Mouse.pressed(ingame, x, y, button)
  local w, h = love.graphics.getDimensions()
  local world = ingame.world
  if not world then
    return
  end

  if ingame.marketUI and ingame.marketUI.visible then
    local px, py, pw = w * 0.2, h * 0.1, w * 0.6
    local ph = h * 0.8
    if Components.isInRect(x, y, px, py, pw, ph) then
      if ingame.marketUI:mousepressed(x, y, w, h) then
        return
      end
    else
      ingame.marketUI:close()
    end
  end

  if y > h - 35 and y < h then
    if x > 200 and x < 230 then
      world.time:prevSpeed()
    end
    if x > 240 and x < 270 then
      world.time:nextSpeed()
    end
    return
  end

  if ingame.mapRenderer then
    ingame.mapRenderer:startDrag(x, y)
    ingame._clickStartX = x
    ingame._clickStartY = y
  end
end

function Mouse.moved(ingame, x, y, dx, dy)
  if not ingame.mapRenderer then
    return
  end

  if ingame.mapRenderer.dragging then
    local dxMove = math.abs(x - (ingame._clickStartX or x))
    local dyMove = math.abs(y - (ingame._clickStartY or y))
    if dxMove > 5 or dyMove > 5 then
      ingame.mapRenderer:updateDrag(x, y)
    end
    return
  end

  local w, h = love.graphics.getDimensions()
  local world = ingame.world
  ingame.mapRenderer.hoveredCity = world and ingame.mapRenderer:getCityAt(x, y, w, h, world)
  if ingame.marketUI then
    ingame.marketUI:mousemoved(x, y)
  end
end

function Mouse.released(ingame, x, y, button)
  if not ingame.mapRenderer then
    return
  end

  local wasDragging = ingame.mapRenderer.dragging
  ingame.mapRenderer:stopDrag()
  if not wasDragging then
    return
  end

  local dxDist = math.abs(x - (ingame._clickStartX or x))
  local dyDist = math.abs(y - (ingame._clickStartY or y))
  if dxDist <= 5 and dyDist <= 5 then
    local w, h = love.graphics.getDimensions()
    local world = ingame.world
    local city = ingame.mapRenderer:getCityAt(x, y, w, h, world)
    if city then
      if ingame.currentCity and city.id ~= ingame.currentCity.id and not world.travel.traveling then
        EventBus:emit("travel:start", {
          from = ingame.currentCity,
          to = city,
        })
        ingame:notify(
          Translator:t("status.travel_started", ingame.currentCity.name, city.name),
          { 0.5, 0.8, 1 }
        )
      elseif ingame.currentCity and city.id == ingame.currentCity.id then
        ingame.marketUI:open(city, world.players[1])
      else
        ingame.marketUI:open(city, world.players[1])
      end
    end
  end
end

return Mouse
