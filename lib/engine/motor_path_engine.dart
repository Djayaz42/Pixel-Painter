import 'package:flutter/material.dart';

import '../models/active_motor.dart';
import '../models/level_data.dart';
import '../models/paint_cartridge.dart';
import '../models/pixel_cell.dart';
import '../models/shot_event.dart';

class MotorPathEngine {
  const MotorPathEngine._();

  static ActiveMotor activeMotorAt({
    required PaintCartridge cartridge,
    required double progress,
    int rows = LevelData.rows,
    int cols = LevelData.cols,
  }) {
    final p = progress.clamp(0.0, 1.0);
    final segment = p * 4;
    final sideProgress = segment - segment.floor();
    final columnIndex = (sideProgress * cols).floor().clamp(0, cols - 1);
    final rowIndex = (sideProgress * rows).floor().clamp(0, rows - 1);

    if (segment < 1) {
      return ActiveMotor(
        cartridge: cartridge,
        progress: p,
        position: Offset(segment, 1),
        side: MotorSide.bottom,
        lineIndex: columnIndex,
      );
    }

    if (segment < 2) {
      return ActiveMotor(
        cartridge: cartridge,
        progress: p,
        position: Offset(1, 2 - segment),
        side: MotorSide.right,
        lineIndex: rows - 1 - rowIndex,
      );
    }

    if (segment < 3) {
      return ActiveMotor(
        cartridge: cartridge,
        progress: p,
        position: Offset(3 - segment, 0),
        side: MotorSide.top,
        lineIndex: cols - 1 - columnIndex,
      );
    }

    return ActiveMotor(
      cartridge: cartridge,
      progress: p,
      position: Offset(0, segment - 3),
      side: MotorSide.left,
      lineIndex: rowIndex,
    );
  }

  static PixelCell? findShotTarget({
    required ActiveMotor motor,
    required List<PixelCell> cells,
    int rows = LevelData.rows,
    int cols = LevelData.cols,
  }) {
    final targets = findShotTargets(
      motor: motor,
      cells: cells,
      rows: rows,
      cols: cols,
    );
    return targets.isEmpty ? null : targets.first;
  }

  static List<PixelCell> findShotTargets({
    required ActiveMotor motor,
    required List<PixelCell> cells,
    int rows = LevelData.rows,
    int cols = LevelData.cols,
  }) {
    if (motor.cartridge.amount <= 0) {
      return const [];
    }

    final aimCol = switch (motor.side) {
      MotorSide.top || MotorSide.bottom => motor.lineIndex,
      MotorSide.left => 0,
      MotorSide.right => cols - 1,
    };
    final aimRow = switch (motor.side) {
      MotorSide.left || MotorSide.right => motor.lineIndex,
      MotorSide.top => 0,
      MotorSide.bottom => rows - 1,
    };

    PixelCell? cellAt(int row, int col) {
      for (final cell in cells) {
        if (cell.row == row && cell.col == col) {
          return cell;
        }
      }
      return null;
    }

    final visibleTargets = <PixelCell>[];

    void addIfShootable(PixelCell? cell) {
      if (cell == null) {
        return;
      }

      if (!cell.isPainted && cell.targetColorId == motor.cartridge.colorId) {
        visibleTargets.add(cell);
      }
    }

    PixelCell? firstInColumn(int col, {required bool reverse}) {
      if (col < 0 || col >= cols) {
        return null;
      }

      final rowIndexes = reverse
          ? Iterable<int>.generate(rows, (index) => rows - 1 - index)
          : Iterable<int>.generate(rows);

      for (final row in rowIndexes) {
        final cell = cellAt(row, col);
        if (cell != null && cell.isTarget && !cell.isPainted) {
          return cell;
        }
      }

      return null;
    }

    PixelCell? firstInRow(int row, {required bool reverse}) {
      if (row < 0 || row >= rows) {
        return null;
      }

      final colIndexes = reverse
          ? Iterable<int>.generate(cols, (index) => cols - 1 - index)
          : Iterable<int>.generate(cols);

      for (final col in colIndexes) {
        final cell = cellAt(row, col);
        if (cell != null && cell.isTarget && !cell.isPainted) {
          return cell;
        }
      }

      return null;
    }

    switch (motor.side) {
      case MotorSide.top:
        addIfShootable(firstInColumn(motor.lineIndex, reverse: false));
      case MotorSide.right:
        addIfShootable(firstInRow(motor.lineIndex, reverse: true));
      case MotorSide.bottom:
        addIfShootable(firstInColumn(motor.lineIndex, reverse: true));
      case MotorSide.left:
        addIfShootable(firstInRow(motor.lineIndex, reverse: false));
    }

    visibleTargets.sort((a, b) {
      final aDistance = (a.col - aimCol).abs() + (a.row - aimRow).abs();
      final bDistance = (b.col - aimCol).abs() + (b.row - aimRow).abs();
      return aDistance.compareTo(bDistance);
    });

    final uniqueTargets = <String, PixelCell>{};
    for (final target in visibleTargets) {
      uniqueTargets[target.key] = target;
    }

    return uniqueTargets.values.toList();
  }

  static ShotEvent createShot({
    required ActiveMotor motor,
    required PixelCell target,
    int rows = LevelData.rows,
    int cols = LevelData.cols,
  }) {
    final targetCenter = Offset(
      (target.col + 0.5) / cols,
      (target.row + 0.5) / rows,
    );

    return ShotEvent(
      from: motor.position,
      to: targetCenter,
      color: motor.cartridge.color,
      createdAt: DateTime.now(),
    );
  }
}
