# Cities Module

## Purpose
City data structures, management, and population simulation.

## Public API
- `simulation.cities.data` - City class (new, getStock, addStock, removeStock, serialize)
- `simulation.cities.manager` - CityManager class (load, getAll, getById, getPortCities)
- `simulation.cities.population` - Population dynamics (update)

## Dependencies
- core.logger

## Used by
- simulation.world.bootstrap, simulation.economy, ui.ingame
