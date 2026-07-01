local json = require("core.json")
local Logger = require("core.logger")
local log = Logger.new("serializer")

local Serializer = {}

function Serializer.encode(data)
  return json.encode(data)
end

function Serializer.decode(str)
  return json.decode(str)
end

function Serializer.saveToFile(filename, data)
  local str = Serializer.encode(data)
  local ok, err = love.filesystem.write(filename, str)
  if ok then log:info("Saved to %s", filename) else log:error("Failed to save %s: %s", filename, err) end
  return ok
end

function Serializer.loadFromFile(filename)
  local data, err = love.filesystem.read(filename)
  if not data then return nil end
  local ok, result = pcall(Serializer.decode, data)
  if ok then return result end
  log:warn("Failed to decode %s", filename)
  return nil
end

return Serializer
