# Rendering Module

## Purpose
All graphical output using LÖVE. No game logic - pure visualization.

## Responsibilities
- Camera system for map navigation
- Map rendering (backgrounds, landmass, cities, ships, routes)
- Fallback renderer
- Compass rose overlay
- Tooltip rendering

## Public API
- `rendering.map` - MapRenderer class (new, update, draw, getCityAt)
- `rendering.renderer` - Simple fallback renderer
- `rendering.camera` - Camera class (new, setTarget, update, apply)
- `rendering.compass` - Compass rose drawing

## Dependencies
- simulation.map.config (for map data only)
- core (fonts, logging)

## Used by
- ui.ingame, ui.newgame
