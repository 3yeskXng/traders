local Theme = require("ui.theme")

local Panel = {}

function Panel.draw(x, y, w, h, title)
  local theme = Theme.get()
  love.graphics.setColor(theme.panelBg)
  love.graphics.rectangle("fill", x, y, w, h, 12, 12)
  love.graphics.setColor(theme.panelBorder)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", x, y, w, h, 12, 12)
  love.graphics.setLineWidth(1)
  if title then
    love.graphics.setColor(theme.panelTitle)
    love.graphics.printf(title, x + 14, y + 10, w - 28, "left")
    love.graphics.setColor(theme.panelBorder)
    love.graphics.line(x + 12, y + 32, x + w - 12, y + 32)
  end
end

return Panel
