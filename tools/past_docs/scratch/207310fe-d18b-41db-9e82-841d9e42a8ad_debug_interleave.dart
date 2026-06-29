import 'dart:math' as math;

class PaintCartridge {
  final int id;
  final int colorId;
  final int amount;
  PaintCartridge({required this.id, required this.colorId, required this.amount});
  @override
  String toString() => 'Cartridge(id: $id, colorId: $colorId, amount: $amount)';
}

void main() {
  final rand = math.Random();
  
  // Simulated deficits for Level 33
  final deficits = {
    42: 253, // Cream
    15: 169, // Slate Grey
    12: 349, // Black
    46: 425, // Dark Brown
    11: 20,  // White
    40: 36,  // Orange
  };

  // Generate cartridges using the partition logic
  final allowedSizes = [40, 30, 20, 15, 10];
  final queue = <PaintCartridge>[];
  int nextId = 1;

  for (final entry in deficits.entries) {
    final colorId = entry.key;
    final deficit = entry.value;
    
    int target = deficit;
    if (target < 10) target = 10;
    if (target % 5 != 0) {
      target = ((target + 4) ~/ 5) * 5;
    }
    
    final batches = <int>[];
    int remaining = target;
    while (remaining > 0) {
      final options = allowedSizes.where((s) {
        final left = remaining - s;
        return left == 0 || left >= 10;
      }).toList();
      if (options.isEmpty) {
        batches.add(remaining);
        remaining = 0;
        break;
      }
      final choice = options[rand.nextInt(options.length)];
      batches.add(choice);
      remaining -= choice;
    }
    
    for (final amt in batches) {
      queue.add(PaintCartridge(id: nextId++, colorId: colorId, amount: amt));
    }
  }

  print('Total cartridges generated: ${queue.length}');

  // Interleave logic
  final colorGroups = <int, List<PaintCartridge>>{};
  for (final c in queue) {
    colorGroups.putIfAbsent(c.colorId, () => []).add(c);
  }
  
  for (final group in colorGroups.values) {
    group.shuffle(rand);
  }
  
  final interleaved = <PaintCartridge>[];
  int? lastColorId;
  int? secondLastColorId;
  int? thirdLastColorId;
  int? lastAmount;
  
  int step = 0;
  while (colorGroups.values.any((list) => list.isNotEmpty)) {
    int bestColorId = -1;
    double bestScore = -double.infinity;
    
    for (final entry in colorGroups.entries) {
      final colorId = entry.key;
      final list = entry.value;
      if (list.isEmpty) continue;
      
      final nextCartridge = list.first;
      double score = list.length.toDouble();
      
      double penalty = 0;
      if (colorId == lastColorId) {
        penalty -= 100.0;
      } else if (colorId == secondLastColorId) {
        penalty -= 50.0;
      } else if (colorId == thirdLastColorId) {
        penalty -= 30.0;
      }
      
      if (nextCartridge.amount == lastAmount) {
        penalty -= 5.0;
      }
      
      final randVal = rand.nextDouble() * 2.0;
      score += penalty + randVal;
      
      if (score > bestScore) {
        bestScore = score;
        bestColorId = colorId;
      }
    }
    
    if (bestColorId == -1) {
      bestColorId = colorGroups.entries.firstWhere((e) => e.value.isNotEmpty).key;
    }
    
    final selectedCartridge = colorGroups[bestColorId]!.removeAt(0);
    interleaved.add(selectedCartridge);
    
    thirdLastColorId = secondLastColorId;
    secondLastColorId = lastColorId;
    lastColorId = selectedCartridge.colorId;
    lastAmount = selectedCartridge.amount;
    step++;
  }

  // Verify interleaving
  bool success = true;
  for (int i = 0; i < interleaved.length - 1; i++) {
    if (interleaved[i].colorId == interleaved[i + 1].colorId) {
      print('FAIL: Consecutive same color at indices $i and ${i + 1}: ${interleaved[i]} and ${interleaved[i + 1]}');
      success = false;
    }
  }
  
  // Verify column interleaving (index i and i + 3 should have different colors)
  for (int i = 0; i < interleaved.length - 3; i++) {
    if (interleaved[i].colorId == interleaved[i + 3].colorId) {
      print('WARNING: Same color in same column at indices $i and ${i + 3}: ${interleaved[i]} and ${interleaved[i + 3]}');
    }
  }
  
  if (success) {
    print('\nSUCCESS: All interleaved successfully!');
  }
}
