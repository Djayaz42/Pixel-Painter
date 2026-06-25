import 'dart:io';

// We will parse the file level_data.dart directly to extract colorRuns for verification.
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
  print('Total levels found in level_data.dart: ${matches.length}');

  bool hasErrors = false;
  int count = 0;

  for (final match in matches) {
    count++;
    final body = match.group(1) ?? '';
    final nameMatch = nameRegExp.firstMatch(body);
    final name = nameMatch?.group(1) ?? 'Unknown';

    final runMatches = colorRunRegExp.allMatches(body);
    int totalTarget = 0;

    for (final runMatch in runMatches) {
      final colorId = int.parse(runMatch.group(1)!);
      final amount = int.parse(runMatch.group(2)!);

      if (amount % 5 != 0) {
        print('Error in Level $count ($name): colorId $colorId has count $amount which is not a multiple of 5!');
        hasErrors = true;
      }
      if (amount < 10) {
        print('Error in Level $count ($name): colorId $colorId has count $amount which is less than 10!');
        hasErrors = true;
      }
      totalTarget += amount;
    }

    if (totalTarget < 60) {
      print('Error in Level $count ($name): total target count is $totalTarget which is less than 60!');
      hasErrors = true;
    }
  }

  if (hasErrors) {
    print('Verification failed! Some levels violate constraints.');
  } else {
    print('All levels verified successfully! Every level satisfies the multiples of 5, >=10, and >=60 targets constraints.');
  }
}
