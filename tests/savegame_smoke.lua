local function stubLove()
  local loveStub = {
    filesystem = {
      newFile = function(path, mode)
        if mode == "r" then
          return {
            read = function() return _G.__savedata or nil end,
            close = function() end,
          }
        end
        return nil
      end,
      write = function(path, data)
        _G.__savedata = data
        return true
      end,
    },
  }
  package.loaded["love"] = loveStub
  _G.love = loveStub
end

stubLove()

local SaveManager = require("savegame.savemanager")

local world = {
  time = { deserialize = function(self, data) self._loaded = data end },
  travel = { deserialize = function(self, data, cities) self._loaded = { data = data, cities = cities } end },
  cities = { deserialize = function(self, data) self._loaded = data end },
  ships = { deserialize = function(self, data) self._loaded = data end },
  players = {},
}

local saveData = {
  world = {
    time = { tick = 3 },
    travel = { state = "moving" },
    cities = { { id = "a" } },
    ships = { { id = "ship-1" } },
  },
  players = { { id = "player-1" } },
}

_G.__savedata = require("core.json").encode(saveData)

local manager = SaveManager.new()
local ok = manager:load(world, 1)
assert(ok, "save load should succeed")
assert(world.time._loaded.tick == 3, "time state should be restored")
assert(world.cities._loaded[1].id == "a", "city state should be restored")
assert(world.ships._loaded[1].id == "ship-1", "ship state should be restored")
assert(world.players[1].id == "player-1", "player state should be restored")
print("savegame-smoke-ok")
