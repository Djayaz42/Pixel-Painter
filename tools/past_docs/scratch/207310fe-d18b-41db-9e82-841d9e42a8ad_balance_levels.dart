import 'dart:io';

void main() {
  balanceCrab();
  balanceDolphin();
}

void balanceCrab() {
  final List<String> rawCrab = [
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYAYYYYYYYYYYYYYYYYY",
    "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYAYYYYYYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYYYYYYYYYYYYAYLYYYYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYYYYYYYYYYYppALYYYYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYYYYYYYYYYALpKALYYYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYYYYYYYYYYAApKLAAYYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYYYYYYYYYLAAKKKApAYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYYYYYYYYYLAApppLALYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYYYYYYYYYYAAAYpLApYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYYYYYYYYYYAAAALAApYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYYYYYYYYYYLAAAAAApYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYYLppLALppYYAAAAAApYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYYYYLppApApApLYpAAAAApYYYYYYYYYYYY",
    "TYYYYYYYYYYYYYYpAAAAAAAAAAAppLpAAAALLYYYYYYYYYYY",
    "TYYYYYYYYYYYYYLpAAAAAAAAAAAAAAAAALppLYYYYYYYYYYY",
    "TYYYYYYYYYYYYLpAAAAAAAAAAAAAAAAALAAApYYYYYYYYYYY",
    "TTTTTTTTTTTTAAAAAAAAAAAAAAAAAAAAALAAATTTTTTTTTTT",
    "TTTTTTTTTTTLAAAAAAAAAAAAAAAAAAAAAALLTTTTTTTTTTTT",
    "TTTTTTTTTTTLLAAAAAAAAAAAAAAAAAAAALLTTATTTTTTTTTT",
    "TTTTTTTTTTTTALAAAAAAddddddAAAAAAALpLALpTTTTTTTTT",
    "TTTTTTTTTTTTpALAAAAAddddddAAAAALApLALATTTTTTTTTT",
    "TTTTTTTTTTTTTLAAAAALddddddLAAALAALAApATTTTTTTTTT",
    "TTTTTTTAppppppALdppppAALApppppLAALAppppLTTTTTTTT",
    "TTTTTTTALAAAAAALLdppppppppppdpLLAAAAAAAAATTTTTTT",
    "TTTTTTLAAddLLALLLAdddddpddddALLApALLpTTLpTTTTTTT",
    "TTTTTTLALpAAAAAAAAAALALpLLLAAALAAAAApLpALTTTTTTT",
    "TTTTTTpApAAAApAAAAALTTTTTTTTTLALALLLLALApTTTTTTT",
    "TTTTTTLpLALATpAATTTTTTTTTTTTTTLApTTAAAppTTTTTTTT",
    "TTTTTTLApAAApLAAAALTTTTTTTTTTpALTTLALdAATTTTTTTT",
    "TTTTTTTpAATAALAAAAALpTTTTTTTAAATTpAATTpATTTTTTTT",
    "TTTTTTTAALTTLApAAAAAATTTTTTAALTTTLApTTpALTTTTTTT",
    "TTTTTTTLApTTTAAAAAAAAATTTTLAATTTTLATTLAATTTTTTTT",
    "TTTTTTTTAATTTpLpAAApAALppAApppppAATTTAATTTTTTTTT",
    "PTTTTTTTAApTpppApAAApLLppppppppALpppLATTTTTTTTTT",
    "PTTTTTTTTLAppppppLpAAAppppppppppppppLATTTTTTTTTT",
    "PTTTTTTpppALpppppppLLLpppppppppppppLppppTTTTTTTT",
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

  final Map<String, int> targetCounts = {
    'K': 10,  // Changed from 5 to 10 to avoid size-5 cartridges
    'L': 120,
    'd': 45,
    'p': 255,
    'A': 360, // Changed from 365 to 360 to balance K
    'W': 105,
  };

  bool fgBalanced = false;
  int iter = 0;
  while (!fgBalanced && iter < 5000) {
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

  print('Crab foreground balanced in $iter iterations.');

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
          print('Failed to balance Crab background $char');
          break;
        }
      } else {
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
          print('Failed to balance Crab background $char');
          break;
        }
      }
    }
  }

  print('=== BALANCED CRAB GRID ===');
  for (final row in grid) {
    print('    "${row.join('')}",');
  }
}

