local TopBar = require("ui.ingame.topbar")
local SidePanel = require("ui.ingame.sidepanel")
local BottomBar = require("ui.ingame.bottombar")
local Notifications = require("ui.ingame.notifications")

local Draw = {}

function Draw.render(ingame)
  local w, h = love.graphics.getDimensions()
  local world = ingame.world
  if not world then
    return
  end

  ingame.mapRenderer:draw(w, h, world)
  TopBar.draw(ingame, w, h, world)
  SidePanel.draw(ingame, w, h, world)
  BottomBar.draw(ingame, w, h, world)

  if ingame.marketUI and ingame.marketUI.visible then
    ingame.marketUI:draw(w, h)
  end

  Notifications.draw(ingame.notifications, w, h)
end

return Draw
