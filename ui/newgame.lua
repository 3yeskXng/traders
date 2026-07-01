local EventBus = require("core.eventbus")
local Components = require("ui.components")
local MapRenderer = require("rendering.map")
local Logger = require("core.logger")
local log = Logger.new("newgame")

local NewGame = {}

function NewGame.enter()
  NewGame.mapRenderer = MapRenderer.new()
  NewGame.selectedCity = nil
  NewGame.world = NewGame.world or nil
  NewGame.player = NewGame.player or nil
  NewGame.buttonHover = nil
  NewGame.dragging = false
  NewGame._clickStartX = nil
  NewGame._clickStartY = nil
end

function NewGame.leave()
  NewGame.mapRenderer = nil
  NewGame.selectedCity = nil
  NewGame.buttonHover = nil
  NewGame.dragging = false
end

function NewGame.update(dt)
  if NewGame.mapRenderer and NewGame.world then
    NewGame.mapRenderer:update(dt, NewGame.world)
  end
end

function NewGame.draw()
  local w, h = love.graphics.getDimensions()
  if NewGame.world then
    NewGame.mapRenderer.selectedCity = NewGame.selectedCity
    NewGame.mapRenderer:draw(w, h, NewGame.world)
  end
  Components.drawPanel(w * 0.1, h * 0.08, w * 0.8, h * 0.14, "Neues Spiel")
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("Wähle deine Startstadt und beginne deine Handelsreise.", w * 0.12, h * 0.12, w * 0.76, "left")

  local infoY = h * 0.24
  if NewGame.selectedCity then
    love.graphics.printf("Startstadt: " .. NewGame.selectedCity.name, w * 0.12, infoY, w * 0.76, "left")
    love.graphics.printf("Bevölkerung: " .. NewGame.selectedCity.population, w * 0.12, infoY + 22, w * 0.76, "left")
    love.graphics.printf("Wohlstand: " .. NewGame.selectedCity.wealth, w * 0.12, infoY + 44, w * 0.76, "left")
  else
    love.graphics.printf("Klicke auf eine Stadt, um zu starten.", w * 0.12, infoY, w * 0.76, "left")
  end

  local buttonW, buttonH = 220, 44
  local bx, by = w * 0.7, h * 0.9 - buttonH
  local startHover = NewGame.buttonHover == "start"
  local backHover = NewGame.buttonHover == "back"
  Components.drawButton("Spiel starten", bx, by, buttonW, buttonH, startHover)
  Components.drawButton("Zurück", bx - buttonW - 20, by, buttonW, buttonH, backHover)
end

function NewGame.mousepressed(x, y, button)
  local w, h = love.graphics.getDimensions()
  if not NewGame.world then return end
  local city = NewGame.mapRenderer:getCityAt(x, y, w, h, NewGame.world)
  local buttonW, buttonH = 220, 44
  local bx, by = w * 0.7, h * 0.9 - buttonH
  local backX, backY = bx - buttonW - 20, by

  if Components.isInRect(x, y, bx, by, buttonW, buttonH) and NewGame.selectedCity then
    EventBus:emit("game:start", { city = NewGame.selectedCity })
    return
  elseif Components.isInRect(x, y, backX, backY, buttonW, buttonH) then
    EventBus:emit("state:change", "mainmenu")
    return
  end

  if city then
    NewGame.selectedCity = city
    return
  end

  if NewGame.mapRenderer then
    NewGame.mapRenderer:startDrag(x, y)
    NewGame.dragging = true
    NewGame._clickStartX = x
    NewGame._clickStartY = y
  end
end

function NewGame.mousemoved(x, y, dx, dy)
  local w, h = love.graphics.getDimensions()
  if NewGame.mapRenderer then
    NewGame.mapRenderer.hoveredCity = NewGame.world and NewGame.mapRenderer:getCityAt(x, y, w, h, NewGame.world)
    if NewGame.dragging and NewGame.mapRenderer then
      NewGame.mapRenderer:updateDrag(x, y)
    end
  end

  local buttonW, buttonH = 220, 44
  local bx, by = w * 0.7, h * 0.9 - buttonH
  local backX, backY = bx - buttonW - 20, by
  if Components.isInRect(x, y, bx, by, buttonW, buttonH) then
    NewGame.buttonHover = "start"
  elseif Components.isInRect(x, y, backX, backY, buttonW, buttonH) then
    NewGame.buttonHover = "back"
  else
    NewGame.buttonHover = nil
  end
end

function NewGame.mousereleased(x, y, button)
  if NewGame.dragging and NewGame.mapRenderer then
    NewGame.mapRenderer:stopDrag()
  end
  NewGame.dragging = false
end

function NewGame.keypressed(key)
  if key == "escape" then
    EventBus:emit("state:change", "mainmenu")
  end
end

return NewGame
