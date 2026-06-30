local Components = {}

function Components.drawOrnateButton(text, x, y, w, h, selected, hover)
    if selected then
        love.graphics.setColor(0.3, 0.25, 0.1)
        love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4, 6)
    end
    local r, g, b = 0.15, 0.12, 0.06
    if hover then r, g, b = 0.22, 0.18, 0.1 end
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", x, y, w, h, 4)
    love.graphics.setColor(0.45, 0.35, 0.15)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 4)
    love.graphics.setColor(0.55, 0.45, 0.2)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 3, y + 3, w - 6, h - 6, 3)
    if selected then
        love.graphics.setColor(1, 0.9, 0.5)
    elseif hover then
        love.graphics.setColor(0.95, 0.85, 0.55)
    else
        love.graphics.setColor(0.85, 0.8, 0.6)
    end
    local font = love.graphics.getFont()
    local tw = font:getWidth(text)
    local th = font:getHeight()
    love.graphics.print(text, x + (w - tw) / 2, y + (h - th) / 2)
end

function Components.drawCloseButton(x, y, size)
    love.graphics.setColor(0.4, 0.15, 0.1)
    love.graphics.rectangle("fill", x, y, size, size, 3)
    love.graphics.setColor(0.6, 0.25, 0.15)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, size, size, 3)
    love.graphics.setColor(1, 0.6, 0.5)
    local s = size / 2
    love.graphics.line(x + s - 3, y + s - 3, x + s + 3, y + s + 3)
    love.graphics.line(x + s + 3, y + s - 3, x + s - 3, y + s + 3)
end

function Components.drawPanel(x, y, w, h, title)
    love.graphics.setColor(0.06, 0.04, 0.02, 0.92)
    love.graphics.rectangle("fill", x, y, w, h, 6)
    love.graphics.setColor(0.35, 0.28, 0.12)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 6)
    love.graphics.setColor(0.2, 0.16, 0.06)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 4, y + 4, w - 8, h - 8, 4)
    if title then
        love.graphics.setColor(0.6, 0.5, 0.2)
        love.graphics.setFont(love.graphics.newFont(15))
        love.graphics.print(title, x + 12, y + 8)
        love.graphics.setColor(0.25, 0.2, 0.08)
        love.graphics.setLineWidth(0.5)
        love.graphics.line(x + 8, y + 30, x + w - 8, y + 30)
    end
    love.graphics.setLineWidth(1)
end

function Components.drawLabel(text, x, y, color)
    love.graphics.setColor(color or {1, 1, 1})
    love.graphics.print(text, x, y)
end

function Components.drawValue(label, value, x, y, width)
    love.graphics.setColor(0.7, 0.65, 0.5)
    love.graphics.print(label, x, y)
    love.graphics.setColor(1, 0.9, 0.5)
    local text = tostring(value)
    local tw = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, x + width - tw, y)
end

function Components.drawSlider(x, y, w, value, min, max)
    local ratio = (value - min) / (max - min)
    love.graphics.setColor(0.2, 0.15, 0.08)
    love.graphics.rectangle("fill", x, y, w, 10, 5)
    love.graphics.setColor(0.5, 0.4, 0.15)
    love.graphics.rectangle("fill", x, y, w * ratio, 10, 5)
    love.graphics.setColor(0.4, 0.3, 0.1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, 10, 5)
    local knobX = x + w * ratio
    love.graphics.setColor(0.7, 0.6, 0.3)
    love.graphics.circle("fill", knobX, y + 5, 7)
    love.graphics.setColor(0.9, 0.8, 0.5)
    love.graphics.circle("line", knobX, y + 5, 7)
end

function Components.isInRect(px, py, x, y, w, h)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

function Components.drawCompass(cx, cy, r)
    love.graphics.setColor(0.3, 0.25, 0.15, 0.25)
    love.graphics.circle("fill", cx, cy, r + 4)
    love.graphics.setColor(0.18, 0.16, 0.08, 0.4)
    love.graphics.circle("fill", cx, cy, r)
    love.graphics.setColor(0.4, 0.35, 0.2, 0.5)
    love.graphics.circle("line", cx, cy, r)
    for i = 0, 7 do
        local angle = i * math.pi / 4
        local len = (i % 2 == 0) and r or r * 0.6
        local x1 = cx + math.cos(angle) * 4
        local y1 = cy + math.sin(angle) * 4
        local x2 = cx + math.cos(angle) * len
        local y2 = cy + math.sin(angle) * len
        if i % 2 == 0 then
            love.graphics.setColor(0.7, 0.6, 0.3, 0.4)
            love.graphics.setLineWidth(2)
        else
            love.graphics.setColor(0.5, 0.45, 0.25, 0.3)
            love.graphics.setLineWidth(1)
        end
        love.graphics.line(x1, y1, x2, y2)
    end
    love.graphics.setColor(0.5, 0.4, 0.2, 0.4)
    love.graphics.circle("line", cx, cy, r * 0.2)
    love.graphics.setLineWidth(1)
end

function Components.drawWave(x, y, w, amp, phase, color)
    love.graphics.setColor(color or {0.1, 0.15, 0.25, 0.15})
    love.graphics.setLineWidth(1)
    local segments = math.floor(w / 4)
    for i = 0, segments - 1 do
        local p1x = x + (i / segments) * w
        local p2x = x + ((i + 1) / segments) * w
        local a1 = y + math.sin((i / segments) * 8 + phase) * amp
        local a2 = y + math.sin(((i + 1) / segments) * 8 + phase) * amp
        love.graphics.line(p1x, a1, p2x, a2)
    end
end

function Components.drawIconBar(x, y, w, h, value, maxVal, fg, bg)
    love.graphics.setColor(bg or {0.15, 0.1, 0.05})
    love.graphics.rectangle("fill", x, y, w, h, 2)
    local ratio = math.max(0, math.min(1, value / math.max(1, maxVal)))
    if ratio > 0 then
        love.graphics.setColor(fg or {0.5, 0.4, 0.15})
        love.graphics.rectangle("fill", x + 1, y + 1, (w - 2) * ratio, h - 2, 2)
    end
end

function Components.drawTooltip(text, x, y)
    local font = love.graphics.getFont()
    local tw = font:getWidth(text)
    local th = font:getHeight()
    local px, py = x + 10, y + 10
    if px + tw + 10 > love.graphics.getWidth() then px = x - tw - 20 end
    if py + th + 10 > love.graphics.getHeight() then py = y - th - 20 end
    love.graphics.setColor(0.06, 0.04, 0.02, 0.95)
    love.graphics.rectangle("fill", px, py, tw + 12, th + 8, 4)
    love.graphics.setColor(0.4, 0.32, 0.15)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", px, py, tw + 12, th + 8, 4)
    love.graphics.setColor(0.85, 0.8, 0.6)
    love.graphics.print(text, px + 6, py + 4)
end

return Components
