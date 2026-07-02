local Logger = require("core.logger")
local json = require("core.json")

local Helpers = {}

function Helpers.readJSON(path)
  local log = Logger.new("json")
  local file = love.filesystem.newFile(path, "r")
  if not file then
    log:warn("Could not open %s", path)
    return nil
  end
  local data = file:read()
  file:close()
  local ok, result = pcall(json.decode, data)
  if ok then
    return result
  end
  log:warn("Failed to parse %s: %s", path, tostring(result))
  return nil
end

return Helpers
