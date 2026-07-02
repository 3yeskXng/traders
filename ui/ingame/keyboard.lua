local EventBus = require("core.eventbus")

local Keyboard = {}

function Keyboard.keypressed(ingame, key)
  if key == "escape" then
    if ingame.marketUI and ingame.marketUI.visible then
      ingame.marketUI:close()
    else
      EventBus:emit("state:change", "mainmenu")
    end
  elseif key == "left" then
    if ingame.world then
      ingame.world.time:prevSpeed()
    end
  elseif key == "right" then
    if ingame.world then
      ingame.world.time:nextSpeed()
    end
  elseif key == "space" then
    if ingame.world then
      ingame.world.time:togglePause()
    end
  end
end

return Keyboard
