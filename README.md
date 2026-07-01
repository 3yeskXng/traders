# Traders

Eine hochgradig modulare Handelssimulation, inspiriert von Patrizier II.

## Architektur

Simulation und Darstellung sind vollständig getrennt. Alle Spielregeln funktionieren auch ohne Fenster oder Grafik.

```
core/          Engine, EventBus, Config, Logger, Utils, Json
simulation/    Weltkern (keine LÖVE/Love2D-Abhängigkeit)
rendering/     Grafische Darstellung
ui/            Benutzeroberfläche
savegame/      Speichern/Laden
multiplayer/   Platzhalter (später ersetzbar)
mods/          Mod-System
data/          JSON-Daten (Waren, Städte, Schiffe, Steuern, ...)
assets/        Ressourcen (Bilder, Sounds)
```

## Grundsätze

- Lieber 50 kleine Dateien als eine riesige Datei
- Jedes System bekommt sein eigenes Modul
- Neue Waren/Städte/Schiffe/Gebäude benötigen keine Code-Änderung
- EventBus für lose Kopplung
- Keine globalen Variablen
- Konfiguration aus JSON-Dateien

## Starten

LÖVE 11.5 erforderlich.

```bash
love .
```

## Steuerung

- Pfeiltasten links/rechts: Geschwindigkeit ändern
- Leertaste: Pause
- Stadt anklicken: Markt öffnen
- Escape: Markt schließen / zurück zum Menü

## Meilensteine

- ✅ Phase 1: Grundgerüst (Engine, Events, Module, Logging)
- ✅ Phase 2: Welt (Städte, Waren, Karte)
- ✅ Phase 3: Handel (Kaufen, Verkaufen, Preise, Lager)
- ✅ Phase 4: Schiffe (Daten, Bewegung, Beladung)
- ✅ Phase 5: Wirtschaft (Produktion, Verbrauch, Nachfrage, Angebot)
- ✅ Phase 6: Steuern (Stadtsteuern, Hafengebühren, Zoll)
- ⬜ Phase 7: NPC-Händler (KI)

## Lizenz

GNU General Public License v3
