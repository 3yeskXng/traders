local Theme = require("ui.theme")
local Components = {}

function Components.setTheme(name)
  local ok = Theme.set(name)
  if ok then Components.currentTheme = Theme.get() end
  return ok
end

function Components.getTheme()
  return Theme.get()
end

Components.currentTheme = Theme.current

function Components.drawPanel(x, y, w, h, title)
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

function Components.drawButton(text, x, y, w, h, hover)
  local theme = Theme.get()
  love.graphics.setColor(hover and theme.buttonHover or theme.buttonBg)
  love.graphics.rectangle("fill", x, y, w, h, 10, 10)
  love.graphics.setColor(theme.buttonBorder)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", x, y, w, h, 10, 10)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(theme.text)
  love.graphics.printf(text, x, y + h / 2 - 10, w, "center")
end

function Components.drawLabel(text, x, y, color)
  love.graphics.setColor(color or Theme.get().text)
  love.graphics.print(text, x, y)
end

function Components.drawValue(label, value, x, y, w)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.print(label, x, y)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(tostring(value), x, y, w, "right")
end

function Components.isInRect(px, py, x, y, w, h)
  return px >= x and px <= x + w and py >= y and py <= y + h
end

function Components.drawSlider(x, y, w, value, min, max)
  love.graphics.setColor(0.2, 0.2, 0.25)
  love.graphics.rectangle("fill", x, y, w, 8)
  local ratio = (value - min) / (max - min)
  local knobX = x + ratio * w
  love.graphics.setColor(0.6, 0.5, 0.3)
  love.graphics.rectangle("fill", knobX - 4, y - 3, 8, 14)
end

function Components.formatNumber(n)
  local s = tostring(math.floor(n))
  local parts = {}
  while #s > 3 do table.insert(parts, 1, s:sub(-3)) s = s:sub(1, -4) end
  table.insert(parts, 1, s)
  return table.concat(parts, ".")
end

function Components.drawIconBar(x, y, w, h, value, maxVal, fg, bg)
  love.graphics.setColor(bg or { 0.3, 0.3, 0.3 })
  love.graphics.rectangle("fill", x, y, w, h)
  if maxVal > 0 then
    local fill = math.min(1, value / maxVal)
    love.graphics.setColor(fg or { 0.2, 0.7, 0.2 })
    love.graphics.rectangle("fill", x + 1, y + 1, (w - 2) * fill, h - 2)
  end
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle("line", x, y, w, h)
end

return Components
