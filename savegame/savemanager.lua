local Logger = require("core.logger")
local Serializer = require("savegame.serializer")
local log = Logger.new("savemanager")

local SaveManager = {}
SaveManager.__index = SaveManager

local MAX_SLOTS = 5

function SaveManager.new()
  return setmetatable({}, SaveManager)
end

function SaveManager:save(world, slot)
  local data = {
    version = 1,
    timestamp = os.time(),
    world = world:serialize(),
    players = world.players,
  }
  return Serializer.saveToFile("save_" .. slot .. ".json", data)
end

function SaveManager:load(world, slot)
  local data = Serializer.loadFromFile("save_" .. slot .. ".json")
  if not data then return false end
  if data.world and data.world.time then world.time:deserialize(data.world.time) end
  if data.world and data.world.travel then world.travel:deserialize(data.world.travel, world.cities) end
  if data.players then world.players = data.players end
  log:info("Loaded save from slot %d", slot)
  return true
end

function SaveManager:listSaves()
  local saves = {}
  for i = 1, MAX_SLOTS do
    local data = Serializer.loadFromFile("save_" .. i .. ".json")
    if data then
      table.insert(saves, { slot = i, timestamp = data.timestamp, version = data.version })
    end
  end
  return saves
end

return SaveManager
