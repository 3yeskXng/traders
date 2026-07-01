local Logger = require("core.logger")
local log = Logger.new("modloader")

local ModLoader = {}

function ModLoader:loadAll()
  local mods = {}
  local items = love.filesystem.getDirectoryItems("mods")
  for _, name in ipairs(items) do
    if love.filesystem.getInfo("mods/" .. name .. "/init.lua") then
      local ok, mod = pcall(require, "mods." .. name)
      if ok and mod then
        table.insert(mods, mod)
        log:info("Loaded mod: %s", name)
        if mod.onLoad then mod:onLoad() end
      else
        log:warn("Failed to load mod: %s", name)
      end
    end
  end
  return mods
end

return ModLoader
