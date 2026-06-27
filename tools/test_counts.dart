import '../lib/models/level_data.dart';

void main() {
  final level = LevelData.levelAt(29); // Level 30
  final counts = <String, int>{};
  for (final row in level.cellRows) {
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
}
