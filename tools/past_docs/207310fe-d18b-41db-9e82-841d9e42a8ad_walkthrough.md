# Level 29, 30, 31, 32, 33 & 34 Features Walkthrough

We have successfully implemented:
1. Level 29 (Penguen) - 3-color winter background.
2. Level 30 (Aslan) - 3-color sunset background, outside-in weapon sorting, 4-weapon slots, and randomized 10/15 capacities.
3. Level 31 (Ejderha) - 48x48 dragon pixel art, outside-in weapon sorting, 3-weapon slots, and randomized 20-30 capacities.
4. Level 32 (Timsah) - 48x48 high-quality crocodile pixel art, 3-weapon slots, and hidden queue previews.
5. Level 33 (Porsuk) - 48x48 badger pixel art on a transparent background, 3-weapon slots, and hidden queue previews.
6. Level 34 (Yengec) - 48x48 crab pixel art on a transparent background, 3-weapon slots, and hidden queue previews.

---

## Level 32 (Timsah / Crocodile) Implementation Details

### 1. 48x48 Grid and Database Compilation
- Created [convert_crocodile.dart](file:///d:/FlutterProjects/pixel_painter/tools/convert_crocodile.dart) to decode the crocodile image.
- Implemented a BFS flood-fill algorithm starting from the corners to identify and clear the solid black background to transparent/empty cells (`.`) while retaining the crocodile's outline details (Color 12).
- Mapped the crocodile colors to the game's palette:
  - **Skin Tone (Cam Yesili)**: Color 44 (`r`) & Color 45 (`s`)
  - **Underbelly / Highlights**: Color 43 (`q`) & Color 42 (`p`)
  - **Spikes / Scales (Govde Rengi)**: Color 46 (`t`)
  - **Mouth Inside (Kirmizi)**: Color 1 (`A`)
  - **Eyes (Sari)**: Color 4 (`D`)
  - **Teeth / Highlights (White)**: Color 11 (`K`)
- Renamed level index 31 from `"Mum"` to `"Timsah"` and added the new 48x48 template in [build_levels.dart](file:///d:/FlutterProjects/pixel_painter/tools/build_levels.dart).

### 2. 3-Column Slot Bar and Hidden Preview Queue
- Since Level 32 is index 31, it automatically defaults to a 3-column slot bar.
- It automatically triggers the `hideSecondRow: true` configuration, making the second-row waiting cartridges invisible to the player (empty placeholders).
- **Reduced Initial Black Outlines**:
  - Decreased the density of black outline (Color 12) cartridges at the beginning of the level by spreading them over a wider range (`progress = progress * 0.65`).
  - Partitioned the 300 deficit of Color 12 into larger capacities of 20 and 30 (instead of standard 10s), reducing the total black cartridge count to around 12 to prevent clogging the start of the queue.

---

## Level 33 (Porsuk / Badger) Implementation Details

### 1. 48x48 Grid and Bounding Box Auto-Cropping
- Created [convert_badger.dart](file:///d:/FlutterProjects/pixel_painter/tools/convert_badger.dart) to process the badger image.
- Implemented an **auto-cropping bounding box detector** to locate the badger's foreground bounds (detected bounding box: `x=118, y=156, w=822, h=701`), removing the large solid cream-colored margins and scaling the badger to fill the 48x48 grid area perfectly ("büyük bir şekilde yap").
- Cleared the solid cream background to transparent/empty cells (`.`) using a corner BFS flood-fill.
- Mapped badger colors to the game's palette:
  - **Cream**: Color 42 (`p`)
  - **Slate Grey**: Color 15 (`O`)
  - **Dark Brown**: Color 46 (`t`)
  - **Black**: Color 12 (`L`)
  - **White**: Color 11 (`K`)
  - **Lion Orange (Tail/Detail)**: Color 40 (`n`)
- Renamed level index 32 from `"Hediye"` to `"Porsuk"` and added the 48x48 badger template to [build_levels.dart](file:///d:/FlutterProjects/pixel_painter/tools/build_levels.dart).

### 2. 3-Column Slot Bar and Hidden Preview Queue
- Level 33 (index 32) uses the standard 3-column slot bar layout.
- The cartridge preview bar has the second row hidden (`hideSecondRow: true` since index >= 31).
- **Randomized Mixed Capacities**:
  - Instead of defaulting mostly to `20`s, we partitioned all color deficits into a randomized, mathematical mix of `10`, `15`, `20`, `30`, and `40` capacities.
- **Smart Color & Capacity Interleaving**:
  - Grouped and shuffled cartridges by color to randomize the internal order of capacities.
  - Rebuilt the queue using a weighted penalty selection:
    - Strong penalty (`-100.0`) for consecutive same colors.
    - Medium penalty (`-50.0`) for identical color two slots away. This guarantees that all 3 active starting slots on screen display distinct colors!
    - Penalty (`-30.0`) for same color in the same column (three slots away) to prevent vertical matching clumping in the active slots.
    - Penalty (`-5.0`) for consecutive identical capacities to diversify the values (e.g. `10 - 15 - 20`, `20 - 30 - 10`).
    - Bypassed the simple default column swap logic for this level as our weighted interleaving natively solves horizontal and vertical matching.

---

## Level 34 (Yengec / Crab) Implementation Details

### 1. 48x48 Grid and Square-Cropped Bounding Box
- Processed the user's crab image (`media__1782480741840.jpg`).
- Detected the precise foreground bounding box: `minX=212, maxX=815, minY=273, maxY=779` (604x507 pixels).
- To prevent stretching/squashing when scaled, we centered the crop vertically to a perfect square of `604x604` (`cropX=212, cropY=225, w=604, h=604`).
- Scaled to 48x48 grid size ("hücreler küçük olsun") and mapped pixels to the game's palette:
  - **Red Shell**: Color 1 (`A`)
  - **Outline**: Color 12 (`L`)
  - **Underbelly / Highlights**: Color 30 (`d`)
  - **Sand/Cream (Island)**: Color 42 (`p`)
  - **White Highlights**: Color 11 (`K`)
  - **Teal waves**: Color 23 (`W`)
- Implemented a tight-threshold corner BFS flood-fill to mark the flat beige background color as transparent/empty (`.`) without leaking into the sand dune or the crab body ("arka plan rengini alma").
- Renamed level index 33 from `"Ari"` to `"Yengec"` and added the template to [build_levels.dart](file:///d:/FlutterProjects/pixel_painter/tools/build_levels.dart).

### 2. 3-Column Slot Bar and Hidden Preview Queue
- Level 34 (index 33) uses the standard 3-column slot bar layout.
- The cartridge preview bar has the second row hidden (`hideSecondRow: true` since index >= 31).
- Automatically inherits the generic randomized capacity partitioning and smart interleaving layout.

---

## Verification Results

### 1. Database Compilation
The command `dart build_levels.dart` successfully builds the entire level suite, producing the updated badger, crocodile, and bee levels:
```
Scaling level 32, name: Timsah
Scaling level 33, name: Porsuk
Scaling level 34, name: Yengec
Level data generated successfully!
```

### 2. Automated Tests
Ran the playability simulator and cartridge queue tests:
- `flutter test test/inspect_queue_test.dart`
  - **Result:** `All tests passed!` (Verified starting capacity diversity, color interleaving, and distinct start colors for both Level 33 and Level 34).
- `flutter test test/motor_path_engine_test.dart`
  - Result: All tests passed! (Verified 100% playability and clearability of the new 48x48 Yengec shape).

### 3. App Launch
- Re-compiled and launched the app on your device (`SM X710`) to apply all changes instantly!

---

## Level 34 (Yengec) Queue Starting Background Capacities (User Request #10)

- **40-Round Starting Background Cartridges**:
  - Implemented strict filtering during Level 34's queue prefix selection: any background color (Color 25, 20, or 16) cartridge selected to interleave within the first 9 starting slots is specifically swapped with a `40-round` cartridge from the queue.
  - This guarantees that background color cartridges at the beginning of the level have a capacity of 40.
- **Flakiness and Interleaving Resolution**:
  - Added a post-processing pass starting at the prefix boundary (index 8) to swap any consecutive same-color cartridges. This ensures that the entire queue remains perfectly interleaved and resolves the flakiness that previously failed unit tests.
- **Automated Verification**:
  - Re-run `flutter test test/inspect_queue_test.dart` and verified that the starting capacities are exactly `40` for background colors, `15` for cream, and `5` for pinks, and that there are no consecutive duplicates. All tests passed successfully!

---

## Level 35 (Yunus / Dolphin) Implementation Details

### 1. 48x48 Grid and Image Processing
- Mapped the user's dolphin image (`media__1782482401913.jpg`) to a high-quality 48x48 pixel art representation.
- **Sunset Sky and Sea Background**: Kept the sunset sky colors (Lavender `J`, Pale Sun Cream `e`, Peach Pink `d`) and sea colors (Sky Blue `Y`, Mavi `B`, Teal Medium `V`, Indigo `P`).
- **White Border Clean Up**: Programmatically stripped out the vertical white borders (Color 11, `K`) on the far-left and far-right columns (columns 0 and 47) by copying the color of their horizontal neighbor cells. This removed the vertical white stripe rendering issue.
- **Clean Outline Merging**: Merged minor outline pixels (Color 12, `L`, which had only 5 cells and was noise) into the dolphin's body color (Slate Grey `O`), keeping the shape clean and eliminating any count-5 colors.
- Renamed level index 34 from `"Semsiye"` to `"Yunus"` and added the template to [build_levels.dart](file:///d:/FlutterProjects/pixel_painter/tools/build_levels.dart).

---

## Complete Removal of 5-Round Cartridges (Level 34 & 35)

To address the constraint that only cartridge capacities of `{10, 15, 20, 30, 40}` are allowed and that no 5-round cartridges should ever be generated, we made two critical changes:

### 1. Pixel Count Balancing
- **Level 34 (Crab)**: Balanced the white highlight color `'K'` to have exactly 10 pixels (instead of 5) and reduced the body color `'A'` to 360 (from 365) to keep the total pixel sum at 2300.
- **Level 35 (Dolphin)**: Merged the 5 pixels of `'L'` into `'O'`, ensuring the minimum target count for any non-zero color is 20.
- As a result, no color in Level 34 or Level 35 has a total target count of 5.

### 2. Remainder Partitioning Logic in `game_screen.dart`
- Modified the cartridge batch amounts planner (`_balancedBatchAmountsForDeficit`):
  - When background colors are partitioned (which have very large counts and must use 40-round cartridges as much as possible), the remainder `rem = target % 40` could sometimes be 5 (e.g. `685 % 40 = 5` for yellow sky background in Crab).
  - Implemented a smart remainder check to prevent forbidden capacities:
    - **Remainder 5**: Partitions the last 45 cells into `[30, 15]`.
    - **Remainder 25**: Partitions into `[15, 10]`.
    - **Remainder 35**: Partitions into `[20, 15]`.
  - For foreground colors, the fallback batch planner rounds target values up to the nearest multiple of 5, and partitions them using a mathematical check that only selects from the allowed set `{10, 15, 20, 30, 40}` without ever leaving a remainder of 5.

---

## Verification Results

### 1. Database Compilation
The command `dart build_levels.dart` successfully builds the entire level suite, producing the updated Crab and Dolphin levels:
```
Scaling level 34, name: Yengec
Scaling level 35, name: Yunus
Level data generated successfully!
```

### 2. Automated Tests
Ran the playability simulator and cartridge queue tests:
- `flutter test test/inspect_queue_test.dart`
  - **Result:** `All tests passed!` (Verified that Level 34 has no 5-round cartridges and uses only allowed capacities `{10, 15, 20, 30, 40}`).
- `flutter test test/motor_path_engine_test.dart`
  - **Result:** `All tests passed!` (Verified 100% playability and clearability of the new balanced Crab and Dolphin shapes).

---

## Cartridge Queue Full Preview Dialog (Level 34)

We added a feature allowing players to inspect all cartridges in the Level 34 queue:

### 1. Preview Trigger Button
- Rendered a premium beveled button `TÜM KARTUŞLARI GÖSTER` (Show All Cartridges) directly underneath the active cartridge slot bar specifically for Level 34.
- Styled using the game's standard luxury beveled gold/wood button aesthetics.

### 2. Luxury Dialog Card Pop-up
- Clicking the button opens a scrollable popup dialog containing a grid representation of all cartridges.
- Mapped each cartridge to a compact visual container styled with its matching paint color, a gold bezel border, its sequence index (`1.`, `2.`, `3.` ...), and its exact capacity value centered in bold text.
- Includes a primary close button at the bottom using the game's theme colors.


