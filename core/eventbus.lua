local Logger = require("core.logger")
local log = Logger.new("eventbus")

local EventBus = { _listeners = {} }

function EventBus:on(event, callback)
  self._listeners[event] = self._listeners[event] or {}
  table.insert(self._listeners[event], callback)
end

function EventBus:off(event, callback)
  local list = self._listeners[event]
  if not list then return end
  for i, cb in ipairs(list) do
    if cb == callback then table.remove(list, i) return end
  end
end

function EventBus:emit(event, data)
  local list = self._listeners[event]
  if not list then return end
  for _, callback in ipairs(list) do
    local ok, err = pcall(callback, data)
    if not ok then log:warn("Handler error on %s: %s", event, err) end
  end
end

function EventBus:clear(event)
  if event then self._listeners[event] = {} else self._listeners = {} end
end

return EventBus
