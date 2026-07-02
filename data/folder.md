# Data Module

## Purpose
Game data stored as JSON files for easy modification and modding.

## Contents
- `cities.json` - City definitions (positions, population, traits)
- `goods.json` - Trade goods (prices, categories, properties)
- `ships.json` - Ship types (capacity, speed, cost)
- `map.json` - Map data (land polygons, islands, rivers, decorations)
- `buildings.json` - Building definitions
- `ports.json` - Port definitions
- `events.json` - Game events
- `taxes.json` - Default tax rates
- `settings.json` - User configuration
- `lang/` - Translation files (de.json, en.json, zh.json)

## Usage
Loaded at runtime via `core.json.decode()`.
