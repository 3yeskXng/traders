local EventBus = require("core.eventbus")
local Components = require("ui.components")
local Translator = require("core.translator")
local Fonts = require("core.fonts")
local MenuBackground = require("ui.mainmenu.background")

local MainMenu = {}

function MainMenu.enter()
  MainMenu.selected = 1
  MainMenu.buttons = {
    { text = Translator:t("menu.new_game"), event = "game:new" },
    { text = Translator:t("menu.load_game"), event = "game:load" },
    { text = Translator:t("menu.settings"), event = "state:change", data = "settings" },
    { text = Translator:t("menu.quit"), event = "quit" },
  }
  MainMenu.selected = 1
  MainMenu.elapsed = 0
  MainMenu.version = "0.1.0"
  MainMenu.changelog = {
    Translator:t("menu.changelog.line1"),
    Translator:t("menu.changelog.line2"),
    Translator:t("menu.changelog.line3"),
  }
end

function MainMenu.leave() end

function MainMenu.update(dt)
  MainMenu.elapsed = (MainMenu.elapsed or 0) + dt
end

function MainMenu.draw()
  local w, h = love.graphics.getDimensions()
  MenuBackground.draw(MainMenu.elapsed, w, h)
  love.graphics.setColor(Components.currentTheme.text)
  local fontSize = math.min(56, w / 16)
  love.graphics.setFont(Fonts.getFont(fontSize))
  love.graphics.printf(Translator:t("game.title"), 0, h * 0.16, w, "center")
  love.graphics.setFont(Fonts.getFont(18))
  love.graphics.setColor(Components.currentTheme.textSecondary)
  love.graphics.printf(Translator:t("game.subtitle"), 0, h * 0.16 + fontSize + 10, w, "center")

  local bw, bh = 260, 46
  local bx, by = (w - bw) / 2, h * 0.45
  for i, btn in ipairs(MainMenu.buttons) do
    Components.drawButton(btn.text, bx, by + (i - 1) * (bh + 12), bw, bh, MainMenu.selected == i)
  end

  local changelogX = bx + bw + 30
  local changelogY = h * 0.42
  Components.drawPanel(changelogX, changelogY, w * 0.22, 170, Translator:t("menu.changelog_title"))
  love.graphics.setColor(Components.currentTheme.text)
  local lineY = changelogY + 45
  for _, line in ipairs(MainMenu.changelog) do
    love.graphics.printf("- " .. line, changelogX + 14, lineY, w * 0.2 - 28, "left")
    lineY = lineY + 24
  end

  love.graphics.setColor(Components.currentTheme.textSecondary)
  love.graphics.setFont(Fonts.getFont(14))
  love.graphics.printf(Translator:t("app.version", MainMenu.version), 20, h - 28, w, "left")
end

function MainMenu.keypressed(key)
  if key == "up" then MainMenu.selected = math.max(1, MainMenu.selected - 1)
  elseif key == "down" then MainMenu.selected = math.min(#MainMenu.buttons, MainMenu.selected + 1)
  elseif key == "return" or key == "space" then MainMenu:activate() end
end

function MainMenu.mousepressed(x, y, button)
  local w, h = love.graphics.getDimensions()
  local bw, bh = 260, 46
  local bx, by = (w - bw) / 2, h * 0.45
  for i, btn in ipairs(MainMenu.buttons) do
    if Components.isInRect(x, y, bx, by + (i - 1) * (bh + 12), bw, bh) then
      MainMenu.selected = i
      MainMenu:activate()
    end
  end
end

function MainMenu.mousemoved(x, y)
  local w, h = love.graphics.getDimensions()
  local bw, bh = 260, 46
  local bx, by = (w - bw) / 2, h * 0.45
  for i, btn in ipairs(MainMenu.buttons) do
    if Components.isInRect(x, y, bx, by + (i - 1) * (bh + 12), bw, bh) then
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
