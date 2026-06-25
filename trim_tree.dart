void main() {
  final rows = _trimAncientTree(_ancientTreeCellRows());
  for (var r in rows) {
    print("'$r',");
  }
}

  List<String> _trimAncientTree(List<String> rows) {
    final trimmed = <String>[];
    for (var row = 0; row < rows.length; row++) {
      var newRow = '';
      for (var col = 0; col < rows[row].length; col++) {
        if ((row <= 16 && (col == 0 || col == 31)) ||
            (row >= 17 && (col < 10 || col > 21)) ||
            (row >= 24 && (col < 12 || col > 19))) {
          newRow += '.';
        } else {
          newRow += rows[row][col];
        }
      }
      trimmed.add(newRow);
    }
    return _trimColorRemainders(trimmed);
  }

  List<String> _trimColorRemainders(List<String> rows) {
    final trimmed = rows.map((row) => row.split('')).toList();
    final counts = <String, int>{};
    for (final row in trimmed) {
      for (final cell in row) {
        if (cell != '.') {
          counts.update(cell, (count) => count + 1, ifAbsent: () => 1);
        }
      }
    }
    for (final entry in counts.entries) {
      var remainder = entry.value % 5;
      for (var row = trimmed.length - 1; row >= 0 && remainder > 0; row--) {
        for (
          var col = trimmed[row].length - 1;
          col >= 0 && remainder > 0;
          col--
        ) {
          if (trimmed[row][col] == entry.key) {
            trimmed[row][col] = '.';
            remainder--;
          }
        }
      }
    }
    return [for (final row in trimmed) row.join()];
  }

  List<String> _ancientTreeCellRows() {
    return const [
      '................................',
      '...........KKKKKKKKKK...........',
      '........KKKGGGGGGGGGGKKK........',
      '......KKGGGGMMMMGGGGGGGGKK......',
      '.....KGGGGMMMMMMMMGGGGGGGGK.....',
      '...KKGGGMMMDDDDMMMMGGGGGGGKK....',
      '..KGGGGMMDDDDDDDDMMMGMGGGGGGK...',
      '.KGGGMMMDDMMMMMDDDMMMMMMGGGGGK..',
      'KGGGMMMDDMMGGGMMDDMMMDDMMGGGGK..',
      'KGGMMDDDDMGGGGGMMDDDDDDMMGGGGK..',
      'KGGMMDDDMGGGGGGGMMDDDDDMMGGGGK..',
      'KGGGMMDDMMGGGGGGMMMDD.MMGGGGGK..',
      '.KGGGMMMMMGGGGGGGGMMMMMMGGGGGK..',
      '..KGGGGMMGGGGGGGGGGMMGGGGGGK....',
      '...KKGGGGGGGGMMGGGGGGGGGGKK.....',
      '.....KKGGGGMMMMGGGGGGGGKK.......',
      '........KKKKGGG...K.............',
      '.............KKKK...............',
      '............KvvvK...............',
      '..........KKvvwvvKK.............',
      '.........KvvvwwvvvK.............',
      '........KvvwwvvwwvvK............',
      '.......KvvvwwvvvwwvvK...........',
      '......KvvwwvvvwwvvvwwK..........',
      '.....KvvvwwvvvwwvvvwwvK.........',
      '....KvvwwvvvwwvvvwwvvwwK........',
      '...KvvvwwvvvwwvvvwwvvvwwK.......',
      '..Kvvvwwvvvwwvvvwwvvv..vvK......',
      '.KKKvvvKKvvvKKvvvKK...KKKK......',
      '....KKK..KKK..KKK..KK...........',
      '................................',
      '................................',
    ];
  }
