# Implementation Plan - Level 49 (Tavuk) & Level 50 (Basketbol) Upgrades

We will replace the current Level 49 (Zarf) and Level 50 (Bayrak) with high-fidelity custom pixel art scenes on a 60x60 grid (3600 pixels each). All color counts are mathematically verified to be multiples of 5, conforming to the game's constraints.

## User Review Required

- **Grid Size Choice**: We chose a **60x60** grid for both levels to capture the cute chickens, feed grains, yellow raincoat, and the basketball hoop, backboard, net, and the two players with high fidelity.
- **Custom Palettes**:
  - **Level 49 (Tavuk)**: 11 custom colors (IDs 263 to 273)
  - **Level 50 (Basketbol)**: 12 custom colors (IDs 274 to 285)
- **Non-colliding Characters**:
  - **Level 49**: mapped to Cyrillic characters (`Љ`, `Њ`, `Ћ`, `Ќ`, `Ў`, `Џ`, `А`, `В`, `Г`, `Д`, `Е`)
  - **Level 50**: mapped to Cyrillic characters (`З`, `Й`, `К`, `М`, `Н`, `О`, `Р`, `С`, `Т`, `У`, `Х`, `Ч`)

---

## Proposed Changes

### Configuration
#### [MODIFY] [header.txt](file:///d:/FlutterProjects/pixel_painter/tools/header.txt)
- Register 23 new colors (`263` to `285`) in `colorValues` map:
  - `263`: `#EFEEF6` (Tavuk Beyazi)
  - `264`: `#511F23` (Tavuk Siyahi)
  - `265`: `#FBC02D` (Tavuk Sarisi)
  - `266`: `#8F443E` (Tavuk Kahvesi)
  - `267`: `#FEB173` (Tavuk Turuncusu)
  - `268`: `#CF7364` (Tavuk Kizili)
  - `269`: `#756B85` (Tavuk Grisi)
  - `270`: `#D88A59` (Tavuk Topragi)
  - `271`: `#D32F2F` (Tavuk Kirmizisi)
  - `272`: `#FFB300` (Tavuk Gagasi)
  - `273`: `#CB817E` (Tavuk Pembesi)
  - `274`: `#ECF6FB` (Basket Beyazi)
  - `275`: `#7F2FC1` (Basket Moru)
  - `276`: `#5AD24C` (Basket Yesili)
  - `277`: `#0C9367` (Basket Koyu Yesili)
  - `278`: `#FBA27F` (Basket Ten)
  - `279`: `#52B9BD` (Basket Mavi Yesil)
  - `280`: `#AB682A` (Basket Kahvesi)
  - `281`: `#D84B20` (Basket Turuncusu)
  - `282`: `#A8C6E0` (Basket Acik Mavi)
  - `283`: `#D2D5E6` (Basket Grisi)
  - `284`: `#000000` (Basket Siyahi)
  - `285`: `#90E6EC` (Basket Turkuazi)
- Add 23 new `PaintCartridge` entries to the `cartridges` list.
- Register all 23 character keys in the global `_charToColor` mapping.

### Generator Update
#### [MODIFY] [build_levels.dart](file:///d:/FlutterProjects/pixel_painter/tools/build_levels.dart)
- Register all 23 character keys in the local `charToColor` map.
- Update template validation so index 48 (Level 49) and index 49 (Level 50) are expected to be 60x60.
- Configure difficulty settings:
  - Level 49: `gridSize = 60`, rename level to `"Tavuk"`
  - Level 50: `gridSize = 60`, rename level to `"Basketbol"`
- Exclude Levels 49 and 50 from automated `adjustColorCounts`.
- Replace the Zarf and Bayrak templates `objectTemplates[48]` and `objectTemplates[49]` with the new 60x60 layouts.

### Regeneration
#### [MODIFY] [level_data.dart](file:///d:/FlutterProjects/pixel_painter/lib/models/level_data.dart)
- Recompile using `dart tools/build_levels.dart` to rebuild level definition data.

---

## Verification Plan

### Automated Verification
- Run `dart build_levels.dart` to ensure it parses successfully.
- Verify color runs in the generated `_level49()` and `_level50()` in `level_data.dart` to ensure they are all multiples of 5 and sum to 3600.
- Verify code compiles cleanly with `dart analyze lib`.

### Manual Verification
- Deploy and launch the application on the user's tablet device (`SM X710`) via hot restart.
- Open Levels 49 and 50 in the level menu and inspect the new scenes.
