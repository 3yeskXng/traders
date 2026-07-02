local EventBus = require("core.eventbus")
local Components = require("ui.components")

local Input = {}

function Input.keypressed(newgame, key)
  if key == "escape" then
    EventBus:emit("state:change", "mainmenu")
  end
end

function Input.mousepressed(newgame, x, y, button)
  local w, h = love.graphics.getDimensions()
  if not newgame.world then
    return
  end

  local city = newgame.mapRenderer:getCityAt(x, y, w, h, newgame.world)
  local buttonW, buttonH = 220, 44
  local bx, by = w * 0.7, h * 0.9 - buttonH
  local backX, backY = bx - buttonW - 20, by

  if Components.isInRect(x, y, bx, by, buttonW, buttonH) and newgame.selectedCity then
    EventBus:emit("game:start", { city = newgame.selectedCity })
    return
  elseif Components.isInRect(x, y, backX, backY, buttonW, buttonH) then
    EventBus:emit("state:change", "mainmenu")
    return
  end

  if city then
    newgame.selectedCity = city
    return
  end

  if newgame.mapRenderer then
    newgame.mapRenderer:startDrag(x, y)
    newgame.dragging = true
    newgame._clickStartX = x
    newgame._clickStartY = y
  end
end

function Input.mousemoved(newgame, x, y, dx, dy)
  local w, h = love.graphics.getDimensions()

  if newgame.mapRenderer then
    newgame.mapRenderer.hoveredCity = newgame.world
      and newgame.mapRenderer:getCityAt(x, y, w, h, newgame.world)
    if newgame.dragging and newgame.mapRenderer then
      newgame.mapRenderer:updateDrag(x, y)
    end
  end

  local buttonW, buttonH = 220, 44
  local bx, by = w * 0.7, h * 0.9 - buttonH
  local backX, backY = bx - buttonW - 20, by

  if Components.isInRect(x, y, bx, by, buttonW, buttonH) then
    newgame.buttonHover = "start"
  elseif Components.isInRect(x, y, backX, backY, buttonW, buttonH) then
    newgame.buttonHover = "back"
  else
    newgame.buttonHover = nil
  end
end

function Input.mousereleased(newgame, x, y, button)
  if newgame.dragging and newgame.mapRenderer then
    newgame.mapRenderer:stopDrag()
  end
  newgame.dragging = false
end

return Input
