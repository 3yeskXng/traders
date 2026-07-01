local json = require("core.json")
local Logger = require("core.logger")
local log = Logger.new("serializer")

local Serializer = {}

function Serializer.encode(data)
  return json.encode(data)
end

function Serializer.decode(data)
  if type(data) ~= "string" and data and data.getString then data = data:getString() end
  return json.decode(data)
end

function Serializer.saveToFile(filename, data)
  local str = Serializer.encode(data)
  local ok, err = love.filesystem.write(filename, str)
  if ok then log:info("Saved to %s", filename) else log:error("Failed to save %s: %s", filename, err) end
  return ok
end

function Serializer.loadFromFile(filename)
  local file = love.filesystem.newFile(filename, "r")
  if not file then return nil end
  local data = file:read()
  file:close()
  if not data then return nil end
  local ok, result = pcall(Serializer.decode, data)
  if ok then return result end
  log:warn("Failed to decode %s: %s", filename, tostring(result))
  return nil
end

return Serializer
