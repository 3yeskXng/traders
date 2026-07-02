# Travel Module

## Purpose
Travel mechanics between cities including distance calculations and travel state management.

## Public API
- `simulation.travel.travel` - TravelSystem class (new, start, update, getPosition, serialize)
- `simulation.travel.distance` - Distance calculations

## Dependencies
- core.logger, core.eventbus

## Used by
- simulation.world.bootstrap, ui.events.travel
