local State = require("ui.newgame.state")
local Draw = require("ui.newgame.draw")
local Input = require("ui.newgame.input")

local NewGame = {}

function NewGame.enter()
  State.enter(NewGame)
end

function NewGame.leave()
  State.leave(NewGame)
end

function NewGame.update(dt)
  State.update(NewGame, dt)
end

function NewGame.draw()
  Draw.render(NewGame)
end

function NewGame.keypressed(key)
  Input.keypressed(NewGame, key)
end

function NewGame.mousepressed(x, y, button)
  Input.mousepressed(NewGame, x, y, button)
end

function NewGame.mousemoved(x, y, dx, dy)
  Input.mousemoved(NewGame, x, y, dx, dy)
end

function NewGame.mousereleased(x, y, button)
  Input.mousereleased(NewGame, x, y, button)
end

return NewGame