void balanceDolphin() {
  final List<String> rawDolphin = [
    ".JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ.",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ",
    "KJJeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "Keeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    "Keeedddddeddddddddedeeedeeeeddeeddddeeddeddddddd",
    "KddeddddddddddddddddPdededdddddeddddddddddeddddd",
    "KdddddddddddddddddddPdOdJOOedddddddddddddddddddd",
    "KdddddddddddddddddddeOOOOOOOOddddddddddddddddddd",
    "KddddddddddddddddddddOOOOOOOOOdddddddddddddddddd",
    "KdddddddddddddddddddOOOOOOOOOOdddddddddddddddddd",
    "KdddddddddddddddddddOOOOOOOOPOeddddddddddddddddd",
    "KddddddddddddddddddOOOOOPOOOOOOddddddddddddddddd",
    "edddddddddddddddddOOOOOOOPPddddddddddddddddddddd",
    "edddddddddddddddddOOOOOJOLLddddddddddddddddddddd",
    "edddddddddddddddddOOOOdLdLdddddddddddddddddddddd",
    "eddddddddddddddddOOOdddddddddddddddddddddddddddd",
    "eddddddddddddddddOOddddddddddddddddddddddddddddd",
    "eddddddddddddddddOOdddddddddddddppppdddddddddddd",
    "eddddddddddddddddOdddddddddddddpeeeppddddddddddd",
    "edddddddddddddddPOddddddddddddppeeeepddddddddddd",
    "eddddddddddddddPPPdXddddddddddpeeeeeppdddddddddd",
    "edddddddddddddOPPPdXddddddddddpeeeeeeddddddddddd",
    "edddddddddddddddddPXdddddddddddppppppddddddddddd",
    "KddYYYYYYYYYYYYXYYPYYYYYYYYYYYYeeeeeXYYYYYYYYYYY",
    "KYYYYBBYBBBKYYYYYXYXYYYYYYYeYeeXXeXXeYeYYBBBBYYY",
    "KBVYYYYYYYYBBXXBBYBBBBBBBYYYYXYYeeXYYYBBYYYYYBBY",
    "KPVVVBBBBBBXBVXXBBYYBXBBYBYYYYYXXeYYYBYYBBBBBBBB",
    "KBBBBYBBBBBBXXXBBBBYBBBBBYYYYYYYYYYBYBBBBBBBBBBB",
    "KBBBYYVYBBVBXBXBBXBBBBBBBYYYYYYYBBBYYBBBBYBBBYYY",
    "KBVBVVBBBVVYVVBXBBBYBBBYYBXVBBBBBBBBBBBBBBVVPBBB",
    "KBBBBBBYBBBBBBBVBBBBBBBBBVVVBVVVBBBBBBBBVVVVBVVB",
    "KBBBBBBBBBVVVVVVVPVBBVVBBBBBBBBVVBVVVVBBBBBYBBBB",
    "KBBBBBBVVVVVVVVVVVVBVBBBBBBBBBBBBBBBBBBYBBBBBBBB",
    "KBBBBVBVVVVVVBBVVVPVVVVVVVBBBBBBBBBBBBBBBBBBBBLB",
    "KVVVVVVVVVVPVVVVVVVVVVVVVVBBBBVVBBBBBBBBBBBBOBdd",
    "KVVVVVVVVVPVVVPPVPVVVVVVBBBBBBBBBBBBBVBBVVVBVddO",
    "XVVVVVVVVVVVVPVVVVVVVVBVVVVVVBBBBBVVVBVVBVVVddVd",
    "KVVVVVVVVVVVVVVVVVVVVVVVVBVVVVVVVVVBVVVVVVVVdOVV",
    ".PPVPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP."
  ];

  final size = 48;
  final List<List<String>> grid = rawDolphin.map((r) => r.split('')).toList();

  // 1. Clean left/right white borders (K = White)
  for (int y = 0; y < size; y++) {
    if (grid[y][0] == 'K') {
      grid[y][0] = grid[y][1];
    }
    if (grid[y][size - 1] == 'K') {
      grid[y][size - 1] = grid[y][size - 2];
    }
  }

  // 2. Merge L (black outline) to O (slate grey)
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      if (grid[y][x] == 'L') {
        grid[y][x] = 'O';
      }
    }
  }

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

  final bgColors = {'J', 'e', 'd', 'Y', 'B', 'V'};
  final fgColors = ['K', 'O', 'P', 'X', 'p', 'U'];

  // Balance foreground colors first
  for (final char in fgColors) {
    int count = countChar(char);
    if (count == 0) continue;
    int rem = count % 5;
    if (rem == 0) continue;

    if (rem < 3) {
      int diff = rem;
      int removedCount = 0;
      for (int y = 0; y < size && removedCount < diff; y++) {
        for (int x = 0; x < size && removedCount < diff; x++) {
          if (grid[y][x] == char) {
            for (final n in getNeighbors(y, x)) {
              final ny = n[0];
              final nx = n[1];
              final nc = grid[ny][nx];
              if (bgColors.contains(nc)) {
                grid[y][x] = nc;
                removedCount++;
                break;
              }
            }
          }
        }
      }
    } else {
      int diff = 5 - rem;
      int addedCount = 0;
      for (int y = 0; y < size && addedCount < diff; y++) {
        for (int x = 0; x < size && addedCount < diff; x++) {
          if (grid[y][x] == char) {
            for (final n in getNeighbors(y, x)) {
              final ny = n[0];
              final nx = n[1];
              final nc = grid[ny][nx];
              if (bgColors.contains(nc)) {
                grid[ny][nx] = char;
                addedCount++;
                if (addedCount == diff) break;
              }
            }
          }
        }
      }
    }
  }

  // Sequential balance of backgrounds
  final bgList = ['J', 'e', 'd', 'Y', 'B'];
  final bgNext = {
    'J': 'e',
    'e': 'd',
    'd': 'Y',
    'Y': 'B',
    'B': 'V',
  };

  for (final char in bgList) {
    int count = countChar(char);
    int rem = count % 5;
    if (rem == 0) continue;

    final nextChar = bgNext[char]!;
    if (rem < 3) {
      int diff = rem;
      int converted = 0;
      for (int y = 0; y < size && converted < diff; y++) {
        for (int x = 0; x < size && converted < diff; x++) {
          if (grid[y][x] == char) {
            for (final n in getNeighbors(y, x)) {
              final ny = n[0];
              final nx = n[1];
              if (grid[ny][nx] == nextChar) {
                grid[y][x] = nextChar;
                converted++;
                break;
              }
            }
          }
        }
      }
    } else {
      int diff = 5 - rem;
      int converted = 0;
      for (int y = 0; y < size && converted < diff; y++) {
        for (int x = 0; x < size && converted < diff; x++) {
          if (grid[y][x] == nextChar) {
            for (final n in getNeighbors(y, x)) {
              final ny = n[0];
              final nx = n[1];
              if (grid[ny][nx] == char) {
                grid[y][x] = char;
                converted++;
                break;
              }
            }
          }
        }
      }
    }
  }

  print('\nDolphin balanced.');

  print('=== BALANCED DOLPHIN GRID ===');
  for (final row in grid) {
    print('    "${row.join('')}",');
  }

  print('\n=== BALANCED DOLPHIN COLORS ===');
  final allDolphinChars = ['K', 'O', 'P', 'X', 'p', 'U', 'J', 'e', 'd', 'Y', 'B', 'V'];
  int total = 0;
  for (final char in allDolphinChars) {
    int count = countChar(char);
    print('$char: $count');
    total += count;
  }
  print('Total: $total (should be 2300)');
}
