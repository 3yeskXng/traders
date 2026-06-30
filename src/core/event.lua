local Logger = require("src.core.logger")
local log = Logger:new("event")

local EventBus = {}
EventBus.__index = EventBus
EventBus.listeners = {}

function EventBus:on(event, callback, context)
    if not self.listeners[event] then
        self.listeners[event] = {}
    end
    table.insert(self.listeners[event], {callback = callback, context = context})
    log:debug("Listener registered: %s", event)
end

function EventBus:off(event, callback)
    if not self.listeners[event] then return end
    for i = #self.listeners[event], 1, -1 do
        if self.listeners[event][i].callback == callback then
            table.remove(self.listeners[event], i)
            log:debug("Listener removed: %s", event)
            return
        end
    end
end

function EventBus:emit(event, data)
    if not self.listeners[event] then return end
    for _, listener in ipairs(self.listeners[event]) do
        local ok, err
        if listener.context then
            ok, err = pcall(listener.callback, listener.context, data)
        else
            ok, err = pcall(listener.callback, data)
        end
        if not ok then
            log:error("Event '%s' handler error: %s", event, tostring(err))
        end
    end
end

function EventBus:clear(event)
    if event then
        self.listeners[event] = nil
    else
        self.listeners = {}
    end
end

return EventBus
