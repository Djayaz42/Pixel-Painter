import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_painter/models/level_data.dart';
import 'package:pixel_painter/screens/game_screen.dart';

void main() {
  const allowedAmounts = {10, 15, 20, 30, 40};

  for (final deficit in [100, 130, 150]) {
    test('$deficit cells produce an exact balanced batch total', () {
      final batches = CartridgeBatchPlanner.plan(
        deficit: deficit,
        fortyBudget: 5,
      );

      expect(batches.fold<int>(0, (sum, amount) => sum + amount), deficit);
      expect(batches.every(allowedAmounts.contains), isTrue);
      expect(
        batches.where((amount) => amount == 40).length,
        lessThanOrEqualTo(1),
      );
      expect(
        batches.where((amount) => amount <= 20).length,
        greaterThan(batches.where((amount) => amount >= 30).length),
      );
    });
  }

  test('levels 1-5 keep the level-wide forty count at five or fewer', () {
    for (var levelIndex = 0; levelIndex < 5; levelIndex++) {
      final plan = _planLevel(levelIndex: levelIndex, fortyLimit: 5);
      expect(
        plan
            .expand((batches) => batches)
            .where((amount) => amount == 40)
            .length,
        lessThanOrEqualTo(5),
      );
    }
  });

  test('levels 6-10 keep the level-wide forty count at seven or fewer', () {
    for (var levelIndex = 5; levelIndex < 10; levelIndex++) {
      final plan = _planLevel(levelIndex: levelIndex, fortyLimit: 7);
      expect(
        plan
            .expand((batches) => batches)
            .where((amount) => amount == 40)
            .length,
        lessThanOrEqualTo(7),
      );
    }
  });

  test('levels 11-15 keep the level-wide forty count at eight or fewer', () {
    for (var levelIndex = 10; levelIndex < 15; levelIndex++) {
      final plan = _planLevel(levelIndex: levelIndex, fortyLimit: 8);
      expect(
        plan
            .expand((batches) => batches)
            .where((amount) => amount == 40)
            .length,
        lessThanOrEqualTo(8),
      );
    }
  });

  test('levels 16-25 keep forties at roughly one quarter of the queue', () {
    for (var levelIndex = 15; levelIndex < 25; levelIndex++) {
      final targetCount = LevelData.createCells(
        levelIndex: levelIndex,
      ).where((cell) => cell.isTarget).length;
      final plan = _planLevel(
        levelIndex: levelIndex,
        fortyLimit: targetCount ~/ 80,
      );
      final queue = plan.expand((batches) => batches).toList();

      expect(
        queue.where((amount) => amount == 40).length,
        lessThanOrEqualTo((queue.length / 4).ceil()),
      );
    }
  });

  test('every level color receives its exact target ammunition', () {
    for (
      var levelIndex = 0;
      levelIndex < LevelData.levels.length;
      levelIndex++
    ) {
      final countsByColor = _targetCountsByColor(levelIndex);
      final colors = LevelData.cartridgesForLevel(levelIndex);
      var remainingFortyBudget = _fortyLimitForLevel(levelIndex, countsByColor);

      for (final color in colors) {
        final targetCount = countsByColor[color.colorId] ?? 0;
        final batches = CartridgeBatchPlanner.plan(
          deficit: targetCount,
          fortyBudget: remainingFortyBudget,
        );
        remainingFortyBudget -= batches.where((amount) => amount == 40).length;

        final ammunition = batches.fold<int>(0, (sum, amount) => sum + amount);
        if (targetCount == 0) {
          expect(batches, isEmpty);
        } else if (targetCount >= 10) {
          expect(
            ammunition,
            targetCount,
            reason:
                'level ${levelIndex + 1} color ${color.colorId} should be exact',
          );
        } else {
          expect(
            batches,
            [10],
            reason:
                'level ${levelIndex + 1} color ${color.colorId} needs fallback',
          );
        }
        expect(batches.every(allowedAmounts.contains), isTrue);
      }
    }
  });

  test('level ammunition is exact except for five-cell fallback groups', () {
    for (
      var levelIndex = 0;
      levelIndex < LevelData.levels.length;
      levelIndex++
    ) {
      final countsByColor = _targetCountsByColor(levelIndex);
      final plan = _planLevel(
        levelIndex: levelIndex,
        fortyLimit: _fortyLimitForLevel(levelIndex, countsByColor),
      );
      final targets = countsByColor.values.fold<int>(
        0,
        (sum, count) => sum + count,
      );
      final fallbackOverfill =
          countsByColor.values.where((count) => count == 5).length * 5;
      final ammunition = plan
          .expand((batches) => batches)
          .fold<int>(0, (sum, amount) => sum + amount);

      expect(
        ammunition,
        targets + fallbackOverfill,
        reason: 'level ${levelIndex + 1} should only overfill 5-cell groups',
      );
    }
  });

  test('all levels keep 10 15 and 20 as the dominant weapon group', () {
    for (
      var levelIndex = 0;
      levelIndex < LevelData.levels.length;
      levelIndex++
    ) {
      final countsByColor = _targetCountsByColor(levelIndex);
      final plan = _planLevel(
        levelIndex: levelIndex,
        fortyLimit: _fortyLimitForLevel(levelIndex, countsByColor),
      );
      final queue = plan.expand((batches) => batches).toList();
      final mainGroup = queue.where((amount) => amount <= 20).length;
      final thirties = queue.where((amount) => amount == 30).length;
      final forties = queue.where((amount) => amount == 40).length;

      expect(
        mainGroup,
        greaterThan(thirties + forties),
        reason: 'level ${levelIndex + 1} should favor 10/15/20',
      );
      expect(
        forties,
        lessThanOrEqualTo(thirties),
        reason: 'level ${levelIndex + 1} should keep 40 rarer than 30',
      );
    }
  });

  test('queue sync planning respects the remaining forty budget', () {
    final firstAddition = CartridgeBatchPlanner.plan(
      deficit: 400,
      fortyBudget: 2,
    );
    final usedForties = firstAddition.where((amount) => amount == 40).length;
    final syncAddition = CartridgeBatchPlanner.plan(
      deficit: 360,
      fortyBudget: 2 - usedForties,
    );

    expect(
      [
        ...firstAddition,
        ...syncAddition,
      ].where((amount) => amount == 40).length,
      lessThanOrEqualTo(2),
    );
    expect(syncAddition.fold<int>(0, (sum, amount) => sum + amount), 360);
  });

  test('small non-batch deficits use a controlled allowed fallback', () {
    final batches = CartridgeBatchPlanner.plan(deficit: 7, fortyBudget: 0);

    expect(batches, [10]);
  });
}

