void main() {
  final rows = [
    '................................',
    '...............KK...............',
    '..............KGKK..............', // G-1, K+1
    '.............KGGGMK.............',
    '.............KGGMKK.............', // D-1, K+1
    '............KGGGMDK.............',
    '...........KGGGGMDKK............',
    '...........KGMMMMDDK............',
    '..........KGGMGGMMDK............',
    '.........KGGGGMMMMDDK...........',
    '.........KGGMMMMMMDDK...........',
    '........KGGGGMMGMMDDKK..........',
    '.......KGGGGGMMMMMMDDK..........',
    '.......KGMMMMMMMMMMDDK..........',
    '......KGGGGGGMMGMMMDDKK.........',
    '......KGGGGMMMMMMMMMDDK.........',
    '.....KGMMMMMMMMMMMMMDDDK........',
    '.....KGGMGGGGMMMMMMMDDDK........',
    '....KGGGGGMMMMMMMMMMDDDKK.......',
    '....KGGGGMMMMMMMMMMMMMDDK.......',
    '...KGGMGGGGGMGMMMMMMMDDDK.......',
    '...KGGGGGMMMMMMMMMMMMMDDDK......',
    '..KGGMGGGGGMMMMMMMMMMMDDDKK.....',
    '..KGGGGGMMMMMMMMMMMMMMMDDDK.....',
    '.KGGMGGGGGMMGMMMMMMMMMDDDK......',
    '.KKKKKKKKKKKKKwwvwvKKKKKKKK.....',
    '.............KwvwvwK............',
    '.............KwvwvwK............',
    '.............KwvwvwK............',
    '............KwKvwvwvK...........', // w-1, K+1
    '...........KwwwvwvwvvK..........',
    '.........KKKKKKKKKKKKK..........', // K+2, .-2
  ];

  for (int i = 0; i < rows.length; i++) {
    if (rows[i].length != 32) {
      if (rows[i].length < 32) {
        rows[i] = rows[i].padRight(32, '.');
      } else {
        rows[i] = rows[i].substring(0, 32);
      }
    }
  }

  List<String> _fillBackground(List<String> rws, List<String> colors) {
    final filledRows = rws.toList();
    for (var band = 0; band < colors.length; band++) {
      final start = band * rws.length ~/ colors.length;
      final end = (band + 1) * rws.length ~/ colors.length;
      int dotsCount = 0;
      for (var i = start; i < end; i++) {
        for (var c in filledRows[i].split('')) {
          if (c == '.') dotsCount++;
        }
      }
      var blanksToKeep = dotsCount % 5;
      
      for (var row = start; row < end; row++) {
        var newRow = '';
        for (var col = 0; col < filledRows[row].length; col++) {
          if (filledRows[row][col] == '.') {
            if (blanksToKeep > 0) {
              newRow += '.';
              blanksToKeep--;
            } else {
              newRow += colors[band];
            }
          } else {
            newRow += filledRows[row][col];
          }
        }
        filledRows[row] = newRow;
      }
    }
    return filledRows;
  }

  final bgFilled = _fillBackground(rows, ['D', 'M', 'G', 'T']);

  Map<String, int> charCounts = {};
  for (var r in bgFilled) {
    for (int i = 0; i < r.length; i++) {
      String c = r[i];
      if (c != '.') {
        charCounts[c] = (charCounts[c] ?? 0) + 1;
      }
    }
  }

  final charToId = {
    'R': 1, 'B': 2, 'G': 3, 'T': 7, 'W': 11, 'K': 12, 'S': 13, 'A': 15,
    'C': 16, 'U': 17, 'V': 18, 'L': 19, 'O': 20, 'D': 21, 'M': 22, 'E': 23,
    'Q': 24, 'X': 25, 'Y': 26, 'Z': 27, 'H': 28, 'N': 29, 'I': 30, 'P': 31,
    'J': 32, 'F': 33, 'r': 34, 'n': 4, 'm': 6, 'g': 3, 'a': 35, 'h': 36,
    'u': 37, 'v': 38, 'w': 39, 'x': 40, 'y': 41, 'z': 42,
  };

  int changesNeeded = 0;
  print('const [');
  for (var entry in charCounts.entries) {
    int rem = entry.value % 5;
    if (rem != 0) changesNeeded++;
    print('  LevelColorRun(' + charToId[entry.key].toString() + ', ' + entry.value.toString() + '), // ' + entry.key);
  }
  print('],');
  print('Total colors needing mod 5 adjust: ' + changesNeeded.toString());
}
