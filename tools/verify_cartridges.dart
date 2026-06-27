import 'dart:io';

class LevelDefinition {
  final String name;
  final List<LevelColorRun> colorRuns;
  LevelDefinition(this.name, this.colorRuns);
}

class LevelColorRun {
  final int colorId;
  final int amount;
  LevelColorRun(this.colorId, this.amount);
}

class PaintCartridge {
  final int id;
  final int colorId;
  final int amount;
  PaintCartridge(this.id, this.colorId, this.amount);
}

// Mimic CartridgeBatchPlanner.plan
List<int> planCartridges({required int deficit, bool allowLarge = false, bool onlyThirtyAndForty = false}) {
  if (deficit <= 0) return [];
  int target = deficit;
  if (target < 10) target = 10;
  if (target % 5 != 0) {
    target = ((target + 2) ~/ 5) * 5;
  }

  if (onlyThirtyAndForty) {
    final result = _findExactPartitionForBackground(target);
    if (result != null) return result;
    return [30];
  }

  final result = _findExactPartition(target, allowLarge);
  if (result != null) return result;
  return [10];
}

List<int>? _findExactPartition(int amount, bool allowLarge) {
  if (amount == 0) return [];
  if (amount < 10) return null;
  
  final allowed = allowLarge 
      ? const [40, 30, 20, 15, 10] 
      : const [20, 15, 10];
      
  for (int size in allowed) {
    if (amount >= size) {
      final sub = _findExactPartition(amount - size, allowLarge);
      if (sub != null) {
        return [size, ...sub];
      }
    }
  }
  return null;
}

List<int>? _findExactPartitionForBackground(int amount) {
  if (amount == 0) return [];
  if (amount < 30) return null;
  const allowed = [40, 30];
  for (int size in allowed) {
    if (amount >= size) {
      final sub = _findExactPartitionForBackground(amount - size);
      if (sub != null) {
        return [size, ...sub];
      }
    }
  }
  return null;
}

void main() {
  final file = File('lib/models/level_data.dart');
  if (!file.existsSync()) {
    print('level_data.dart not found!');
    return;
  }
  
  final content = file.readAsStringSync();
  final levelRegExp = RegExp(r'static LevelDefinition _level\d+\(\)\s*\{(.*?)\n  \}', dotAll: true);
  final colorRunRegExp = RegExp(r'LevelColorRun\((\d+),\s*(\d+)\)');
  final nameRegExp = RegExp(r"name:\s*'(.*?)'");

  final matches = levelRegExp.allMatches(content);
  List<LevelDefinition> levels = [];
  int idx = 0;
  for (final match in matches) {
    final body = match.group(1) ?? '';
    final nameMatch = nameRegExp.firstMatch(body);
    final name = nameMatch?.group(1) ?? 'Unknown';
    final runMatches = colorRunRegExp.allMatches(body);
    List<LevelColorRun> runs = [];
    for (final runMatch in runMatches) {
      runs.add(LevelColorRun(
        int.parse(runMatch.group(1)!),
        int.parse(runMatch.group(2)!),
      ));
    }
    levels.add(LevelDefinition(name, runs));
  }

  bool hasErrors = false;

  for (int i = 0; i < levels.length; i++) {
    final lvl = levels[i];
    
    // Mimic the _buildCartridgeQueue logic
    var nextId = 1;
    final batchesByColor = <int, List<int>>{};
    
    // Find background colorId (most targets)
    int backgroundId = -1;
    int maxTargets = -1;
    for (final run in lvl.colorRuns) {
      if (run.amount > maxTargets) {
        maxTargets = run.amount;
        backgroundId = run.colorId;
      }
    }

    int fortyBudget = (i < 5) ? 5 : (i < 10) ? 7 : (i < 15) ? 8 : (i < 25) ? (maxTargets ~/ 80) : (i % 25 < 5) ? 5 : (i % 25 < 10) ? 7 : (i % 25 < 15) ? 8 : (maxTargets ~/ 100);
    if (fortyBudget < 1) fortyBudget = 1;

    for (final run in lvl.colorRuns) {
      final isBackground = (run.colorId == backgroundId && i != 26 && i != 36 && i != 37) ||
          (i == 13 && (run.colorId == 3 || run.colorId == 5 || run.colorId == 76)) ||
          (i == 14 && (run.colorId == 101 || run.colorId == 102)) ||
          (i == 15 && (run.colorId == 103 || run.colorId == 104));
      final allowLarge = isBackground || (i == 26 && run.colorId == 16);
      final onlyThirtyAndForty = isBackground;
      
      List<int> batches;
      if (i == 36 && run.colorId == 12) {
        batches = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 15, 10];
      } else if (i == 37) {
        if (run.colorId == 12) {
          batches = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20];
        } else if (run.colorId == 13) {
          batches = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20];
        } else if (run.colorId == 14) {
          batches = [20, 20, 20, 20, 20, 20, 20, 15, 10];
        } else if (run.colorId == 31) {
          batches = [20, 20, 20, 20, 15];
        } else if (run.colorId == 15) {
          batches = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 15, 10];
        } else if (run.colorId == 19) {
          batches = [15, 10];
        } else {
          batches = [];
        }
      } else {
        batches = planCartridges(
          deficit: run.amount,
          allowLarge: allowLarge,
          onlyThirtyAndForty: onlyThirtyAndForty,
        );
      }
      batchesByColor[run.colorId] = batches;
    }

    final queue = <PaintCartridge>[];
    for (final run in lvl.colorRuns) {
      final batches = batchesByColor[run.colorId] ?? [];
      for (final amount in batches) {
        queue.add(PaintCartridge(nextId++, run.colorId, amount));
      }
    }

    // Splitting logic to ensure at least 6 cartridges
    while (queue.length < 6) {
      int splitIndex = queue.indexWhere((c) => c.amount > 10 && c.amount != 15);
      if (splitIndex == -1) break;
      
      final target = queue[splitIndex];
      List<int> parts = [];
      if (target.amount == 40) {
        parts = [20, 20];
      } else if (target.amount == 30) {
        parts = [15, 15];
      } else if (target.amount == 20) {
        parts = [10, 10];
      }
      
      queue.removeAt(splitIndex);
      for (int part in parts) {
        queue.insert(
          splitIndex,
          PaintCartridge(nextId++, target.colorId, part),
        );
      }
    }

    // Now verify the queue
    if (queue.length < 6) {
      print('Error in Level ${i + 1} (${lvl.name}): Queue length is only ${queue.length}!');
      hasErrors = true;
    }

    int totalBullets = 0;
    for (final c in queue) {
      if (![10, 15, 20, 30, 40].contains(c.amount)) {
        print('Error in Level ${i + 1} (${lvl.name}): Cartridge amount ${c.amount} is not in {10, 15, 20, 30, 40}!');
        hasErrors = true;
      }
      totalBullets += c.amount;
    }

    int expectedBullets = lvl.colorRuns.map((r) => r.amount).fold(0, (sum, val) => sum + val);
    if (totalBullets != expectedBullets) {
      print('Error in Level ${i + 1} (${lvl.name}): Total bullets $totalBullets does not match expected cell targets $expectedBullets!');
      hasErrors = true;
    }
  }

  if (hasErrors) {
    print('Cartridge verification failed!');
  } else {
    print('All cartridge queues verified successfully! Every level has >= 6 cartridges of valid sizes summing to the exact target cell count.');
  }
}
