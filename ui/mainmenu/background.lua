local Components = require("ui.components")
local Translator = require("core.translator")

local MenuBackground = {}

function MenuBackground.draw(elapsed, w, h)
  local theme = Components.currentTheme
  love.graphics.setColor(theme.background)
  love.graphics.rectangle("fill", 0, 0, w, h)

  local offset = (elapsed or 0) * 20
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
  love.graphics.setFont(require("core.fonts").getFont(34))
  love.graphics.printf(Translator:t("menu.map_label"), w * 0.05, h * 0.18, w * 0.4, "left")
end

return MenuBackground
