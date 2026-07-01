local Logger = require("core.logger")
local json = require("core.json")
local log = Logger.new("config")

local Config = {}

function Config:load(path)
  local data, err = love.filesystem.read(path)
  if not data then log:warn("Could not read config: %s (%s)", path, err or "?") return {} end
  local parsed = json.decode(data)
  if not parsed then log:warn("Could not parse config: %s", path) return {} end
  for k, v in pairs(parsed) do self[k] = v end
  log:info("Loaded config from %s", path)
  return parsed
end

function Config:save(path)
  local jsonLib = require("core.json")
  local data = {}
  for k, v in pairs(self) do
    if type(v) ~= "function" then data[k] = v end
  end
  local ok = love.filesystem.write(path, jsonLib.encode(data))
  if ok then log:info("Saved config to %s", path) end
  return ok
end

return Config
