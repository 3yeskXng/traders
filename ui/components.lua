local Components = {}

function Components.drawPanel(x, y, w, h, title)
  love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor(0.4, 0.3, 0.2)
  love.graphics.rectangle("line", x, y, w, h)
  if title then
    love.graphics.setColor(0.8, 0.7, 0.4)
    love.graphics.printf(title, x + 5, y + 3, w - 10, "left")
    love.graphics.setColor(0.3, 0.25, 0.15)
    love.graphics.line(x + 2, y + 22, x + w - 2, y + 22)
  end
end

function Components.drawButton(text, x, y, w, h, hover)
  if hover then
    love.graphics.setColor(0.4, 0.35, 0.25)
  else
    love.graphics.setColor(0.25, 0.2, 0.15)
  end
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor(0.6, 0.5, 0.3)
  love.graphics.rectangle("line", x, y, w, h)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(text, x, y + h / 2 - 8, w, "center")
end

function Components.drawLabel(text, x, y, color)
  love.graphics.setColor(color or { 1, 1, 1 })
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
