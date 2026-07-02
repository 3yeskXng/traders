# Traders Architecture

## Layer Architecture

Dependencies flow strictly downward. No layer may depend on a layer above it.

```
UI          ui/, rendering/
  |
Gameplay    (empty - future layer for game mechanics coordination)
  |
Simulation  simulation/
  |
Core        core/, savegame/
```

### Layer Rules

- **Core** - Foundation layer. No game-specific knowledge. No simulation or UI dependencies.
- **Simulation** - Pure game logic. No LÖVE API usage. No rendering or UI dependencies.
- **Gameplay** - (future) Coordinates simulation and core. No rendering or UI dependencies.
- **UI** - User interface and rendering. May depend on all lower layers.
- **Rendering** - Graphical output. May depend on simulation (read-only), core, but never on UI.

## Directory Structure

```
traders/
├── main.lua                 # Entry point
├── conf.lua                 # LÖVE configuration
├── ARCHITECTURE.md          # This file
├── README.md                # Project overview
├── folder.md                # Root directory overview
│
├── core/                    # Foundation layer
│   ├── folder.md
│   ├── eventbus.lua         # Pub/sub event system
│   ├── statemachine.lua     # Screen state machine
│   ├── config.lua           # Configuration manager
│   ├── translator.lua       # i18n translation
│   ├── json.lua             # JSON facade
│   ├── json/
│   │   ├── encoder.lua      # JSON encoding
│   │   └── decoder.lua      # JSON decoding
│   ├── fonts.lua            # Font facade
│   ├── fonts/
│   │   └── loader.lua       # Font loading with CJK support
│   ├── logger.lua           # Logger facade
│   ├── logging/
│   │   ├── logger.lua       # Logger implementation
│   │   └── init.lua         # Logging module facade
│   ├── utils.lua            # Utility functions
│   ├── modloader.lua        # Mod loading
│   └── pluginmanager.lua    # Plugin management
│
├── simulation/              # Game logic (no LÖVE)
│   ├── folder.md
│   ├── world.lua            # World orchestrator
│   ├── world/
│   │   ├── bootstrap.lua    # World initialization
│   │   ├── serialize.lua    # World serialization
│   │   └── update.lua       # World update cycle
│   ├── player.lua           # Player data
│   ├── time.lua             # Game time system
│   ├── map/                 # Map data
│   │   ├── init.lua
│   │   └── config.lua
│   ├── cities/              # Cities
│   │   ├── init.lua
│   │   ├── data.lua         # City data structure
│   │   ├── manager.lua      # City management
│   │   └── population.lua   # Population dynamics
│   ├── economy/             # Economy simulation
│   │   ├── init.lua
│   │   ├── prices.lua
│   │   ├── demand.lua
│   │   ├── supply.lua
│   │   ├── production.lua
│   │   ├── consumption.lua
│   │   └── inflation.lua
│   ├── goods/               # Trade goods
│   │   ├── init.lua
│   │   ├── data.lua         # Goods definitions
│   │   ├── manager.lua      # Goods management
│   │   └── categories.lua   # Goods categories
│   ├── ships/               # Ships
│   │   ├── init.lua
│   │   ├── data.lua         # Ship data structure
│   │   ├── manager.lua      # Ship management
│   │   ├── cargo.lua        # Cargo system
│   │   ├── movement.lua     # Ship movement
│   │   └── speed.lua        # Speed calculations
│   ├── trade/               # Trading
│   │   ├── init.lua
│   │   ├── trading.lua      # Buy/sell logic
│   │   ├── market.lua       # Market data
│   │   └── route.lua        # Trade routes
│   ├── travel/              # Travel
│   │   ├── init.lua
│   │   ├── travel.lua       # Travel system
│   │   └── distance.lua     # Distance calculations
│   ├── taxes/               # Taxation
│   │   ├── init.lua
│   │   ├── citytax.lua
│   │   ├── customs.lua
│   │   └── portfees.lua
│   └── ai/                  # AI Traders
│       ├── init.lua
│       ├── trader.lua
│       ├── strategy.lua
│       └── simpletrader.lua
│
├── rendering/               # Graphics output (LÖVE)
│   ├── folder.md
│   ├── init.lua
│   ├── camera.lua           # Camera system
│   ├── compass.lua          # Compass rose
│   ├── renderer.lua         # Simple fallback renderer
│   ├── map.lua              # Map renderer facade
│   └── map/
│       ├── folder.md
│       ├── state.lua        # MapRenderer state
│       ├── updater.lua      # Update logic
│       ├── renderer.lua     # Draw orchestrator
│       ├── interaction.lua  # Mouse handling
│       ├── backgrounds.lua  # Ocean/water rendering
│       ├── landmass.lua     # Land polygons
│       ├── features.lua     # Forests, rivers
│       ├── islands.lua      # Island rendering
│       ├── cities.lua       # City icons/labels
│       ├── ships.lua        # Ship visualization
│       ├── routes.lua       # Trade routes
│       ├── overlay.lua      # Overlay elements
│       └── tooltip.lua      # City tooltips
│
├── ui/                      # User interface
│   ├── folder.md
│   ├── init.lua
│   ├── theme.lua            # UI theme
│   ├── components.lua       # Component library facade
│   ├── components/
│   │   ├── folder.md
│   │   ├── init.lua         # Facade
│   │   ├── theme.lua        # Theme integration
│   │   ├── panel.lua        # Panel widget
│   │   ├── widgets.lua      # Button, label, slider, iconbar
│   │   └── helpers.lua      # isInRect, formatNumber
│   ├── mainmenu.lua         # Main menu screen
│   ├── mainmenu/
│   │   └── background.lua   # Menu background
│   ├── settings.lua         # Settings screen facade
│   ├── settings/
│   │   ├── folder.md
│   │   ├── state.lua        # Settings state
│   │   ├── draw.lua         # Settings rendering
│   │   └── input.lua        # Settings input
│   ├── newgame.lua          # New game screen facade
│   ├── newgame/
│   │   ├── folder.md
│   │   ├── state.lua        # New game state
│   │   ├── draw.lua         # New game rendering
│   │   └── input.lua        # New game input
│   ├── ingame.lua           # In-game screen facade
│   ├── ingame/
│   │   ├── folder.md
│   │   ├── state.lua        # In-game state
│   │   ├── draw.lua         # HUD rendering
│   │   ├── input.lua        # In-game input
│   │   ├── topbar.lua       # Top bar
│   │   ├── sidepanel.lua    # Side panel
│   │   ├── bottombar.lua    # Bottom bar
│   │   └── notifications.lua# Notifications
│   ├── market.lua           # Market UI facade
│   └── market/
│       ├── folder.md
│       ├── draw.lua         # Market rendering
│       └── logic.lua        # Market input logic
│
├── events/                  # Event handlers (moved from core to UI layer)
│   └── ... (see ui/events/)
│
├── savegame/
│   ├── folder.md
│   ├── init.lua
│   ├── manager.lua
│   └── serializer.lua
│
├── mods/
│   ├── folder.md
│   ├── init.lua
│   └── loader.lua
│
├── multiplayer/
│   ├── folder.md
│   ├── init.lua
│   └── sync.lua
│
├── data/                    # JSON data files
│   ├── folder.md
│   ├── cities.json
│   ├── goods.json
│   ├── ships.json
│   ├── map.json
│   └── lang/ (de.json, en.json, zh.json)
│
├── assets/                  # Resource files
│   └── folder.md
│
└── tests/
    ├── savegame_smoke.lua   # Serialization test
    └── ...
```

