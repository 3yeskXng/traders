# Simulation Module

## Purpose
Pure game logic with zero LÖVE dependencies. Contains all gameplay rules and data structures.

## Responsibilities
- World creation and lifecycle
- City data and population dynamics
- Economy simulation (prices, demand, supply, production, consumption)
- Goods definitions and management
- Ship data, movement, cargo
- Trading system (buy, sell, markets, routes)
- Travel between cities
- Tax collection (city tax, port fees, customs)
- AI traders

## Public API
- `simulation.world` - World class (new, init, update, addPlayer, serialize)
- `simulation.player` - Player class (new, addStock, removeStock, serialize)
- `simulation.time` - TimeSystem class (update, getSpeed, togglePause)

## Dependencies
- core (logging, eventbus, utils)

## Used by
- ui.events, ui.ingame, rendering.map
