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
  MainMenu:drawBackground(w, h)
  love.graphics.setColor(Components.currentTheme.text)
  local fontSize = math.min(56, w / 16)
  love.graphics.setFont(love.graphics.newFont(fontSize))
  love.graphics.printf(Translator:t("game.title"), 0, h * 0.16, w, "center")
  love.graphics.setFont(love.graphics.newFont(18))
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
  love.graphics.setFont(love.graphics.newFont(14))
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

function MainMenu:drawBackground(w, h)
  local theme = Components.currentTheme
  love.graphics.setColor(theme.background)
  love.graphics.rectangle("fill", 0, 0, w, h)

  local offset = (MainMenu.elapsed or 0) * 20
  for i = 1, 12 do
    local y = (i * 48 + offset) % h
    love.graphics.setColor(theme.panelBorder[1], theme.panelBorder[2], theme.panelBorder[3], 0.07)
    love.graphics.line(0, y, w, y)
  end

  love.graphics.setColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.14)
  local mapRadius = math.min(w, h) * 0.45
  love.graphics.circle("line", w * 0.3, h * 0.5, mapRadius, 80)
  love.graphics.setColor(theme.textSecondary[1], theme.textSecondary[2], theme.textSecondary[3], 0.16)
  love.graphics.circle("line", w * 0.3, h * 0.5, mapRadius * 0.68, 80)
  love.graphics.circle("line", w * 0.3, h * 0.5, mapRadius * 0.36, 80)

  for i = 1, 8 do
    local angle = i * math.pi / 4 + offset * 0.01
    local x = w * 0.3 + math.cos(angle) * mapRadius * 0.9
    local y = h * 0.5 + math.sin(angle) * mapRadius * 0.9
    love.graphics.circle("fill", x, y, 3)
  end

  love.graphics.setColor(theme.accent)
  love.graphics.polygon("fill", w * 0.72, h * 0.22, w * 0.76, h * 0.26, w * 0.70, h * 0.28, w * 0.68, h * 0.24)
  love.graphics.polygon("fill", w * 0.75, h * 0.30, w * 0.80, h * 0.34, w * 0.73, h * 0.36, w * 0.70, h * 0.32)
  love.graphics.polygon("fill", w * 0.70, h * 0.40, w * 0.74, h * 0.44, w * 0.69, h * 0.46, w * 0.66, h * 0.42)

  love.graphics.setColor(theme.textSecondary[1], theme.textSecondary[2], theme.textSecondary[3], 0.22)
  for i = 1, 4 do
    local y = h * 0.15 + i * 38 + math.sin(offset * 0.03 + i) * 4
    love.graphics.line(w * 0.1, y, w * 0.5, y + 12)
  end

  love.graphics.setColor(theme.textSecondary)
  love.graphics.setFont(love.graphics.newFont(34))
  love.graphics.printf(Translator:t("menu.map_label"), w * 0.05, h * 0.18, w * 0.4, "left")
end

return MainMenu
