local Logger = require("core.logger")
local City = require("simulation.cities.data")
local log = Logger.new("citymanager")

local CityManager = {}
CityManager.__index = CityManager

function CityManager.new()
  return setmetatable({ list = {}, byId = {} }, CityManager)
end

function CityManager:load(data)
  for _, entry in ipairs(data) do
    local city = City.new(entry)
    table.insert(self.list, city)
    self.byId[city.id] = city
  end
  log:info("Loaded %d cities", #self.list)
end

function CityManager:getAll()
  return self.list
end

function CityManager:getById(id)
  return self.byId[id]
end

function CityManager:serialize()
  local data = {}
  for _, city in ipairs(self.list) do
    table.insert(data, city:serialize())
  end
  return data
end

function CityManager:deserialize(data)
  for _, entry in ipairs(data) do
    local city = self.byId[entry.id]
    if city then city:deserialize(entry) end
  end
end

function CityManager:getPortCities()
  local ports = {}
  for _, city in ipairs(self.list) do
    if city.hasPort then table.insert(ports, city) end
  end
  return ports
end

return CityManager
