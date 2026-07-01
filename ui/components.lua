local Components = {}

Components.themes = {
  retro = {
    panelBg = {0.08, 0.07, 0.04, 0.95},
    panelBorder = {0.65, 0.55, 0.35, 0.95},
    panelTitle = {0.96, 0.88, 0.65, 1},
    buttonBg = {0.24, 0.18, 0.12, 0.95},
    buttonHover = {0.44, 0.34, 0.22, 0.95},
    buttonBorder = {0.82, 0.72, 0.45, 1},
    text = {0.95, 0.92, 0.82, 1},
    textSecondary = {0.7, 0.62, 0.45, 1},
    accent = {0.78, 0.62, 0.28, 1},
    background = {0.06, 0.05, 0.03, 1},
  },
  clean = {
    panelBg = {0.08, 0.1, 0.14, 0.95},
    panelBorder = {0.5, 0.6, 0.72, 0.95},
    panelTitle = {0.85, 0.92, 0.98, 1},
    buttonBg = {0.18, 0.23, 0.3, 0.95},
    buttonHover = {0.28, 0.4, 0.55, 0.95},
    buttonBorder = {0.6, 0.75, 0.92, 1},
    text = {0.94, 0.95, 0.98, 1},
    textSecondary = {0.7, 0.78, 0.88, 1},
    accent = {0.55, 0.75, 0.9, 1},
    background = {0.03, 0.06, 0.1, 1},
  },
}

Components.currentTheme = Components.themes.retro

function Components.setTheme(name)
  if Components.themes[name] then
    Components.currentTheme = Components.themes[name]
    return true
  end
  return false
end

function Components.getTheme()
  return Components.currentTheme
end

function Components.drawPanel(x, y, w, h, title)
  local theme = Components.currentTheme
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
  local theme = Components.currentTheme
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
  love.graphics.setColor(color or Components.currentTheme.text)
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
