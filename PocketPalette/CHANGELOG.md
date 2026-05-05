# Changelog

## [2.1.2] - 04/04/2026

### Main changes
- Added dye IDs 638 to 649 from the Mitterfruhl Easter 2026 event to PocketPalette: Golden Griffon, Deathclaw Brown, Jade Temple Green, Reikwald Green, Hagercrybs Teal, Celestial Blue, Imperial Fleet Blue, Bogenhafen Violet, Carroburg Crimson, Talabec Red, Kindleflame, and Imperial Gold.

## [2.11] - 02/15/2026

### Main changes
- Dye data now loads from 2 places:
  - `PocketPalette.csv` (shipped with addon)
  - `data\\gamedata\\tintpalette_equipment.csv` (live game file)
- New dyes added in game can now show up without updating the addon/CSV.
- All dyes not in the shipped CSV will miss full color/detail data until the shipped CSV is refreshed.
- If a dye exists in both sources, the live game file wins.
- If a dye has no usable name in CSV, the addon now tries `GetDyeNameString(id)`.
- If a dye has no hue/color values at all, the addon now uses a visible fallback color (`127,127,127,255`) instead of leaving it blank.
- Added a simple cross-platform helper script: `sync_shipped_csv.py`.
  - It can pull `tintpalette_equipment.csv` from a user's game install and rewrite `PocketPalette.csv`.
  - It can also write to a temp output path first, so users can compare and only rewrite when needed.
- Shipped `PocketPalette.csv` was updated with new dye rows from current game data.
- Added dye IDs `624` to `637`: Myrmidian Bronze, Estalian Steel, Glowkelp Green, Novareno Blue, Estalian Indigo, Miramar Violet, Irrana Purple, Bilbali Brandy Red, Estalian Red, Fury's Blood-Orange, Obregon Orange, Durango Orange, Estalian Yellow, Estalian Tan.

### Tooltip and UI
- Hovering a dye row now shows a tooltip with:
  - dye ID
  - data source
  - optional `Hue:` line when hue came from a different source
- Dye row tooltip hover handlers were added in `PocketPalette.xml`.
- Tooltip scale is reduced while hovering a dye row and restored on mouse-out.

### Stability improvements
- CSV row parsing is more tolerant of incomplete/odd `BuildTableFromCSV` rows.
- Specular dye detection is more accurate when specular RGB exists but specular intensity is missing.
