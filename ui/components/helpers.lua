local Helpers = {}

function Helpers.isInRect(px, py, x, y, w, h)
  return px >= x and px <= x + w and py >= y and py <= y + h
end

function Helpers.formatNumber(n)
  local s = tostring(math.floor(n))
  local parts = {}
  while #s > 3 do
    table.insert(parts, 1, s:sub(-3))
    s = s:sub(1, -4)
  end
  table.insert(parts, 1, s)
  return table.concat(parts, ".")
end

return Helpers
