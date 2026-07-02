# Logging Module

## Purpose
Provides structured logging with levels (DEBUG, INFO, WARN, ERROR).

## Public API
- `core.logger.new(name)` - Create a new logger instance
- `logger:info(message, ...)` - Log at INFO level
- `logger:warn(message, ...)` - Log at WARN level
- `logger:error(message, ...)` - Log at ERROR level
- `logger:debug(message, ...)` - Log at DEBUG level
- `Logger.setLevel(level)` - Set global minimum log level

## Dependencies
- None

## Used by
- All modules across all layers
