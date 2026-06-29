# Implementation Plan - Level 34 (Crab) and Level 35 (Dolphin) Balancing & No 5-round Cartridges

We will update Level 34 ("Yengec") and Level 35 ("Yunus") so that all color counts are multiples of 5 and at least 10, completely clean up the white border on the Dolphin level, recompile the level database, and modify the cartridge partitioning logic to guarantee that no 5-round cartridges are ever generated.

## Proposed Changes

### 1. Level Database & Templates

#### [MODIFY] [build_levels.dart](file:///d:/FlutterProjects/pixel_painter/tools/build_levels.dart)
- Run a custom balancer script to:
  - **Level 34 (Crab)**: Re-balance the 48x48 template so that `'K'` (white) has exactly 10 pixels (instead of 5), `'A'` is reduced to 360, and all other foreground and background color counts are multiples of 5.
  - **Level 35 (Dolphin)**:
    - Merge any `L` (outline, 5 cells) pixels into `O` (slate grey) so that color 12 has 0 cells.
    - Remove the left/right white border by replacing any `K` (white) on column 0 and column 47 with the neighboring cell's color (column 1/46).
    - Ensure all remaining colors are multiples of 5.
- Update the templates in `tools/build_levels.dart` with the perfectly balanced grids.
- Run the level database builder:
  ```powershell
  dart tools/build_levels.dart
  ```

---

### 2. Game Logic

#### [MODIFY] [game_screen.dart](file:///d:/FlutterProjects/pixel_painter/lib/screens/game_screen.dart)
- Update `_balancedBatchAmountsForDeficit`:
  - For Level 34 background colors (25, 20, 16), update the partitioning logic so it never generates a cartridge of size 5, 25, or 35. Instead, partition the remainder using only allowed capacities `{10, 15, 20, 30, 40}`:
    - Remainder 5: Replace the last 40-round cartridge and the 5-round remainder with `30` and `15` (total 45).
    - Remainder 25: Split into `15` and `10` (or `40` + `15` + `10` if target > 40).
    - Remainder 35: Split into `20` and `15` (or `40` + `20` + `15` if target > 40).
  - Apply the same safe partitioning logic to Level 35 background and foreground colors to ensure they are also 100% free of 5s.

---

### 3. Verification Plan

#### Automated Tests
- Run playability and category tests:
  ```powershell
  flutter test test/motor_path_engine_test.dart
  ```
- Run cartridge queue tests:
  ```powershell
  flutter test test/inspect_queue_test.dart
  ```

#### Manual Verification
- Run the app on the Samsung tablet.
- Launch Level 34:
  - Verify that the first 9 slots contain exactly 3 pink cartridges (size 10) and 1 cream cartridge (size 15).
  - Verify that no cartridge in the level queue has size 5.
- Launch Level 35:
  - Verify the Dolphin looks beautiful without any left/right white border lines.
  - Verify that no cartridge has size 5.
