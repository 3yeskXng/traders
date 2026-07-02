# Trade Module

## Purpose
Trading system including market mechanics, buy/sell logic, and trade routes.

## Public API
- `simulation.trade.trading` - TradeSystem class (new, buy, sell)
- `simulation.trade.route` - Trade route definitions
- `simulation.trade.market` - Market data structures

## Dependencies
- core.logger, core.eventbus, simulation.economy.prices

## Used by
- simulation.world.bootstrap
