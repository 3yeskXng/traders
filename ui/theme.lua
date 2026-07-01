local Theme = {}

Theme.themes = {
  retro = {
    panelBg = {0.08, 0.07, 0.04, 0.95},
    panelBorder = {0.65, 0.55, 0.35, 0.95},
    panelTitle = {0.96, 0.88, 0.65, 1},
    buttonBg = {0.24, 0.18, 0.12, 0.95},
    buttonHover = {0.44, 0.34, 0.22, 0.95},
    buttonBorder = {0.82, 0.72, 0.45, 1},
    text = {0.95, 0.92, 0.82, 1},
    textSecondary = {0.7, 0.62, 0.45, 1},
    accent = {0.78, 0.62, 0.28, 1},
    background = {0.06, 0.05, 0.03, 1},
  },
  clean = {
    panelBg = {0.08, 0.1, 0.14, 0.95},
    panelBorder = {0.5, 0.6, 0.72, 0.95},
    panelTitle = {0.85, 0.92, 0.98, 1},
    buttonBg = {0.18, 0.23, 0.3, 0.95},
    buttonHover = {0.28, 0.4, 0.55, 0.95},
    buttonBorder = {0.6, 0.75, 0.92, 1},
    text = {0.94, 0.95, 0.98, 1},
    textSecondary = {0.7, 0.78, 0.88, 1},
    accent = {0.55, 0.75, 0.9, 1},
    background = {0.03, 0.06, 0.1, 1},
  },
}

Theme.current = Theme.themes.retro

function Theme.set(name)
  if Theme.themes[name] then
    Theme.current = Theme.themes[name]
    return true
  end
  return false
end

function Theme.get()
  return Theme.current
end

return Theme
