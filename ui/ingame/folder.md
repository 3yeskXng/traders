# In-Game HUD Module

## Purpose
In-game screen management including map, HUD elements, and input handling.

## Responsibilities
- Map renderer creation and lifecycle
- Market UI window management
- Notification system
- Top bar (date, gold, time controls)
- Side panel (city info, cargo)
- Bottom bar (speed controls)
- Input handling (keyboard, mouse)
- Current city tracking

## Public API
See `ui.ingame` facade.

## Dependencies
- rendering.map
- simulation.map.config
- ui.components, ui.market
- core (eventbus, translator, logger, json)
