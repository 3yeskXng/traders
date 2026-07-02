# Ships Module

## Purpose
Ship data structures, types, management, cargo, movement, and speed calculations.

## Public API
- `simulation.ships.data` - Ship class (new, loadCargo, unloadCargo, serialize)
- `simulation.ships.manager` - ShipManager class (loadTypes, createShip, getShipsByOwner)
- `simulation.ships.cargo` - Cargo management
- `simulation.ships.movement` - Ship movement
- `simulation.ships.speed` - Speed calculations

## Dependencies
- core.logger, simulation.travel.distance

## Used by
- simulation.world.bootstrap, ui.events.game
