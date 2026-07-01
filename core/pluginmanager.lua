local Logger = require("core.logger")
local log = Logger.new("pluginmanager")

local PluginManager = {}
PluginManager.__index = PluginManager

function PluginManager.new()
  return setmetatable({ plugins = {}, active = {} }, PluginManager)
end

function PluginManager:register(name, plugin)
  if not name or type(plugin) ~= "table" then return false end
  self.plugins[name] = plugin
  log:info("Registered plugin: %s", name)
  return true
end

function PluginManager:activate(name, ...)
  local plugin = self.plugins[name]
  if not plugin then return false end
  if plugin.activate then plugin:activate(...) end
  self.active[name] = plugin
  log:info("Activated plugin: %s", name)
  return true
end

function PluginManager:deactivate(name, ...)
  local plugin = self.active[name]
  if not plugin then return false end
  if plugin.deactivate then plugin:deactivate(...) end
  self.active[name] = nil
  log:info("Deactivated plugin: %s", name)
  return true
end

function PluginManager:get(name)
  return self.plugins[name]
end

function PluginManager:getActive()
  return self.active
end

return PluginManager