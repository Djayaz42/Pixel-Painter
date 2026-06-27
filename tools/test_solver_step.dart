void main() {
  final cellRows = [
    "................................", // Row 0
    "......................LLLL......", // Row 1
    "....................LLKKKKLL....", // Row 2
    "....L...............LLKKKKKKLL..", // Row 3
    "....L.....LLLL......LKKKKKKKLL..", // Row 4
    "....L....LXVVXL.....LLKKKKLL....", // Row 5
    "....L....LXVVXL.......LLLL......", // Row 6
    "....L....LVVVVL.................", // Row 7
    ".......LLLLLLLLL................", // Row 8
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

  List<List<String>> grid = cellRows.map((r) => r.split('')).toList();

  int kToL = 1;
  int xToU = 1;
  int xToM = 2;
  int uToL = 6;

  // Apply K to L:
  int countK = 0;
  for (int r = 2; r <= 5 && countK < kToL; r++) {
    for (int c = 0; c < 32 && countK < kToL; c++) {
      if (grid[r][c] == 'K') {
        print('Changing K to L at Row $r, Col $c');
        grid[r][c] = 'L';
        countK++;
      }
    }
  }

  // Apply xToU:
  int countXU = 0;
  for (int r = 9; r < 30 && countXU < xToU; r++) {
    for (int c = 0; c < 32 && countXU < xToU; c++) {
      if (grid[r][c] == 'X') {
        print('Changing X to U at Row $r, Col $c');
        grid[r][c] = 'U';
        countXU++;
      }
    }
  }

  // Apply xToM:
  int countXM = 0;
  for (int r = 19; r < 32 && countXM < xToM; r++) {
    for (int c = 0; c < 32 && countXM < xToM; c++) {
      if (grid[r][c] == 'X') {
        print('Changing X to M at Row $r, Col $c');
        grid[r][c] = 'M';
        countXM++;
      }
    }
  }

  // Apply uToL:
  int countUL = 0;
  for (int r = 9; r < 32 && countUL < uToL; r++) {
    for (int c = 0; c < 32 && countUL < uToL; c++) {
      if (grid[r][c] == 'U') {
        print('Changing U to L at Row $r, Col $c');
        grid[r][c] = 'L';
        countUL++;
      }
    }
  }

  final counts = <String, int>{};
  for (final row in grid) {
    for (final char in row) {
      counts[char] = (counts[char] ?? 0) + 1;
    }
  }

  print('\nRESULTING GRID:');
  for (final row in grid) {
    print('        "${row.join("")}",');
  }

  print('\nCounts:');
  counts.forEach((char, count) {
    if (char != '.') {
      print('  $char: $count');
    }
  });
}
