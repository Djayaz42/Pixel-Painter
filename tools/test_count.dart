void main() {
  final grid = [
    "................................",
    "......................LLLL......",
    "....................LLKKKKLL....",
    "....L...............LLLLKKKKLL..",
    "....L.....LLLL......LKKKKKKKLL..",
    "....L....LXVVXL.....LLKKKKLL....",
    "....L....LXVVXL.......LLLL......",
    "....L....LVVVVL.................",
    ".......LLLLLLLLL................",
    ".......LLLLLLLLL................",
    ".......LXXUXXUXL....LXVXVXXL....",
    ".......LXXUXXUXL....LXVXVXXL....",
    ".......LLLLLLLLL....LXVXVXXL....",
    ".....LLLLLLLLLLLLL..LXVXVXXL....",
    ".....LUUXUUXUUXUUL..LXVXVXXL....",
    ".....LUUXUUXUUXUUL..LXVXVXXL....",
    ".....LUUUXUUUXUUUL..LLLLLLLL....",
    ".....LUUXUUXUUXUUL..............",
    ".....LUUXUUXUUXUUL..LLLLLLLLLLL.",
    ".....LUUUXUUUXUUUL..LXXMXMXMXXL.",
    "LLLLLLUUXUUXUUXUULLLLXXMXMXMXXL.",
    "LXXLXXLLLLLLLLLLLLLMMMMMMMMMMML.",
    "LXXLXXLUUXUUXUUXUULXXMXMXMXXLLL.",
    "LXXLXXLUUXUUXUUXUULXXMXMXMXXLXXL",
    "LLLLLLLUUUXUUUXUUULMMMMMMMMMLXXL",
    "LXXLXXLUUXUUXUUXUULXXMXMXMXXLXXL",
    "LXXLXXLUUXUUXUUXUULXXMXMXMXXLLLL",
    "LXXLXXLLLLLLLLLLLLLMMMMMMMMMLXXL",
    "LLLLLLLUUXUUXUUXUULXXMXMXMXXLXXL",
    "LMMMMMLUUXUUXUUXUULXXMXMXMXXLXXL",
    "LMMMMMLLLLLLLLLLLLLMMMMMMMMMLLLL",
    "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL",
  ];

  int countK = 0;
  for (final row in grid) {
    for (int i = 0; i < row.length; i++) {
      if (row[i] == 'K') countK++;
    }
  }
  print('Count of K in grid: $countK');
}
