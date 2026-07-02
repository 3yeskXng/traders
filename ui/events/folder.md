# Event Handlers Module

## Purpose
Registration of all EventBus listeners that connect UI actions to simulation logic.

## Responsibilities
- Game lifecycle (new game, start game, save, load)
- Trade events (buy, sell)
- Travel events (start, arrived)
- Settings changes (language, fullscreen, volumes)
- State machine transitions

## Public API
- `ui.events.register(stateMachine, worldRef, saveManager)` - Register all event handlers

## Dependencies
- core (eventbus, config, translator, fonts, json, logger)
- simulation (world, player)
- ui (ingame, newgame)

## Used by
- main.lua
