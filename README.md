# Traders

A highly modular trading simulation game built with LÖVE (Love2D) featuring 14th century Hanseatic trade.

## Architecture

Simulation and rendering are strictly separated. The dependency direction is:

```
UI → Rendering → Simulation → Core
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for full documentation.

## Quick Start

Requires LÖVE 11.5.

```bash
love .
```

## Controls

- **Left/Right arrow** - Change game speed
- **Space** - Pause/resume
- **Click city** - Open market
- **Drag map** - Pan view
- **Escape** - Close market / back to menu

## Project Structure

```
core/            Engine (eventbus, config, logging, json, fonts)
simulation/      Game world (no LÖVE dependency)
rendering/       Graphics output
ui/              User interface and events
savegame/        Save/Load system
multiplayer/     Placeholder
mods/            Mod system
data/            JSON data (cities, goods, ships, map, ...)
assets/          Resource files
```

## Design Principles

- Single Responsibility - each module has one purpose
- Small files - most files under 100 lines
- Facade pattern - public APIs through init.lua or module facades
- Event-driven - loose coupling via EventBus
- No globals - all state encapsulated in module tables
- Data-driven - JSON configuration, no code changes for new content
- Replaceable backend - simulation has zero LÖVE dependency

## License

GNU General Public License v3
