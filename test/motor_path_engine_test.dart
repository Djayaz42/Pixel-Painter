import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_painter/engine/motor_path_engine.dart';
import 'package:pixel_painter/models/active_motor.dart';
import 'package:pixel_painter/models/level_data.dart';
import 'package:pixel_painter/models/paint_cartridge.dart';
import 'package:pixel_painter/models/pixel_cell.dart';

void main() {
  test(
    'motor scans edge lines in counter-clockwise order without skipping',
    () {
      final motorRoute = [
        for (var i = 0; i < (LevelData.rows + LevelData.cols) * 2; i++)
          MotorPathEngine.activeMotorAt(
            cartridge: LevelData.cartridges.first,
            progress: (i + 0.5) / ((LevelData.rows + LevelData.cols) * 2),
          ),
      ];

      expect(motorRoute.map((motor) => motor.side), [
        for (var i = 0; i < LevelData.cols; i++) MotorSide.bottom,
        for (var i = 0; i < LevelData.rows; i++) MotorSide.right,
        for (var i = 0; i < LevelData.cols; i++) MotorSide.top,
        for (var i = 0; i < LevelData.rows; i++) MotorSide.left,
      ]);
      expect(motorRoute.map((motor) => motor.lineIndex), [
        for (var i = 0; i < LevelData.cols; i++) i,
        for (var i = LevelData.rows - 1; i >= 0; i--) i,
        for (var i = LevelData.cols - 1; i >= 0; i--) i,
        for (var i = 0; i < LevelData.rows; i++) i,
      ]);
    },
  );

  test('a painted cell becomes empty for the next side in the same run', () {
    final cells = [
      const PixelCell(row: 9, col: 0, targetColorId: 1, isPainted: true),
      const PixelCell(row: 9, col: 1, targetColorId: 1),
    ];
    const cartridge = PaintCartridge(
      id: 1,
      colorId: 1,
      name: 'Kirmizi',
      color: Color(0xFFFF4D67),
      amount: 1,
    );
    final motor = MotorPathEngine.activeMotorAt(
      cartridge: cartridge,
      progress: (3 + 9.5 / LevelData.rows) / 4,
    );

    final target = MotorPathEngine.findShotTarget(motor: motor, cells: cells);
    expect(target?.key, '9:1');
  });

  test('a different-colored cell blocks shots behind it', () {
    final cells = [
      const PixelCell(row: 9, col: 0, targetColorId: 2),
      const PixelCell(row: 9, col: 1, targetColorId: 1),
    ];
    const cartridge = PaintCartridge(
      id: 1,
      colorId: 1,
      name: 'Kirmizi',
      color: Color(0xFFFF4D67),
      amount: 1,
    );
    final motor = MotorPathEngine.activeMotorAt(
      cartridge: cartridge,
      progress: (3 + 9.5 / LevelData.rows) / 4,
    );

    expect(MotorPathEngine.findShotTarget(motor: motor, cells: cells), isNull);
  });

  test('level 5 motor and shot coordinates support its 32 by 32 grid', () {
    const cartridge = PaintCartridge(
      id: 1,
      colorId: 18,
      name: 'System Red',
      color: Color(0xFFFF453A),
      amount: 1,
    );
    final motor = MotorPathEngine.activeMotorAt(
      cartridge: cartridge,
      progress: (31.5 / 32) / 4,
      rows: 32,
      cols: 32,
    );
    const target = PixelCell(row: 31, col: 31, targetColorId: 18);
    final shot = MotorPathEngine.createShot(
      motor: motor,
      target: target,
      rows: 32,
      cols: 32,
    );

    expect(motor.lineIndex, 31);
    expect(shot.to, const Offset(31.5 / 32, 31.5 / 32));
  });

  test('levels follow the 100-level category plan', () {
    expect(LevelData.levels, hasLength(75));
    expect(LevelData.cartridges, hasLength(356));

    final first50Names = [
      "Yildiz", "Kalp", "Elma", "Muz", "Portakal", "Karpuz", "Cilek", "Ananas", "Havuc", "Mantar",
      "Kupkek", "Kurabiye", "Donat", "Dondurma", "Burger", "Pizzadilimi", "Kupa", "Anahtar", "Kilit", "Sandik",
      "Kalkan", "Kilic", "Yuzuk", "Tac", "Elmas", "Kedi", "Kitap", "Corgi", "Penguen", "Aslan",
      "Ejderha", "Timsah", "Porsuk", "Yengec", "Yunus", "Ev", "Gokdelenler", "Retro TV", "UFO", "Fuji Dagi",
      "Sokak", "Mezarlik", "Retro", "Ev", "Maymun", "Kopek", "Muzik Kutusu", "Dansci", "Tavuk", "Basketbol"
    ];

    final next25Names = [
      "Kedi", "Kopek", "Ev", "Hamburger", "Motosiklet", "Ucak", "Tir", "Kaleci", "Boksör", "Kutular",
      "Doğa Sporları", "Günbatımı", "Snowboardcu", "Şehir Trafiği", "Tiyatro Sahnesi", "Radyatör",
      "Stadyum", "İskelet Köpek", "Retro TV", "Yüzücü", "Formül 1", "Köprü", "Para Torbası", "Van Gogh", "Yıldızlı Kedi"
    ];

    for (var i = 0; i < 50; i++) {
      expect(LevelData.levels[i].name, first50Names[i]);
    }
    for (var i = 0; i < 25; i++) {
      expect(LevelData.levels[50 + i].name, next25Names[i]);
    }

    final usedColorIds = {
      for (final level in LevelData.levels)
        for (final run in level.colorRuns) run.colorId,
    };
    expect(usedColorIds.length, greaterThanOrEqualTo(40));
  });

  test('levels are playable target shapes', () {
    expect(LevelData.levels, hasLength(75));

    for (
      var levelIndex = 0;
      levelIndex < LevelData.levels.length;
      levelIndex++
    ) {
      final cells = LevelData.createCells(levelIndex: levelIndex);
      final level = LevelData.levelAt(levelIndex);
      final targets = cells.where((cell) => cell.isTarget).toList();
      final targetCountsByColor = <int, int>{};
      for (final target in targets) {
        targetCountsByColor.update(
          target.targetColorId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      expect(targets, isNotEmpty, reason: 'level ${levelIndex + 1} is empty');
      if (levelIndex != 52) {
        expect(
          targetCountsByColor.values.every((count) => count % 5 == 0),
          isTrue,
          reason: 'level ${levelIndex + 1} should use 5-cell color batches',
        );
      }
      expect(
        targets.every((cell) => cell.row >= 0 && cell.row < level.gridRows),
        isTrue,
        reason: 'level ${levelIndex + 1} should stay inside board rows',
      );
      expect(
        targets.every((cell) => cell.col >= 0 && cell.col < level.gridCols),
        isTrue,
        reason: 'level ${levelIndex + 1} should stay inside board columns',
      );

      final remainingTargets = _clearWithProductiveColorOrder(cells);
      expect(
        remainingTargets,
        isEmpty,
        reason: 'level ${levelIndex + 1} should be clearable',
      );
    }
  });

  test('level 1 uses the configured Yildiz palette and weapon capacities', () {
    final level = LevelData.levelAt(0);
    final cells = LevelData.createCells();
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Yildiz');
    expect(level.gridRows, 25);
    expect(level.gridCols, 25);
    expect(countsByColor, {12: 95, 11: 170});
    expect(countsByColor.values.fold<int>(0, (sum, count) => sum + count), 265);
  });

  test('level 2 uses the configured Kalp palette and weapon capacities', () {
    final level = LevelData.levelAt(1);
    final cells = LevelData.createCells(levelIndex: 1);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Kalp');
    expect(countsByColor, {12: 40, 1: 100});
    expect(countsByColor.values.fold<int>(0, (sum, count) => sum + count), 140);
  });

  test('level 3 uses the configured Elma palette and weapon capacities', () {
    final level = LevelData.levelAt(2);
    final cells = LevelData.createCells(levelIndex: 2);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Elma');
    expect(level.gridRows, 48);
    expect(level.gridCols, 48);
    expect(countsByColor, {3: 180, 4: 120, 6: 160, 1: 120, 5: 120, 2: 120});
    expect(countsByColor.values.fold<int>(0, (sum, count) => sum + count), 820);
  });

  test('level 4 uses the configured Muz pixel pattern', () {
    final level = LevelData.levelAt(3);
    final cells = LevelData.createCells(levelIndex: 3);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Muz');
    expect(level.gridRows, 48);
    expect(level.gridCols, 48);
    expect(countsByColor, {14: 40, 42: 40, 4: 160, 41: 120});
    expect(countsByColor.values.fold<int>(0, (sum, count) => sum + count), 360);
  });

  test('level 5 uses the configured Portakal pixel pattern', () {
    final level = LevelData.levelAt(4);
    final cells = LevelData.createCells(levelIndex: 4);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Portakal');
    expect(level.gridRows, 48);
    expect(level.gridCols, 48);
    expect(countsByColor, {12: 320, 32: 240, 42: 720, 6: 320, 41: 160});
    expect(
      countsByColor.values.fold<int>(0, (sum, count) => sum + count),
      1760,
    );
  });

  test('level 6 uses the configured Karpuz pixel pattern', () {
    final level = LevelData.levelAt(5);
    final cells = LevelData.createCells(levelIndex: 5);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Karpuz');
    expect(level.gridRows, 48);
    expect(level.gridCols, 48);
    expect(countsByColor, {1: 360, 12: 40, 11: 120, 43: 80, 44: 120});
    expect(
      countsByColor.values.fold<int>(0, (sum, count) => sum + count),
      720,
    );
  });

  test('level 12 uses the configured Kurabiye pixel pattern', () {
    final level = LevelData.levelAt(11);
    final cells = LevelData.createCells(levelIndex: 11);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Kurabiye');
    expect(level.gridRows, 48);
    expect(level.gridCols, 48);
    expect(countsByColor, {76: 840, 75: 370, 74: 1090});
    expect(
      countsByColor.values.fold<int>(0, (sum, count) => sum + count),
      2300,
    );
  });

  test('level 13 uses the configured Donat pixel pattern', () {
    final level = LevelData.levelAt(12);
    final cells = LevelData.createCells(levelIndex: 12);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Donat');
    expect(level.gridRows, 48);
    expect(level.gridCols, 48);
    expect(countsByColor, {84: 200, 79: 1150, 77: 440, 78: 440, 80: 40, 81: 10, 83: 10, 82: 10});
    expect(
      countsByColor.values.fold<int>(0, (sum, count) => sum + count),
      2300,
    );
  });

  test('level 51 uses the configured cat pixel art pattern', () {
    final level = LevelData.levelAt(50);
    final cells = LevelData.createCells(levelIndex: 50);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Kedi');
    expect(level.gridRows, 48);
    expect(level.gridCols, 48);
    expect(countsByColor, {
      1: 10,
      4: 10,
      6: 70,
      8: 10,
      10: 80,
      11: 75,
      12: 105,
      15: 30,
    });
    expect(
      countsByColor.values.fold<int>(0, (sum, count) => sum + count),
      390,
    );
  });

  test('level 52 uses the configured dog pixel art pattern', () {
    final level = LevelData.levelAt(51);
    final cells = LevelData.createCells(levelIndex: 51);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Kopek');
    expect(level.gridRows, 48);
    expect(level.gridCols, 48);
    expect(countsByColor, {
      1: 40,
      11: 25,
      14: 95,
      32: 20,
      35: 95,
      42: 235,
      47: 110,
      52: 20,
    });
    expect(
      countsByColor.values.fold<int>(0, (sum, count) => sum + count),
      640,
    );
  });

  test('level 55 uses the configured 48x48 motosiklet pixel art pattern', () {
    final level = LevelData.levelAt(54);
    final cells = LevelData.createCells(levelIndex: 54);
    final countsByColor = <int, int>{};
    for (final cell in cells.where((cell) => cell.isTarget)) {
      countsByColor.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    expect(level.name, 'Motosiklet');
    expect(level.gridRows, 48);
    expect(level.gridCols, 48);
    expect(countsByColor, {
      12: 250,
      13: 135,
      14: 120,
      46: 25,
      57: 15,
      60: 10,
      132: 185,
    });
    expect(
      countsByColor.values.fold<int>(0, (sum, count) => sum + count),
      740,
    );
  });

  test('object levels use distinct templates', () {
    final objectShapes = {
      for (final level in LevelData.levels.take(50))
        level.cellRows.join('\n'),
    };
    expect(objectShapes.length, 50);
  });

  test('animal levels use distinct templates', () {
    final animalShapes = {
      for (final level in LevelData.levels.skip(50).take(50))
        level.cellRows.join('\n'),
    };
    expect(animalShapes.length, 25);
  });
}

List<PixelCell> _clearWithProductiveColorOrder(List<PixelCell> cells) {
  final cartridgesByColor = {
    for (final cartridge in LevelData.cartridges) cartridge.colorId: cartridge,
  };

  var guard = 0;
  while (cells.any((cell) => cell.isTarget && !cell.isPainted) && guard < 100) {
    var paintedThisRound = 0;

    for (final colorId in cartridgesByColor.keys) {
      final remaining = cells
          .where(
            (cell) =>
                cell.targetColorId == colorId &&
                cell.isTarget &&
                !cell.isPainted,
          )
          .length;
      if (remaining == 0) {
        continue;
      }

      paintedThisRound += _runLap(
        cells: cells,
        cartridge: cartridgesByColor[colorId]!.copyWith(amount: remaining),
      );
    }

    if (paintedThisRound == 0) {
      break;
    }
    guard++;
  }

  return cells.where((cell) => cell.isTarget && !cell.isPainted).toList();
}

int _runLap({
  required List<PixelCell> cells,
  required PaintCartridge cartridge,
}) {
  final rows = cells.fold<int>(
    0,
    (max, cell) => cell.row >= max ? cell.row + 1 : max,
  );
  final cols = cells.fold<int>(
    0,
    (max, cell) => cell.col >= max ? cell.col + 1 : max,
  );
  final processedLineKeys = <String>{};
  var remaining = cartridge.amount;
  var hits = 0;

  for (var elapsedMs = 0; elapsedMs < 6000 && remaining > 0; elapsedMs += 35) {
    final motor = MotorPathEngine.activeMotorAt(
      cartridge: cartridge.copyWith(amount: remaining),
      progress: elapsedMs / 6000,
      rows: rows,
      cols: cols,
    );
    final lineKey = '${motor.side.name}:${motor.lineIndex}';
    if (processedLineKeys.contains(lineKey)) {
      continue;
    }
    processedLineKeys.add(lineKey);

    final target = MotorPathEngine.findShotTarget(
      motor: motor,
      cells: cells,
      rows: rows,
      cols: cols,
    );
    if (target == null) {
      continue;
    }

    cells.replaceRange(
      cells.indexWhere((cell) => cell.key == target.key),
      cells.indexWhere((cell) => cell.key == target.key) + 1,
      [target.copyWith(isPainted: true)],
    );
    remaining--;
    hits++;
  }

  return hits;
}
