import 'dart:io';

void main() {
  final cellRows = [
    "................................", // Row 0
    "......................LLLL......", // Row 1
    "....................LLKKKKLL....", // Row 2
    "....L...............LLLLKKKKLL..", // Row 3
    "....L.....LLLL......LKKKKKKKLL..", // Row 4
    "....L....LXVVXL.....LLKKKKLL....", // Row 5
    "....L....LXVVXL.......LLLL......", // Row 6
    "....L....LVVVVL.................", // Row 7
    ".......LUUUUULLL................", // Row 8
    ".......LLLLLLLLL................", // Row 9
    ".......LXXUXXUXL....LXVXVXXL....", // Row 10
    ".......LXXUXXUXL....LXVXVXXL....", // Row 11
    ".......LLLLLLLLL....LXVXVXXL....", // Row 12
    ".....LLLLLLLLLLLLL..LXVXVXXL....", // Row 13
    ".....LUUXUUXUUXUUL..LXVXVXXL....", // Row 14
    ".....LUUXUUXUUXUUL..LXVXVXXL....", // Row 15
    ".....LUUUXUUUXUUUL..LLLLLLLL....", // Row 16
    ".....LUUXUUXUUXUUL..............", // Row 17
    ".....LUUXUUXUUXUUL..LLLLLLLLLLL.", // Row 18
    ".....LUUUXUUUXUUUL..LXXMXMXMXXL.", // Row 19
    "LLLLLLUUXUUXUUXUULLLLXXMXMXMXXL.", // Row 20
    "LXXLXXLLLLLLLLLLLLLMMMMMMMMMMML.", // Row 21
    "LXXLXXLUUXUUXUUXUULXXMXMXMXXLLL.", // Row 22
    "LXXLXXLUUXUUXUUXUULXXMXMXMXXLXXL", // Row 23
    "LLLLLLLUUUXUUUXUUULMMMMMMMMMLXXL", // Row 24
    "LXXLXXLUUXUUXUUXUULXXMXMXMXXLXXL", // Row 25
    "LXXLXXLUUXUUXUUXUULXXMXMXMXXLLLL", // Row 26
    "LXXLXXLLLLLLLLLLLLLMMMMMMMMMLXXL", // Row 27
    "LLLLLLLUUXUUXUUXUULXXMXMXMXXLXXL", // Row 28
    "LMMMMMLUUXUUXUUXUULXXMXMXMXXLXXL", // Row 29
    "LMMMMMLLLLLLLLLLLLLMMMMMMMMMLLLL", // Row 30
    "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL", // Row 31
  ];

  // We want:
  // L: 265
  // K: 20
  // X: 165
  // V: 20
  // U: 125
  // M: 70
  
  // Let's search for coordinate changes:
  // Since we want K to be 20 (currently 19), we need to change one L to K.
  // Since we want M to be 70 (currently 72), we need to change two M to X.
  // Since we want L to be 265 (currently 270), and we changed one L to K, we have 269.
  // We need to change four L to other characters (like U or X).
  // Let's write a solver that checks combinations of replacements:
  
  final coordsOf = <String, List<List<int>>>{};
  for (final char in ['.', 'L', 'K', 'X', 'V', 'U', 'M']) {
    coordsOf[char] = [];
  }

  for (int r = 0; r < 32; r++) {
    for (int c = 0; c < 32; c++) {
      final ch = cellRows[r][c];
      coordsOf[ch]!.add([r, c]);
    }
  }

  // Let's search over:
  // 1. One L to K (Row 3, col 23):
  // 2. Two M to X (inner center building)
  // 3. Some L's to U's or X's.
  // Let's try to change:
  // - lToK: 1 (at [3, 23])
  // - mToX: 2 (change 2 M's to X's)
  // - lToU: 5 (change 5 L's to U's)
  // - uToX: 4 (change 4 U's to X's)
  // Let's verify if this balances:
  // L: 270 - 1 (to K) - 5 (to U) = 264. Wait, we want 265.
  // Let's write a search loop to find the exact combination!
  
  for (int lToK = 1; lToK <= 1; lToK++) {
  for (int mToX = 0; mToX <= 5; mToX++) {
  for (int mToU = 0; mToU <= 5; mToU++) {
  for (int mToL = 0; mToL <= 5; mToL++) {
  for (int uToX = 0; uToX <= 10; uToX++) {
  for (int uToL = 0; uToL <= 10; uToL++) {
  for (int lToX = 0; lToX <= 10; lToX++) {
  for (int lToU = 0; lToU <= 10; lToU++) {
  for (int xToL = 0; xToL <= 10; xToL++) {
  for (int xToU = 0; xToU <= 10; xToU++) {
    
    int deltaL = -lToK - lToX - lToU + mToL + uToL + xToL;
    int deltaK = lToK;
    int deltaM = -mToX - mToU - mToL;
    int deltaU = -uToX - uToL + mToU + lToU + xToU;
    int deltaX = -xToL - xToU + mToX + uToX + lToX;

    if (270 + deltaL == 265 &&
        19 + deltaK == 20 &&
        72 + deltaM == 70 &&
        124 + deltaU == 125 &&
        161 + deltaX == 165) {
      
      print('FOUND SUCCESSFUL DESIGN COMBO!');
      print('  lToK: $lToK, mToX: $mToX, mToU: $mToU, mToL: $mToL');
      print('  uToX: $uToX, uToL: $uToL, lToX: $lToX, lToU: $lToU');
      print('  xToL: $xToL, xToU: $xToU');
      
      // Let's apply:
      List<List<String>> grid = cellRows.map((r) => r.split('')).toList();
      
      // 1. lToK at Row 3, col 23
      grid[3][23] = 'K';
      
      // 2. mToX: change M to X
      int countMX = 0;
      for (final coord in coordsOf['M']!) {
        if (countMX >= mToX) break;
        // Avoid outer columns
        if (coord[1] > 20 && coord[1] < 30 && coord[0] > 18 && coord[0] < 30) {
          grid[coord[0]][coord[1]] = 'X';
          countMX++;
        }
      }

      // 3. mToU: change M to U
      int countMU = 0;
      for (final coord in coordsOf['M']!) {
        if (grid[coord[0]][coord[1]] == 'M' && countMU < mToU) {
          if (coord[1] > 20 && coord[1] < 30) {
            grid[coord[0]][coord[1]] = 'U';
            countMU++;
          }
        }
      }

      // 4. uToL: change U to L
      int countUL = 0;
      for (final coord in coordsOf['U']!) {
        if (countUL >= uToL) break;
        if (coord[1] > 0 && coord[1] < 31) {
          grid[coord[0]][coord[1]] = 'L';
          countUL++;
        }
      }

      // 5. lToU: change L to U
      int countLU = 0;
      for (final coord in coordsOf['L']!) {
        if (countLU >= lToU) break;
        // Modify roof/floor outlines of the skyscraper (Row 18, Row 16, Row 13)
        if (coord[1] > 5 && coord[1] < 18 && (coord[0] == 13 || coord[0] == 16 || coord[0] == 18)) {
          grid[coord[0]][coord[1]] = 'U';
          countLU++;
        }
      }

      // 6. xToU: change X to U
      int countXU = 0;
      for (final coord in coordsOf['X']!) {
        if (grid[coord[0]][coord[1]] == 'X' && countXU < xToU) {
          if (coord[1] > 5 && coord[1] < 18) {
            grid[coord[0]][coord[1]] = 'U';
            countXU++;
          }
        }
      }

      final finalCounts = <String, int>{};
      for (final row in grid) {
        for (final char in row) {
          finalCounts[char] = (finalCounts[char] ?? 0) + 1;
        }
      }

      print('\nRESULTING GRID:');
      for (final row in grid) {
        print('        "${row.join("")}",');
      }

      print('\nCounts:');
      finalCounts.forEach((char, cnt) {
        if (char != '.') {
          print('  $char: $cnt');
        }
      });
      return;
    }
  }
  }
  }
  }
  }
  }
  }
  }
  }
  }
}
