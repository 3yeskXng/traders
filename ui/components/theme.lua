local Theme = require("ui.theme")
local currentTheme = Theme.current

local ComponentTheme = {}

function ComponentTheme.setTheme(name)
  local ok = Theme.set(name)
  if ok then
    currentTheme = Theme.get()
  end
  return ok
end

function ComponentTheme.getTheme()
  return Theme.get()
end

ComponentTheme.currentTheme = currentTheme

return ComponentTheme
