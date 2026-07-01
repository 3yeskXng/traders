local Logger = require("core.logger")
local json = require("core.json")
local log = Logger.new("translator")

local Translator = {}
Translator.__index = Translator

Translator.languages = {}
Translator.current = "de"
Translator.fallback = "en"

function Translator:loadLanguage(code, path)
  local file = love.filesystem.newFile(path, "r")
  if not file then log:warn("Could not open language file: %s", path) return false end
  local data = file:read()
  file:close()
  local ok, parsed = pcall(json.decode, data)
  if not ok or type(parsed) ~= "table" then log:warn("Could not parse language file: %s", path) return false end
  self.languages[code] = parsed
  log:info("Loaded language: %s", code)
  return true
end

function Translator:setLanguage(code)
  if self.languages[code] then
    self.current = code
    log:info("Language set to: %s", code)
    return true
  end
  log:warn("Language not loaded: %s", code)
  return false
end

function Translator:getLanguage()
  return self.current
end

function Translator:t(key, ...)
  local lang = self.languages[self.current] or {}
  local text = lang[key] or (self.languages[self.fallback] and self.languages[self.fallback][key])
  if not text then
    log:warn("Missing translation key: %s", key)
    return key
  end
  if select('#', ...) > 0 then
    return string.format(text, ...)
  end
  return text
end

return Translator