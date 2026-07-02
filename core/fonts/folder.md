# Fonts Module

## Purpose
Font management with CJK (Chinese/Japanese/Korean) fallback loading.

## Public API
- `core.fonts.getFont(size)` - Get a font at specified size
- `core.fonts.setGlobalFont(langCode, size)` - Load and set global font for language

## Dependencies
- None

## Used by
- ui.mainmenu, ui.components, rendering.map.overlay
