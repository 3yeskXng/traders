local json = {}

local function getString(data)
  if type(data) == "string" then return data end
  if type(data) == "userdata" and data.getString then return data:getString() end
  return tostring(data)
end

function json.decode(str)
  str = getString(str)
  local idx, len = 1, #str
  local function skip()
    while idx <= len do
      local c = str:sub(idx, idx)
      if c == " " or c == "\t" or c == "\n" or c == "\r" then idx = idx + 1 else break end
    end
  end
  local function parse()
    skip()
    if idx > len then error("Unexpected end of JSON") end
    local c = str:sub(idx, idx)
    if c == "{" then
      idx = idx + 1; local obj = {}; skip()
      if str:sub(idx, idx) == "}" then idx = idx + 1 return obj end
      while true do
        skip(); local key = parse()
        if type(key) ~= "string" then error("Expected string key") end
        skip()
        if str:sub(idx, idx) ~= ":" then error("Expected colon") end
        idx = idx + 1; obj[key] = parse(); skip()
        local n = str:sub(idx, idx)
        if n == "," then idx = idx + 1 elseif n == "}" then idx = idx + 1 break else error("Expected , or }") end
      end
      return obj
    elseif c == "[" then
      idx = idx + 1; local arr = {}; skip()
      if str:sub(idx, idx) == "]" then idx = idx + 1 return arr end
      while true do
        table.insert(arr, parse()); skip()
        local n = str:sub(idx, idx)
        if n == "," then idx = idx + 1 elseif n == "]" then idx = idx + 1 break else error("Expected , or ]") end
      end
      return arr
    elseif c == '"' then
      idx = idx + 1; local s = {}
      while idx <= len do
        local cc = str:sub(idx, idx)
        if cc == '"' then idx = idx + 1 break end
        if cc == "\\" then
          idx = idx + 1; local esc = str:sub(idx, idx)
          local m = { ['"'] = '"', ["\\"] = "\\", ["/"] = "/", b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" }
          if m[esc] then table.insert(s, m[esc])
          elseif esc == "u" then
            local hex = str:sub(idx + 1, idx + 4); idx = idx + 4
            table.insert(s, string.char(tonumber(hex, 16)))
          else table.insert(s, esc) end
          idx = idx + 1
        else table.insert(s, cc) idx = idx + 1 end
      end
      return table.concat(s)
    elseif c == "t" and str:sub(idx, idx + 3) == "true" then idx = idx + 4 return true
    elseif c == "f" and str:sub(idx, idx + 4) == "false" then idx = idx + 5 return false
    elseif c == "n" and str:sub(idx, idx + 3) == "null" then idx = idx + 4 return nil
    else
      local ns = str:match("-?[0-9]+%.?[0-9]*", idx)
      if ns then
        local matchLen = #ns
        if str:sub(idx, idx + matchLen - 1) == ns then
          idx = idx + matchLen
          local exp = str:match("[eE][+-]?[0-9]+", idx)
          if exp and str:sub(idx, idx + #exp - 1) == exp then
            ns = ns .. exp; idx = idx + #exp
          end
          local n = tonumber(ns); if n then return n end
        end
      end
      error("Unexpected char: " .. c .. " at pos " .. idx .. " (first 20: " .. str:sub(1, math.min(20, #str)) .. ")")
    end
  end
  return parse()
end

function json.encode(val)
  local function enc(v)
    local t = type(v)
    if t == "nil" then return "null"
    elseif t == "boolean" then return tostring(v)
    elseif t == "number" then return tostring(v)
    elseif t == "string" then
      local esc = { ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
      return '"' .. v:gsub('[%c\\"]', esc) .. '"'
    elseif t == "table" then
      local isArray = true
      for k in pairs(v) do if type(k) ~= "number" or k < 1 or k > #v then isArray = false break end end
      if isArray then
        local parts = {}
        for i = 1, #v do parts[i] = enc(v[i]) end
        return "[" .. table.concat(parts, ",") .. "]"
      else
        local parts = {}
        for k, val in pairs(v) do table.insert(parts, enc(k) .. ":" .. enc(val)) end
        return "{" .. table.concat(parts, ",") .. "}"
      end
    end
  end
  return enc(val)
end

return json
