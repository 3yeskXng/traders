local Encoder = {}

function Encoder.encode(val)
  local function enc(v)
    local t = type(v)
    if t == "nil" then
      return "null"
    elseif t == "boolean" then
      return tostring(v)
    elseif t == "number" then
      return tostring(v)
    elseif t == "string" then
      local esc = {
        ['"'] = '\\"', ["\\"] = "\\\\",
        ["\b"] = "\\b", ["\f"] = "\\f",
        ["\n"] = "\\n", ["\r"] = "\\r",
        ["\t"] = "\\t",
      }
      return '"' .. v:gsub('[%c\\"]', esc) .. '"'
    elseif t == "table" then
      local isArray = true
      for k in pairs(v) do
        if type(k) ~= "number" or k < 1 or k > #v then
          isArray = false
          break
        end
      end
      if isArray then
        local parts = {}
        for i = 1, #v do
          parts[i] = enc(v[i])
        end
        return "[" .. table.concat(parts, ",") .. "]"
      else
        local parts = {}
        for k, val in pairs(v) do
          table.insert(parts, enc(k) .. ":" .. enc(val))
        end
        return "{" .. table.concat(parts, ",") .. "}"
      end
    end
  end
  return enc(val)
end

return Encoder
