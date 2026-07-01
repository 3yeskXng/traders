local Logger = require("core.logger")
local log = Logger.new("statemachine")

local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new()
  return setmetatable({ states = {}, current = nil, previous = nil }, StateMachine)
end

function StateMachine:add(name, handlers)
  self.states[name] = handlers
end

function StateMachine:change(name, ...)
  if self.current and self.states[self.current] and self.states[self.current].leave then
    self.states[self.current]:leave()
  end
  self.previous = self.current
  self.current = name
  if self.states[name] and self.states[name].enter then
    self.states[name]:enter(...)
  end
  log:info("State changed to: %s", name)
end

function StateMachine:update(dt)
  if self.current and self.states[self.current] and self.states[self.current].update then
    self.states[self.current]:update(dt)
  end
end

function StateMachine:draw()
  if self.current and self.states[self.current] and self.states[self.current].draw then
    self.states[self.current]:draw()
  end
end

function StateMachine:keypressed(key, scancode, isrepeat)
  if self.current and self.states[self.current] and self.states[self.current].keypressed then
    return self.states[self.current]:keypressed(key, scancode, isrepeat)
  end
end

function StateMachine:mousepressed(x, y, button)
  if self.current and self.states[self.current] and self.states[self.current].mousepressed then
    return self.states[self.current]:mousepressed(x, y, button)
  end
end

function StateMachine:mousemoved(x, y, dx, dy)
  if self.current and self.states[self.current] and self.states[self.current].mousemoved then
    return self.states[self.current]:mousemoved(x, y, dx, dy)
  end
end

return StateMachine
