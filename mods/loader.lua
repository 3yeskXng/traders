local Logger = require("core.logger")
local log = Logger.new("modloader")

local ModLoader = {}

function ModLoader:loadAll()
  local mods = {}
  local items = love.filesystem.getDirectoryItems("mods")
  for _, name in ipairs(items) do
    local info = love.filesystem.getInfo("mods/" .. name)
    if info and info.type == "directory" then
      local initPath = "mods." .. name .. ".init"
      local ok, mod = pcall(require, initPath)
      if ok and mod then
        table.insert(mods, { name = name, mod = mod })
        if mod.onLoad then mod:onLoad() end
        log:info("Loaded mod: %s", name)
      end
    end
  end
  return mods
end

function ModLoader:unloadAll(mods)
  for _, entry in ipairs(mods) do
    if entry.mod.onUnload then entry.mod:onUnload() end
  end
end

return ModLoader
