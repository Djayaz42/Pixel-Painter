import 'dart:io';

void main() {
  final List<String> rawCrab = [
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYAYYYYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYLYpALYYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYALYLALYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYAApKLAAYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYLAAYKKApAYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYLAApppLALYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYAAAYpLApYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYAAAALAApYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYLAAAAAApYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYLppLALppYYAAAAAApYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYLppApApApLYpAAAAApYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYpAAAAAAAAAAAppLpAAAALLYYYYYYYYYYY",
    "YYYYYYYYYYYYYYLpAAAAAAAAAAAAAAAAALppLYYYYYYYYYYY",
    "YYYYYYYYYYYYYLpAAAAAAAAAAAAAAAAALAAApYYYYYYYYYYY",
    "TTTTTTTTTTTTAAAAAAAAAAAAAAAAAAAAALAAATTTTTTTTTTT",
    "TTTTTTTTTTTLAAAAAAAAAAAAAAAAAAAAAALLTTTTTTTTTTTT",
    "TTTTTTTTTTTLLAAAAAAAAAAAAAAAAAAAALLTTATTTTTTTTTT",
    "TTTTTTTTTTTTALAAAAAAddddddAAAAAAALpLALpTTTTTTTTT",
    "TTTTTTTTTTTTpALAAAAAddddddAAAAALApLALATTTTTTTTTT",
    "TTTTTTTTTTTTTLAAAAALddddddLAAALAALAApATTTTTTTTTT",
    "TTTTTTTAppppppALdppppAALApppppLAALAppppLTTTTTTTT",
    "TTTTTTTALAAAAAALLdppppppppppdpLLAAAAAAAAATTTTTTT",
    "TTTTTTLAATdLLALLLAdddddpddddALLApALLpTTLpTTTTTTT",
    "TTTTTTLALpAAAAAAAAAALALpLLLAAALAAAAApLpALTTTTTTT",
    "TTTTTTpApAAAApAAAAALTTTTTTTTTLALALLLLALApTTTTTTT",
    "TTTTTTLpLALATpAATTTTTTTTTTTTTTLApTTAAAppTTTTTTTT",
    "TTTTTTLApAAApLAAAALTTTTTTTTTTpALTTLALdAATTTTTTTT",
    "TTTTTTTpAATAALAAAAALpTTTTTTTAAATTpAATTpATTTTTTTT",
    "TTTTTTTAALTTLApAAAAAATTTTTTAALTTTLApTTpALTTTTTTT",
    "TTTTTTTLApTTTAAAAAAAAATTTTLAATTTTLATTLAATTTTTTTT",
    "TTTTTTTTAATTTpLpAAApAALppAApppppAATTTAATTTTTTTTT",
    "TTTTTTTTAApTpppApAAApLLppppppppALpppLATTTTTTTTTT",
    "TTTTTTTTTLAppppppLpAAAppppppppppppppLATTTTTTTTTT",
    "TTTTTTTpppALpppppppLLLpppppppppppppLppppTTTTTTTT",
    "PPPPPPppppppppppppppppppppppppppppppppppppPPPPPP",
    "pWpPPWWWppWWWppWWWpppWWpppWWpppWWpppWWWppWWWPPWW",
    "PPpWWPPPWWPpPWWpPpWWWPPWWWPPWWWPPpWWpppWWpPPWWpP",
    "PPPPPPPWPPWWWpPWWWpPWWWpPWWWWPpWWWppWWWPPWPPPPPP",
    "PPPPPPPPWWPPpWWpPPWWppPpWpPPdWWPPPWWPppWWPPPPPPP",
    "PPPPPPPPPPPWWppWWWWPWWWWPWWWWPWWWWPWWWPPPPPPPPPP",
    "PPPPPPPPPPPPPpWPPPpWPPPPWPPPPWPPPPWPPPPPPPPPPPPP",
    "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
    "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
    "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"
  ];

  final size = 48;
  final List<List<String>> grid = rawCrab.map((r) => r.split('')).toList();

  // Force 4 corners to be empty '.'
  grid[0][0] = '.';
  grid[0][size - 1] = '.';
  grid[size - 1][0] = '.';
  grid[size - 1][size - 1] = '.';

  int countChar(String char) {
    int count = 0;
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        if (grid[y][x] == char) count++;
      }
    }
    return count;
  }

  List<List<int>> getNeighbors(int y, int x) {
    final list = <List<int>>[];
    final dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    for (final d in dirs) {
      int ny = y + d[0];
      int nx = x + d[1];
      if (ny >= 0 && ny < size && nx >= 0 && nx < size) {
        list.add([ny, nx]);
      }
    }
    return list;
  }

  final bgColors = {'Y', 'T', 'P'};

  // Targets we want for each foreground color:
  final Map<String, int> targetCounts = {
    'K': 5,
    'L': 120,
    'd': 45,
    'p': 255,
    'A': 365,
    'W': 105,
  };

  // Run balancing until all foreground counts are correct
  bool fgBalanced = false;
  int iter = 0;
  while (!fgBalanced && iter < 1000) {
    fgBalanced = true;
    iter++;

    for (final entry in targetCounts.entries) {
      final char = entry.key;
      final target = entry.value;
      int count = countChar(char);

      if (count == target) continue;
      fgBalanced = false;

      if (count < target) {
        bool progress = false;
        // First try to replace background colors
        for (int y = 0; y < size && !progress; y++) {
          for (int x = 0; x < size && !progress; x++) {
            if (grid[y][x] == char) {
              for (final n in getNeighbors(y, x)) {
                final ny = n[0];
                final nx = n[1];
                final nc = grid[ny][nx];
                if (bgColors.contains(nc)) {
                  grid[ny][nx] = char;
                  progress = true;
                  break;
                }
              }
            }
          }
        }
        // If not progress, allow replacing any other color (except '.')
        if (!progress) {
          for (int y = 0; y < size && !progress; y++) {
            for (int x = 0; x < size && !progress; x++) {
              if (grid[y][x] == char) {
                for (final n in getNeighbors(y, x)) {
                  final ny = n[0];
                  final nx = n[1];
                  final nc = grid[ny][nx];
                  if (nc != '.' && nc != char) {
                    grid[ny][nx] = char;
                    progress = true;
                    break;
                  }
                }
              }
            }
          }
        }
      } else {
        // Need to remove pixels of char (prefer to replace with background colors)
        bool progress = false;
        for (int y = 0; y < size && !progress; y++) {
          for (int x = 0; x < size && !progress; x++) {
            if (grid[y][x] == char) {
              for (final n in getNeighbors(y, x)) {
                final ny = n[0];
                final nx = n[1];
                final nc = grid[ny][nx];
                if (bgColors.contains(nc)) {
                  grid[y][x] = nc;
                  progress = true;
                  break;
                }
              }
            }
          }
        }
        if (!progress) {
          for (int y = 0; y < size && !progress; y++) {
            for (int x = 0; x < size && !progress; x++) {
              if (grid[y][x] == char) {
                for (final n in getNeighbors(y, x)) {
                  final ny = n[0];
                  final nx = n[1];
                  final nc = grid[ny][nx];
                  if (nc != '.' && nc != char) {
                    grid[y][x] = nc;
                    progress = true;
                    break;
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  print('Foreground balanced in $iter iterations.');

  // Now balance background colors
  final bgList = ['Y', 'T'];
  final bgNext = {'Y': 'T', 'T': 'P'};
  final Map<String, int> bgTargets = {
    'Y': 685,
    'T': 430,
    'P': 290,
  };

  for (final char in bgList) {
    final target = bgTargets[char]!;
    final nextChar = bgNext[char]!;

    while (true) {
      int count = countChar(char);
      if (count == target) break;

      if (count < target) {
        // Convert nextChar to char
        bool progress = false;
        for (int y = 0; y < size && !progress; y++) {
          for (int x = 0; x < size && !progress; x++) {
            if (grid[y][x] == nextChar) {
              for (final n in getNeighbors(y, x)) {
                final ny = n[0];
                final nx = n[1];
                if (grid[ny][nx] == char) {
                  grid[y][x] = char;
                  progress = true;
                  break;
                }
              }
            }
          }
        }
        if (!progress) {
          print('Failed to balance background $char');
          break;
        }
      } else {
        // Convert char to nextChar
        bool progress = false;
        for (int y = 0; y < size && !progress; y++) {
          for (int x = 0; x < size && !progress; x++) {
            if (grid[y][x] == char) {
              for (final n in getNeighbors(y, x)) {
                final ny = n[0];
                final nx = n[1];
                if (grid[ny][nx] == nextChar) {
                  grid[y][x] = nextChar;
                  progress = true;
                  break;
                }
              }
            }
          }
        }
        if (!progress) {
          print('Failed to balance background $char');
          break;
        }
      }
    }
  }

  print('=== Balanced Crab Grid ===');
  for (final row in grid) {
    print('    "${row.join('')}",');
  }

  print('\n=== Balanced Color Runs ===');
  int total = 0;
  final allColors = ['K', 'L', 'd', 'p', 'A', 'W', 'Y', 'T', 'P'];
  for (final char in allColors) {
    int count = countChar(char);
    print('$char: $count');
    total += count;
  }
  print('Total targets: $total (should be 2300)');
}
