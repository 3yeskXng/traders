local Logger = require("core.logger")
local json = require("core.json")
local log = Logger.new("config")

local Config = {}

function Config:load(path)
  local file = love.filesystem.newFile(path, "r")
  if not file then log:warn("Could not open config: %s", path) return {} end
  local data = file:read()
  file:close()
  local ok, parsed = pcall(json.decode, data)
  if not ok or not parsed then log:warn("Could not parse config: %s (%s)", path, tostring(ok or parsed)) return {} end
  for k, v in pairs(parsed) do self[k] = v end
  log:info("Loaded config from %s", path)
  return parsed
end

function Config:save(path)
  local data = {}
  for k, v in pairs(self) do
    if type(v) ~= "function" then data[k] = v end
  end
  local ok = love.filesystem.write(path, require("core.json").encode(data))
  if ok then log:info("Saved config to %s", path) end
  return ok
end

return Config
