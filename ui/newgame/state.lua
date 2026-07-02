local MapRenderer = require("rendering.map")

local State = {}

function State.enter(newgame)
  newgame.mapRenderer = MapRenderer.new()
  newgame.selectedCity = nil
  newgame.world = newgame.world or nil
  newgame.player = newgame.player or nil
  newgame.buttonHover = nil
  newgame.dragging = false
  newgame._clickStartX = nil
  newgame._clickStartY = nil
end

function State.leave(newgame)
  newgame.mapRenderer = nil
  newgame.selectedCity = nil
  newgame.buttonHover = nil
  newgame.dragging = false
end

function State.update(newgame, dt)
  if newgame.mapRenderer and newgame.world then
    newgame.mapRenderer:update(dt, newgame.world)
  end
end

return State
