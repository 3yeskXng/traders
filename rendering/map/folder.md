# Map Rendering Module

## Purpose
Detailed map rendering with submodules for each visual layer.

## Responsibilities
- Background and water effects
- Landmass, coastline, and island rendering
- Forest and river rendering
- City icon and label rendering
- Ship visualization during travel
- Trade route rendering
- Compass rose and overlay decorations
- City tooltip rendering
- Map interaction (drag, click, city detection)

## Public API
See `rendering.map` facade.

## Dependencies
- simulation.map.config (read-only map data)
- core.fonts, core.translator
- ui.components

## Used by
- ui.ingame, ui.newgame
