local Utils = {}

function Utils.clamp(val, min, max)
  return math.max(min, math.min(max, val))
end

function Utils.lerp(a, b, t)
  return a + (b - a) * t
end

function Utils.round(val, decimals)
  local mult = 10 ^ (decimals or 0)
  return math.floor(val * mult + 0.5) / mult
end

function Utils.map(value, inMin, inMax, outMin, outMax)
  return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

function Utils.deepCopy(tbl)
  if type(tbl) ~= "table" then return tbl end
  local copy = {}
  for k, v in pairs(tbl) do
    copy[Utils.deepCopy(k)] = Utils.deepCopy(v)
  end
  return copy
end

function Utils.merge(target, source)
  for k, v in pairs(source) do
    if type(v) == "table" and type(target[k]) == "table" then
      Utils.merge(target[k], v)
    else
      target[k] = v
    end
  end
  return target
end

function Utils.formatNumber(n)
  local s = tostring(math.floor(n))
  local parts = {}
  while #s > 3 do
    table.insert(parts, 1, s:sub(-3))
    s = s:sub(1, -4)
  end
  table.insert(parts, 1, s)
  return table.concat(parts, ".")
end

function Utils.tableSize(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

return Utils
