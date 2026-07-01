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
  local prev = self.current and self.states[self.current]
  if prev and prev.leave then prev.leave() end
  self.previous = self.current
  self.current = name
  local next = self.states[name]
  if next and next.enter then next.enter(...) end
  log:info("State changed to: %s", name)
end

function StateMachine:update(dt)
  local state = self.states[self.current]
  if state and state.update then state.update(dt) end
end

function StateMachine:draw()
  local state = self.states[self.current]
  if state and state.draw then state.draw() end
end

function StateMachine:keypressed(key, scancode, isrepeat)
  local state = self.states[self.current]
  if state and state.keypressed then return state.keypressed(key, scancode, isrepeat) end
end

function StateMachine:mousepressed(x, y, button)
  local state = self.states[self.current]
  if state and state.mousepressed then return state.mousepressed(x, y, button) end
end

function StateMachine:mousemoved(x, y, dx, dy)
  local state = self.states[self.current]
  if state and state.mousemoved then return state.mousemoved(x, y, dx, dy) end
end

return StateMachine
