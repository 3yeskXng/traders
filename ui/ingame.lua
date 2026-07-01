local EventBus = require("core.eventbus")
local Utils = require("core.utils")
local Components = require("ui.components")
local MapRenderer = require("rendering.map")
local MarketUI = require("ui.market")
local Logger = require("core.logger")
local log = Logger.new("ingame")

local InGame = {}

function InGame.enter()
  InGame.mapRenderer = MapRenderer.new()
  InGame.marketUI = MarketUI.new()
  InGame.notifications = {}
  InGame.currentCity = nil
end

function InGame.leave()
  InGame.marketUI = nil
  InGame.mapRenderer = nil
  InGame.notifications = nil
end

function InGame.update(dt)
  InGame.world = InGame.world or EventBus.world
  if InGame.marketUI then InGame.marketUI:update(dt) end
  if InGame.mapRenderer and InGame.world then
    InGame.mapRenderer:update(dt, InGame.world)
  end
  if InGame.notifications then
    for i = #InGame.notifications, 1, -1 do
      InGame.notifications[i].ttl = InGame.notifications[i].ttl - dt
      if InGame.notifications[i].ttl <= 0 then
        table.remove(InGame.notifications, i)
      end
    end
  end
  InGame:updateCurrentCity(InGame.world)
end

function InGame:notify(text, color)
  table.insert(InGame.notifications, { text = text, color = color or { 0.9, 0.9, 0.6 }, ttl = 4 })
  log:info(text)
end

function InGame.draw()
  local w, h = love.graphics.getDimensions()
  local world = InGame.world
  if not world then return end
  InGame.mapRenderer:draw(w, h, world)
  InGame:drawTopBar(w, h, world)
  InGame:drawBottomBar(w, h, world)
  if InGame.marketUI and InGame.marketUI.visible then
    InGame.marketUI:draw(w, h)
  end
  InGame:drawNotifications(w, h)
end

function InGame:drawTopBar(w, h, world)
  Components.drawPanel(0, 0, w, 30, nil)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(world.time:getDateString(), 10, 7)
  if InGame.currentCity then
    love.graphics.setColor(0.6, 0.8, 1)
    love.graphics.print("Standort: " .. InGame.currentCity.name, 200, 7)
  end
  love.graphics.setColor(0.8, 0.7, 0.2)
  if world.players[1] then
    love.graphics.printf("Gold: " .. Utils.formatNumber(world.players[1].gold), 0, 7, w - 10, "right")
  end
end

function InGame:drawBottomBar(w, h, world)
  Components.drawPanel(0, h - 35, w, 35, nil)
  local speedLabel = world.time:getSpeedLabel()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Geschwindigkeit: " .. speedLabel, 10, h - 27)
  love.graphics.print("[<] [>] Leertaste=Pause", 200, h - 27)
  if world.travel.traveling and InGame.currentCity then
    love.graphics.setColor(1, 0.8, 0.2)
    local progress = math.floor(world.travel.progress * 100)
    love.graphics.printf("Reise nach " .. world.travel.to.name .. " (" .. progress .. "%)", 0, h - 27, w - 10, "right")
  elseif InGame.currentCity then
    love.graphics.setColor(0.5, 0.8, 0.5)
    love.graphics.printf("In " .. InGame.currentCity.name, 0, h - 27, w - 10, "right")
  end
end

function InGame:drawNotifications(w, h)
  if not InGame.notifications then return end
  local ny = h * 0.15
  for _, n in ipairs(InGame.notifications) do
    local alpha = math.min(1, n.ttl)
    love.graphics.setColor(n.color[1], n.color[2], n.color[3], alpha)
    love.graphics.printf(n.text, w * 0.3, ny, w * 0.4, "center")
    ny = ny + 22
  end
end

function InGame:updateCurrentCity(world)
  if not world then return end
  if world.travel.traveling then
    InGame.currentCity = nil
    return
  end
  local player = world.players[1]
  if not player then return end
  if player.currentCityId then
    local city = world.cities:getById(player.currentCityId)
    if city then
      InGame.currentCity = city
      return
    end
  end
  local cities = world.cities:getAll()
  if #cities > 0 then
    player.currentCityId = cities[1].id
    InGame.currentCity = cities[1]
  end
end

function InGame.keypressed(key)
  if key == "escape" then
    if InGame.marketUI and InGame.marketUI.visible then
      InGame.marketUI:close()
    else
      EventBus:emit("state:change", "mainmenu")
    end
  elseif key == "left" then
    if InGame.world then InGame.world.time:prevSpeed() end
  elseif key == "right" then
    if InGame.world then InGame.world.time:nextSpeed() end
  elseif key == "space" then
    if InGame.world then InGame.world.time:togglePause() end
  end
end

function InGame.mousepressed(x, y, button)
  local w, h = love.graphics.getDimensions()
  local world = InGame.world
  if not world then return end
  if InGame.marketUI and InGame.marketUI.visible then
    local px, py, pw = w * 0.2, h * 0.1, w * 0.6
    local ph = h * 0.8
    if Components.isInRect(x, y, px, py, pw, ph) then
      if InGame.marketUI:mousepressed(x, y, w, h) then return end
    else
      InGame.marketUI:close()
    end
  end
  if y > h - 35 and y < h then
    if x > 200 and x < 230 then world.time:prevSpeed() end
    if x > 240 and x < 270 then world.time:nextSpeed() end
    return
  end
  if InGame.mapRenderer then
    InGame.mapRenderer:startDrag(x, y)
    InGame._clickStartX = x
    InGame._clickStartY = y
  end
end

function InGame.mousemoved(x, y, dx, dy)
  if not InGame.mapRenderer then return end
  if InGame.mapRenderer.dragging then
    local dxMove = math.abs(x - InGame._clickStartX)
    local dyMove = math.abs(y - InGame._clickStartY)
    if dxMove > 5 or dyMove > 5 then
      InGame.mapRenderer:updateDrag(x, y)
    end
    return
  end
  local w, h = love.graphics.getDimensions()
  local world = InGame.world
  InGame.mapRenderer.hoveredCity = world and InGame.mapRenderer:getCityAt(x, y, w, h, world)
  if InGame.marketUI then InGame.marketUI:mousemoved(x, y) end
end

function InGame.mousereleased(x, y, button)
  if not InGame.mapRenderer then return end
  local wasDragging = InGame.mapRenderer.dragging
  InGame.mapRenderer:stopDrag()
  if not wasDragging then return end
  local dxDist = math.abs(x - (InGame._clickStartX or x))
  local dyDist = math.abs(y - (InGame._clickStartY or y))
  if dxDist <= 5 and dyDist <= 5 then
    local w, h = love.graphics.getDimensions()
    local world = InGame.world
    local city = InGame.mapRenderer:getCityAt(x, y, w, h, world)
    if city then
      if InGame.currentCity and city.id ~= InGame.currentCity.id and not world.travel.traveling then
        EventBus:emit("travel:start", { from = InGame.currentCity, to = city })
        InGame:notify("Reise gestartet: " .. InGame.currentCity.name .. " -> " .. city.name, { 0.5, 0.8, 1 })
      elseif InGame.currentCity and city.id == InGame.currentCity.id then
        InGame.marketUI:open(city, world.players[1])
      else
        InGame.marketUI:open(city, world.players[1])
      end
    end
  end
end

return InGame