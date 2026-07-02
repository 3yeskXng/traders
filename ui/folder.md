# UI Module

## Purpose
User interface screens, components, and event wiring.

## Responsibilities
- Screen state management (main menu, settings, new game, in-game)
- Shared UI components (panels, buttons, sliders, labels)
- Theme system
- Event handler registration for UI events
- Market UI window
- HUD elements (top bar, side panel, bottom bar, notifications)
- Language selection and settings

## Public API
- `ui.mainmenu` - Main menu screen
- `ui.settings` - Settings screen
- `ui.newgame` - New game city selection screen
- `ui.ingame` - In-game HUD screen
- `ui.market` - Market trading window
- `ui.components` - Shared UI component library
- `ui.events` - Event handler registration

## Dependencies
- simulation (world, player, map.config)
- rendering (map renderer)
- core (eventbus, config, translator, fonts, json, logger)
