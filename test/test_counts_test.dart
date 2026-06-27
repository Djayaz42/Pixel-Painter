import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_painter/models/level_data.dart';

void main() {
  test('inspect Level 30 runtime counts', () {
    final level = LevelData.levelAt(29); // Level 30 (0-indexed 29)
    final counts = <String, int>{};
    print('Grid rows for Level 30:');
    for (final row in level.cellRows) {
      print(row);
      for (int i = 0; i < row.length; i++) {
        counts[row[i]] = (counts[row[i]] ?? 0) + 1;
      }
    }
    print('Runtime character counts for Level 30:');
    print(counts);
    print('Runtime color runs for Level 30:');
    for (final run in level.colorRuns) {
      print('Color ${run.colorId}: ${run.amount}');
    }
  });
}
