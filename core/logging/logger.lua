local LEVELS = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4 }
local currentLevel = LEVELS.INFO
local _unpack = table.unpack or unpack

local Logger = {}
Logger.__index = Logger

function Logger.new(name)
  return setmetatable({ name = name }, Logger)
end

function Logger:log(level, message, ...)
  if LEVELS[level] < currentLevel then
    return
  end
  local info = debug.getinfo(2, "Sl")
  local loc = info and ("[" .. info.short_src .. ":" .. info.currentline .. "]") or ""
  local args = { ... }
  if #args > 0 then
    message = string.format(message, _unpack(args))
  end
  print(string.format("[%s] %s %s: %s", level, loc, self.name, message))
end

for _, level in ipairs({ "DEBUG", "INFO", "WARN", "ERROR" }) do
  Logger[level:lower()] = function(self, msg, ...)
    self:log(level, msg, ...)
  end
end

function Logger.setLevel(level)
  currentLevel = LEVELS[level] or currentLevel
end

return Logger
