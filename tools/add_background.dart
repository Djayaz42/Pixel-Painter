import 'dart:io';

void main() {
  final List<String> originalGrid = [
    "................................................",
    "....................LLLLLLLL....................",
    "...................LLLLLLLLLLL..................",
    "..................LLLLLLLLLLLLL.................",
    ".................LLLLLLLLLLLLLL.................",
    ".................LLKKKLLLLKKKLLL................",
    "................LLKKKKKLLKKKKKLL................",
    "................LLKKKKKLLKKKKKKL................",
    "................LKKKLKKKLKKLSKKLL...............",
    "................LKKKLKKKLKKLLKKLL...............",
    "................LKKKKKKFFFKKKKKLL...............",
    "...............LLKKKKFFFFFFKKKKLL...............",
    "...............BLKKKKKFFFFKKKKKLBB..............",
    "..............KBBBBKKKKKKKBBQBBBBB..............",
    "...............BBBBBBBBBBBQBBQBQBQ..............",
    "..............BQQBBBBBBBBBBBBQBBBB..............",
    "..............BBBBBQQBBBBBBQBBBBQBB.............",
    "..............LBBBBBBBBBBBBQBBBBQB..............",
    "..............LLLBBBBBBBBBBQBBBBBLL.............",
    ".............LLLLLSSSSMMMMSSBBBBBLL.............",
    ".............LLLLLKKKKKKKKKSBBBBBLLL............",
    "............LLLLLKKKKKKKKKKSBBBBBLLLS...........",
    "...........LLLLLLKKKKKKKKKKSBBBBBLLLL...........",
    "...........LLLLLSKKKKKKKKKKSBBBBBLLLLL..........",
    "..........LLLLLLKKKKKKKKKKKSBBBBBLLLLLL.........",
    ".........LLLLLLLKKKKKKKKKKKBBBBBBLLLLLL.........",
    "........LLLLLLLLKKKKKKKKKKKBBBBBBLLLLLLL........",
    ".......LLLLLLLLLKKKKKKKKKKKBBBBBBLLLLLLLL.......",
    "......MLLLLLLLLLKKKKKKKKKKKBBBBBBLLLLLLLLL......",
    ".....SLLLLLLLLLLKKKKKKKKKKKBBBBBBBLLLLLLLLL.....",
    "....MLLLLLL.LLLLKKKKKKKKKKKBBBBBBBLLMLLLLLLL....",
    "...MLLLLLL..LLLLKKKKKKKKKKKSBBBBBBBLM..LLLLLL...",
    "...LLLLM....LLLLKKKKKKKKKKKSBBBBBBBL.....LLLLL..",
    "............LLLLKKKKKKKKKKKSSSSSSLLL............",
    "............LLLLKKKKKKKKKKKKSKKKLLLL............",
    ".............LLLLKKKKKKKKKKKKKKKLLLL............",
    ".............LLLLKKKKKKKKKKKKKKMLLL.............",
    ".............LLLLMKKKKKKKKKKKKKLLLL.............",
    "..............LLLLKKKKKKKKKKKKLLLLS.............",
    "...............LLLLKKKKKKKKKKLLLLL..............",
    "...............LLLLLMKKKKKKKLLLLL...............",
    "................MLLLLLLSKLLLLLLL................",
    ".................FLLLLLLLLLLLLL.................",
    "................FFFFLLLLLLLLLFFFF...............",
    "..............SFFFFFFF....FFFFFFFF..............",
    "...............SFFFFFF....FFFFFFFS..............",
    "................................................",
    "................................................"
  ];

  // We want to replace '.' with background characters 'J', 'X', 'T'
  // But leave some as '.' to satisfy the multiple of 5 rule.
  // J target: 580 (raw: 583)
  // X target: 290 (raw: 290)
  // T target: 440 (raw: 445)
  // Dots target: 9 (top corners, bottom corners, maybe some on edges)
  
  // Let's define the placement of J, X, T, and . row by row:
  final List<String> modifiedGrid = [];
  int jCount = 0;
  int xCount = 0;
  int tCount = 0;
  int dotCount = 0;

  for (int y = 0; y < originalGrid.length; y++) {
    final row = originalGrid[y];
    final sb = StringBuffer();
    for (int x = 0; x < row.length; x++) {
      final char = row[x];
      if (char == '.') {
        // Let's decide which color to place
        String bgChar;
        if (y < 18) {
          bgChar = 'J';
        } else if (y < 34) {
          bgChar = 'X';
        } else {
          bgChar = 'T';
        }

        // We need to reduce J from 583 to 580 (need 3 dots)
        // We need to reduce T from 445 to 440 (need 5 dots)
        // X is already 290 (need 0 dots)
        // Total dots = 3 + 5 = 8 dots!
        
        // Let's place dots at specific symmetric positions:
        // For J: Top-Left [0,0], Top-Right [0,47], and one in the middle [0, 24]
        if (y == 0 && (x == 0 || x == 47 || x == 24)) {
          bgChar = '.';
          dotCount++;
        }
        // For T: Bottom-Left [47,0], Bottom-Right [47,47], [47, 24], [46, 0], [46, 47]
        else if ((y == 47 && (x == 0 || x == 47 || x == 24)) ||
                 (y == 46 && (x == 0 || x == 47))) {
          bgChar = '.';
          dotCount++;
        } else {
          if (bgChar == 'J') jCount++;
          if (bgChar == 'X') xCount++;
          if (bgChar == 'T') tCount++;
        }
        sb.write(bgChar);
      } else {
        sb.write(char);
      }
    }
    modifiedGrid.add(sb.toString());
  }

  print('=== Modified Grid ===');
  for (final row in modifiedGrid) {
    print('    "$row",');
  }

  print('\n=== Background Counts ===');
  print('J: $jCount (mod 5 = ${jCount % 5})');
  print('X: $xCount (mod 5 = ${xCount % 5})');
  print('T: $tCount (mod 5 = ${tCount % 5})');
  print('Dots: $dotCount');
}
