local Utils = {}

function Utils.clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.round(val, decimals)
    local factor = 10 ^ (decimals or 0)
    return math.floor(val * factor + 0.5) / factor
end

function Utils.map(value, inMin, inMax, outMin, outMax)
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

function Utils.deepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = Utils.deepCopy(v)
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
    local formatted = tostring(math.floor(n))
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")
        if k == 0 then break end
    end
    return formatted
end

function Utils.tableSize(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

return Utils