## Design Principles

1. **Single Responsibility** - Each module has exactly one purpose.
2. **Small Files** - No file exceeds 100 lines without strong justification.
3. **Facade Pattern** - Public APIs are exported via facade files (init.lua or module facades).
4. **Dependency Direction** - Dependencies flow strictly downward (UI → Simulation → Core).
5. **No Global State** - All state is encapsulated in module tables.
6. **Event-Driven** - Loose coupling via EventBus for cross-layer communication.
7. **Data-Driven** - Game content loaded from JSON files; no code changes needed for new content.
8. **Replaceable Backend** - Simulation layer has zero LÖVE dependencies, allowing backend replacement.

## Dependency Graph

```
main.lua
  ├── core.logger
  ├── core.eventbus
  ├── core.config
  ├── core.translator
  ├── core.fonts
  ├── core.statemachine
  ├── core.modloader
  ├── core.pluginmanager
  ├── ui.mainmenu
  ├── ui.settings
  ├── ui.newgame
  ├── ui.ingame
  ├── savegame.manager
  └── ui.events
        ├── ui.events.lifecycle   → simulation.world, core.*
        ├── ui.events.game        → simulation.world, simulation.player, ui.newgame, ui.ingame
        ├── ui.events.trade       → core.eventbus
        ├── ui.events.travel      → core.translator, ui.ingame
        └── ui.events.settings    → core.config, core.translator, core.fonts

simulation.world
  ├── simulation.world.bootstrap
  │     ├── simulation.goods.manager
  │     ├── simulation.cities.manager
  │     ├── simulation.ships.manager
  │     ├── simulation.time
  │     ├── simulation.trade.trading
  │     ├── simulation.travel.travel
  │     ├── simulation.economy.*
  │     ├── simulation.cities.population
  │     └── simulation.taxes.citytax
  ├── simulation.world.serialize
  └── simulation.world.update

ui.ingame
  ├── rendering.map
  │     ├── rendering.map.renderer → rendering.map.*
  │     ├── rendering.map.interaction
  │     └── rendering.map.state
  ├── ui.market
  ├── ui.ingame.*
  └── simulation.map.config
```

## Module Count

- Core: 15 files (including submodules)
- Simulation: 30 files (including submodules)
- Rendering: 15 files (including submodules)
- UI: 28 files (including submodules)
- Savegame: 3 files
- Mods: 3 files
- Multiplayer: 2 files
- **Total: ~96 Lua source files**

## Event Reference

| Event | Payload | Description |
|-------|---------|-------------|
| `state:change` | `stateName` | Navigate to a screen |
| `language:change` | `languageCode` | Switch UI language |
| `settings:apply` | — | Apply and save settings |
| `game:new` | — | Create a new game world |
| `game:start` | `{ city }` | Start game from city selection |
| `game:load` | — | Load saved game from slot |
| `game:save` | — | Save current game to slot |
| `trade:buy` | `{ city, goodId, amount }` | Buy goods at city |
| `trade:sell` | `{ city, goodId, amount }` | Sell goods at city |
| `travel:start` | `{ from, to }` | Start travel between cities |
| `travel:arrived` | `{ city }` | Ship arrived at destination |
| `day:passed` | `{ year, month, day }` | A new game day has started |
