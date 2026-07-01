local EventBus = require("core.eventbus")
local Utils = require("core.utils")
local Components = require("ui.components")
local MapRenderer = require("rendering.map")
local MarketUI = require("ui.market")

local InGame = {}

function InGame.enter()
  InGame.mapRenderer = MapRenderer.new()
  InGame.marketUI = MarketUI.new()
end

function InGame.leave()
  InGame.marketUI = nil
  InGame.mapRenderer = nil
end

function InGame.update(dt)
  InGame.world = InGame.world or EventBus.world
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
end

function InGame:drawTopBar(w, h, world)
  Components.drawPanel(0, 0, w, 30, nil)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(world.time:getDateString(), 10, 7)
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
  love.graphics.print("[<] [>]", 200, h - 27)
  if world.travel.traveling then
    love.graphics.printf("Reist...", 0, h - 27, w - 10, "right")
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
    if InGame.marketUI:mousepressed(x, y, w, h) then return end
  end
  if y > h - 35 and y < h then
    if x > 200 and x < 230 then world.time:prevSpeed() end
    if x > 240 and x < 270 then world.time:nextSpeed() end
    return
  end
  local city = InGame.mapRenderer:getCityAt(x, y, w, h, world)
  if city then
    InGame.marketUI:open(city, world.players[1])
  end
end

function InGame.mousemoved(x, y)
  if not InGame.mapRenderer then return end
  local w, h = love.graphics.getDimensions()
  local world = InGame.world
  InGame.mapRenderer.hoveredCity = world and InGame.mapRenderer:getCityAt(x, y, w, h, world)
end

return InGame
