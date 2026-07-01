# Traders

A highly modular trading simulation game built with LÖVE (Love2D).

## Architecture

Simulation and rendering are strictly separated. All game rules work without a window or graphics.

```
core/          Engine, EventBus, Config, Logger, Utils, JSON
simulation/    Game world (no LÖVE dependency)
rendering/     Graphical output
ui/            User interface
savegame/      Save/Load system
multiplayer/   Placeholder (replaceable later)
mods/          Mod system
data/          JSON data (goods, cities, ships, taxes, ...)
assets/        Resources (images, sounds)
```

## Principles

- Prefer 50 small files over one large file
- Each system gets its own module
- New goods/cities/ships/buildings require no code changes
- EventBus for loose coupling
- No global variables
- Configuration from JSON files

## Running

Requires LÖVE 11.5.

```bash
love .
```

## Controls

- Left/Right arrow: change speed
- Space: pause
- Click city: open market
- Escape: close market / back to menu

## Milestones

- ✅ Phase 1: Framework (Engine, Events, Modules, Logging)
- ✅ Phase 2: World (Cities, Goods, Map)
- ✅ Phase 3: Trade (Buy, Sell, Prices, Storage)
- ✅ Phase 4: Ships (Data, Movement, Cargo)
- ✅ Phase 5: Economy (Production, Consumption, Demand, Supply)
- ✅ Phase 6: Taxes (City Tax, Port Fees, Customs)
- ⬜ Phase 7: NPC Traders (AI)

## License

GNU General Public License v3
