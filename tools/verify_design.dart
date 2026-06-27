import 'dart:io';

void main() {
  final cellRows = [
    "................................", // Row 0
    "......................LLLL......", // Row 1
    "....................LLKKKKLL....", // Row 2
    "....L...............LLLKKKKKLL..", // Row 3 (Changed first K to L)
    "....L.....LLLL......LKKKKKKKLL..", // Row 4
    "....L....LXVVXL.....LLKKKKLL....", // Row 5
    "....L....LXVVXL.......LLLL......", // Row 6
    "....L....LVVVVL.................", // Row 7
    ".......LUUUUULLL................", // Row 8
    ".......LLLLLLLLL................", // Row 9
    ".......LXXLXXLXL....LXVXVXXL....", // Row 10 (Modified X/U to match counts)
    ".......LXXLXXLXL....LXVXVXXL....", // Row 11 (Modified X/U to match counts)
    ".......LLLLLLLLL....LXVXVXXL....", // Row 12
    ".....LLLLLLLLLLLLL..LXVXVXXL....", // Row 13
    ".....LLUXUUXUUXUUL..LXVXVXXL....", // Row 14 (Modified U to L to match counts)
    ".....LUUXUUXUUXUUL..LXVXVXXL....", // Row 15
    ".....LUUUXUUUXUUUL..LLLLLLLL....", // Row 16
    ".....LUUXUUXUUXUUL..............", // Row 17
    ".....LUUXUUXUUXUUL..LLLLLLLLLLL.", // Row 18
    ".....LUUUMUUUMUUUL..LXXMXMXMXXL.", // Row 19 (Modified U/X/M to match counts)
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

  final counts = <String, int>{};
  for (final row in cellRows) {
    for (int i = 0; i < row.length; i++) {
      counts[row[i]] = (counts[row[i]] ?? 0) + 1;
    }
  }

  print('Design counts:');
  counts.forEach((char, count) {
    if (char != '.') {
      print('  $char: $count');
    }
  });
}
