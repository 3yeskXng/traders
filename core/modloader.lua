local Logger = require("core.logger")
local EventBus = require("core.eventbus")
local log = Logger.new("modloader")

local ModLoader = {}

function ModLoader:loadAll(pluginManager)
  local mods = {}
  local items = love.filesystem.getDirectoryItems("mods")
  for _, name in ipairs(items) do
    local info = love.filesystem.getInfo("mods/" .. name)
    if info and info.type == "directory" and love.filesystem.getInfo("mods/" .. name .. "/init.lua") then
      local ok, mod = pcall(require, "mods." .. name)
      if ok and mod then
        table.insert(mods, mod)
        log:info("Loaded mod: %s", name)
        if mod.onLoad then mod:onLoad(pluginManager) end
        if EventBus and EventBus.emit then EventBus:emit("mod:loaded", { name = name, mod = mod }) end
      else
        log:warn("Failed to load mod: %s", name)
      end
    end
  end
  return mods
end

return ModLoader
