local CompassRose = {}

function CompassRose.draw(cx, cy, size)
  love.graphics.push()
  love.graphics.translate(cx, cy)

  local outer = size
  local inner = size * 0.3

  for i = 0, 7 do
    local angle = math.rad(i * 45)
    local isCardinal = i % 2 == 0
    local isMain = i % 2 == 0

    love.graphics.push()
    love.graphics.rotate(angle)

    local tip = isMain and outer or outer * 0.7

    if isMain then
      love.graphics.setColor(0.5, 0.15, 0.15)
      love.graphics.polygon("fill", 0, -tip, -inner * 0.4, 0, 0, inner * 0.15, inner * 0.4, 0)
      love.graphics.setColor(0.7, 0.25, 0.25)
      love.graphics.polygon("line", 0, -tip, -inner * 0.4, 0, 0, inner * 0.15, inner * 0.4, 0)
    else
      love.graphics.setColor(0.55, 0.4, 0.25)
      love.graphics.polygon("fill", 0, -tip, -inner * 0.3, 0, 0, inner * 0.1, inner * 0.3, 0)
      love.graphics.setColor(0.7, 0.55, 0.35)
      love.graphics.polygon("line", 0, -tip, -inner * 0.3, 0, 0, inner * 0.1, inner * 0.3, 0)
    end

    love.graphics.pop()
  end

  love.graphics.setColor(0.3, 0.2, 0.1)
  love.graphics.circle("line", 0, 0, outer)
  love.graphics.setColor(0.4, 0.3, 0.15)
  love.graphics.circle("line", 0, 0, outer * 0.6)

  love.graphics.setColor(0.3, 0.2, 0.1)
  local labels = { "N", "NO", "O", "SO", "S", "SW", "W", "NW" }
  for i, label in ipairs(labels) do
    local angle = math.rad((i - 1) * 45)
    local lx = math.sin(angle) * (outer + 8)
    local ly = -math.cos(angle) * (outer + 8)
    love.graphics.setColor(0.3, 0.15, 0.08)
    love.graphics.printf(label, lx - 8, ly - 5, 16, "center")
  end

  love.graphics.pop()
end

return CompassRose