# Core Module

## Purpose
Foundation layer with no game-specific knowledge. Provides infrastructure used by all other layers.

## Responsibilities
- Event pub/sub system
- Configuration management
- JSON encoding/decoding
- Font loading (including CJK support)
- Logging framework
- State machine for screen transitions
- Translation/i18n system
- Utility functions
- Plugin and mod management

## Public API
- `core.eventbus` - EventBus singleton (on, off, emit, clear)
- `core.config` - Config singleton (load, save)
- `core.translator` - Translator singleton (loadLanguage, setLanguage, t)
- `core.logger` - Logger class (new, info, warn, error, debug)
- `core.json` - JSON encoder/decoder (encode, decode)
- `core.fonts` - Font loader (getFont, setGlobalFont)
- `core.statemachine` - StateMachine class (new, add, change)
- `core.utils` - Utility functions
- `core.modloader` - Mod loading (loadAll)
- `core.pluginmanager` - Plugin management

## Dependencies
- None (foundation layer)

## Used by
- All layers (simulation, rendering, ui, savegame)