List<List<int>> _planLevel({required int levelIndex, required int fortyLimit}) {
  final countsByColor = _targetCountsByColor(levelIndex);
  final plan = <List<int>>[];
  var remainingFortyBudget = fortyLimit;

  for (final color in LevelData.cartridgesForLevel(levelIndex)) {
    final batches = CartridgeBatchPlanner.plan(
      deficit: countsByColor[color.colorId] ?? 0,
      fortyBudget: remainingFortyBudget,
    );
    remainingFortyBudget -= batches.where((amount) => amount == 40).length;
    plan.add(batches);
  }

  return plan;
}

Map<int, int> _targetCountsByColor(int levelIndex) {
  final counts = <int, int>{};
  for (final cell in LevelData.createCells(levelIndex: levelIndex)) {
    if (!cell.isTarget) {
      continue;
    }
    counts.update(cell.targetColorId, (count) => count + 1, ifAbsent: () => 1);
  }
  return counts;
}

int _fortyLimitForLevel(int levelIndex, Map<int, int> countsByColor) {
  if (levelIndex < 5) {
    return 5;
  }
  if (levelIndex < 10) {
    return 7;
  }
  if (levelIndex < 15) {
    return 8;
  }
  final targetCount = countsByColor.values.fold<int>(
    0,
    (sum, count) => sum + count,
  );
  if (levelIndex < 25) {
    return (targetCount ~/ 80).clamp(1, 1 << 30);
  }
  final categoryPosition = levelIndex % 25;
  if (categoryPosition < 5) {
    return 5;
  }
  if (categoryPosition < 10) {
    return 7;
  }
  if (categoryPosition < 15) {
    return 8;
  }
  return (targetCount ~/ 100).clamp(8, 1 << 30);
}
