local EventBus = require("core.eventbus")
local Components = require("ui.components")
local Translator = require("core.translator")

local MainMenu = {}

function MainMenu.enter()
  MainMenu.selected = 1
  MainMenu.buttons = {
    { text = Translator:t("menu.new_game"), event = "game:new" },
    { text = Translator:t("menu.load_game"), event = "game:load" },
    { text = Translator:t("menu.settings"), event = "state:change", data = "settings" },
    { text = Translator:t("menu.quit"), event = "quit" },
  }
end

function MainMenu.leave() end

function MainMenu.update(dt) end

function MainMenu.draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0.1, 0.12, 0.2)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0.7, 0.6, 0.3)
  local fontSize = math.min(48, w / 20)
  love.graphics.setFont(love.graphics.newFont(fontSize))
  love.graphics.printf(Translator:t("game.title"), 0, h * 0.2, w, "center")
  love.graphics.setFont(love.graphics.newFont(18))
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.printf(Translator:t("game.subtitle"), 0, h * 0.2 + fontSize + 10, w, "center")
  local bw, bh = 250, 40
  local bx, by = (w - bw) / 2, h * 0.45
  for i, btn in ipairs(MainMenu.buttons) do
    Components.drawButton(btn.text, bx, by + (i - 1) * (bh + 10), bw, bh, MainMenu.selected == i)
  end
end

function MainMenu.keypressed(key)
  if key == "up" then MainMenu.selected = math.max(1, MainMenu.selected - 1)
  elseif key == "down" then MainMenu.selected = math.min(#MainMenu.buttons, MainMenu.selected + 1)
  elseif key == "return" or key == "space" then MainMenu:activate() end
end

function MainMenu.mousepressed(x, y, button)
  local w, h = love.graphics.getDimensions()
  local bw, bh = 250, 40
  local bx, by = (w - bw) / 2, h * 0.45
  for i, btn in ipairs(MainMenu.buttons) do
    if Components.isInRect(x, y, bx, by + (i - 1) * (bh + 10), bw, bh) then
      MainMenu.selected = i
      MainMenu:activate()
    end
  end
end

function MainMenu.mousemoved(x, y)
  local w, h = love.graphics.getDimensions()
  local bw, bh = 250, 40
  local bx, by = (w - bw) / 2, h * 0.45
  for i, btn in ipairs(MainMenu.buttons) do
    if Components.isInRect(x, y, bx, by + (i - 1) * (bh + 10), bw, bh) then
      MainMenu.selected = i
    end
  end
end

function MainMenu:activate()
  local btn = MainMenu.buttons[MainMenu.selected]
  if btn.event == "quit" then love.event.quit()
  elseif btn.event == "state:change" then EventBus:emit(btn.event, btn.data)
  else EventBus:emit(btn.event) end
end

return MainMenu
