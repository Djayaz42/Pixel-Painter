import 'dart:io';

void main() {
  // Validate all templates are exactly 16x16
  bool hasErrors = false;
  for (int i = 0; i < animalTemplates.length; i++) {
    if (animalTemplates[i].length != 16) {
      print('Animal ${i+1} (${animalNames[i]}) has ${animalTemplates[i].length} rows instead of 16!');
      hasErrors = true;
    }
    for (int r = 0; r < animalTemplates[i].length; r++) {
      if (animalTemplates[i][r].length != 16) {
        print('Animal ${i+1} (${animalNames[i]}), row $r has length ${animalTemplates[i][r].length} instead of 16! Content: "${animalTemplates[i][r]}"');
        hasErrors = true;
      }
    }
  }
  for (int i = 0; i < objectTemplates.length; i++) {
    // Star is 25x25, Donut/IceCream/Cookie/Cupcake/Mushroom/Carrot/Pineapple/Burger are 48x48, others are 24x24 or 16x16
    int expectedSize = (i == 0) ? 25 : (i == 7 || i == 8 || i == 9 || i == 10 || i == 11 || i == 12 || i == 13 || i == 14 || i == 15 || i == 16 || i == 17 || i == 18 || i == 19 || i == 20 || i == 21 || i == 22 || i == 23 || i == 24) ? 48 : (i == 2 || i == 3 || i == 4 || i == 5 || i == 6) ? 24 : 16;
    if (objectTemplates[i].length != expectedSize) {
      print('Object ${i+51} (${objectNames[i]}) has ${objectTemplates[i].length} rows instead of $expectedSize!');
      hasErrors = true;
    }
    for (int r = 0; r < objectTemplates[i].length; r++) {
      if (objectTemplates[i][r].length != expectedSize) {
        print('Object ${i+51} (${objectNames[i]}), row $r has length ${objectTemplates[i][r].length} instead of $expectedSize! Content: "${objectTemplates[i][r]}"');
        hasErrors = true;
      }
    }
  }
  if (hasErrors) {
    print('Validation failed. Please fix the templates.');
    exit(1);
  }

  final headerFile = File('header.txt');
  final headerContent = headerFile.readAsStringSync();
  
  StringBuffer sb = StringBuffer();
  sb.writeln(headerContent);
  sb.writeln('  static List<LevelDefinition> get levels => [');
  for (int i = 1; i <= 100; i++) {
    sb.writeln('    _level${i}(),');
  }
  sb.writeln('  ];');
  sb.writeln();
  sb.writeln('  static LevelDefinition levelAt(int index) {');
  sb.writeln('    if (index < 0 || index >= levels.length) return levels.last;');
  sb.writeln('    return levels[index];');
  sb.writeln('  }');
  sb.writeln();
  sb.writeln('  static Iterable<PaintCartridge> cartridgesForLevel(int index) {');
  sb.writeln('    final level = levelAt(index);');
  sb.writeln('    final colorIds = level.colorRuns.map((r) => r.colorId).toSet();');
  sb.writeln('    return cartridges.where((c) => colorIds.contains(c.colorId));');
  sb.writeln('  }');
  sb.writeln();
  
  // Color mapping logic from LevelData
  Map<String, int> charToColor = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8, 'I': 9, 'J': 10,
    'K': 11, 'L': 12, 'M': 13, 'N': 14, 'O': 15, 'P': 16, 'Q': 17, 'R': 18, 'S': 19,
    'T': 20, 'U': 21, 'V': 22, 'W': 23, 'X': 24, 'Y': 25, 'Z': 26, 'a': 27, 'b': 28,
    'c': 29, 'd': 30, 'e': 31, 'f': 32, 'g': 33, 'h': 34, 'i': 35, 'j': 36, 'k': 37,
    'l': 38, 'm': 39, 'n': 40, 'o': 41, 'p': 42, 'q': 43, 'r': 44, 's': 45, 't': 46,
    'u': 47,
    'v': 48,
    'w': 49,
    'x': 50,
    'y': 51,
    'z': 52,
    '0': 53,
    '1': 54,
    '2': 55,
    '3': 56,
    '4': 57,
    '5': 58,
    '6': 59,
    '7': 60,
    '8': 61,
    '9': 62,
    '-': 63,
    '+': 64,
    '=': 65,
    '*': 66,
    '#': 67,
    '{': 68,
    '}': 69,
    '[': 70,
    ']': 71,
    '<': 72,
    '>': 73,
    '(': 74,
    ')': 75,
    '_': 76,
    '?': 77,
    '!': 78,
    '&': 79,
    '^': 80,
    '%': 81,
    '\$': 82,
    '@': 83,
    '~': 84,
    '|': 85,
    '/': 86,
    ':': 87,
    ';': 88,
    ',': 89,
    '`': 90,
    '\\': 91,
    '"': 92,
    '\'': 93,
    '§': 94,
    '°': 95,
    '©': 96,
    '®': 97,
    'µ': 98,
    '¶': 99,
    '¿': 100,
    'Ç': 101,
    'É': 102,
    'Í': 103,
    'Î': 104,
    'á': 105,
    'à': 106,
    'â': 107,
    'ä': 108,
    'ã': 109,
    'å': 110,
    'æ': 111,
    'ç': 112,
    'è': 113,
    'é': 114,
    'ê': 115,
    'ë': 116,
    'ì': 117,
    'í': 118,
    'ò': 119,
    'ó': 120,
    'ô': 121,
    'õ': 122,
    'ö': 123,
    'ø': 124,
    'ù': 125,
    'ú': 126,
    'û': 127,
    'ü': 128,
    'ý': 129,
    'þ': 130,
    'ÿ': 131,
    'ć': 132,
    'ĉ': 133,
    'ċ': 134,
    '£': 135,
    '¥': 136,
    '¢': 137,
    '¤': 138,
    'ª': 139,
    'º': 140,
    '«': 141,
    '»': 142,
    '±': 143,
    '²': 144,
    '³': 145,
    '¼': 146,
    '½': 147,
    '¾': 148,
    '×': 149,
    '÷': 150,
    'Ø': 151,
    'Þ': 152,
    'Ý': 153,
    'ß': 154,
    'Đ': 155,
  };

  // Generate 100 levels
  for (int i = 1; i <= 100; i++) {
    int gridSize = 16;
    String name = "";
    List<String> baseTemplate = [];
    
    // Difficulty curve
    if (i == 1) {
      gridSize = 25; // Tutorial Star (Yüksek Boyut)
    } else if (i == 3) {
      gridSize = 48; // Apple (48x48)
    } else if (i == 4) {
      gridSize = 48; // Banana (48x48)
    } else if (i == 5) {
      gridSize = 48; // Orange (48x48)
    } else if (i == 6) {
      gridSize = 48; // Watermelon (48x48)
    } else if (i == 7) {
      gridSize = 48; // Strawberry (48x48)
    } else if (i == 8) {
      gridSize = 48; // Pineapple (48x48)
    } else if (i == 9) {
      gridSize = 48; // Carrot (48x48)
    } else if (i == 10) {
      gridSize = 48; // Mushroom (48x48)
    } else if (i == 11) {
      gridSize = 48; // Cupcake (48x48)
    } else if (i == 12) {
      gridSize = 48; // Cookie (48x48)
    } else if (i == 13) {
      gridSize = 48; // Donat (48x48)
    } else if (i == 14) {
      gridSize = 48; // Dondurma (48x48)
    } else if (i == 15) {
      gridSize = 48; // Burger (48x48)
    } else if (i == 16) {
      gridSize = 48; // Pizzadilimi (48x48)
    } else if (i == 17) {
      gridSize = 48; // Kupa (48x48)
    } else if (i == 18) {
      gridSize = 48; // Anahtar (48x48)
    } else if (i == 19) {
      gridSize = 48; // Kilit (48x48)
    } else if (i == 20) {
      gridSize = 48; // Sandik (48x48)
    } else if (i == 21) {
      gridSize = 48; // Kalkan (48x48)
    } else if (i == 22) {
      gridSize = 48; // Kilic (48x48)
    } else if (i == 23) {
      gridSize = 48; // Yuzuk (48x48)
    } else if (i == 24) {
      gridSize = 48; // Tac (48x48)
    } else if (i <= 5) {
      gridSize = 16; // Tutorial (Komut/Kolay)
    } else if (i <= 10) {
      if (i <= 7) gridSize = 16; // Kolay
      else if (i <= 9) gridSize = 24; // Orta
      else gridSize = 32; // Zor
    } else {
      int cycleIndex = (i - 11) % 23;
      if (cycleIndex < 5) { // 0-4: E E M H VH
        if (cycleIndex < 2) gridSize = 16;
        else if (cycleIndex == 2) gridSize = 24;
        else if (cycleIndex == 3) gridSize = 32;
        else gridSize = 48;
      } else if (cycleIndex < 11) { // 5-10: E E M H H VH
        int idx = cycleIndex - 5;
        if (idx < 2) gridSize = 16;
        else if (idx == 2) gridSize = 24;
        else if (idx <= 4) gridSize = 32;
        else gridSize = 48;
      } else if (cycleIndex < 16) { // 11-15: E M M H VH
        int idx = cycleIndex - 11;
        if (idx == 0) gridSize = 16;
        else if (idx <= 2) gridSize = 24;
        else if (idx == 3) gridSize = 32;
        else gridSize = 48;
      } else { // 16-22: E E M M H VH VH
        int idx = cycleIndex - 16;
        if (idx <= 1) gridSize = 16;
        else if (idx <= 3) gridSize = 24;
        else if (idx == 4) gridSize = 32;
        else gridSize = 48;
      }
    }

    if (i <= 50) {
      // Object theme
      name = objectNames[i - 1];
      baseTemplate = objectTemplates[i - 1];
    } else {
      // Animal theme
      name = animalNames[i - 51];
      baseTemplate = animalTemplates[i - 51];
    }
    
    print('Scaling level $i, name: $name');
    List<String> scaledGrid = scaleGrid(baseTemplate, gridSize);
    scaledGrid = adjustColorCounts(scaledGrid, charToColor);
    
    Map<int, int> colorCounts = {};
    for (String row in scaledGrid) {
      for (int k = 0; k < row.length; k++) {
        String char = row[k];
        if (charToColor.containsKey(char)) {
          int colorId = charToColor[char]!;
          colorCounts[colorId] = (colorCounts[colorId] ?? 0) + 1;
        }
      }
    }
    
    sb.writeln('  static LevelDefinition _level${i}() {');
    sb.writeln('    return LevelDefinition(');
    sb.writeln("      name: '${name}',");
    sb.writeln('      rows: [],');
    sb.writeln('      cellRows: const [');
    for (String line in scaledGrid) {
      // Wrap line in double quotes for Dart string array
      final escapedLine = line
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll('\$', '\\\$');
      sb.writeln('        "${escapedLine}",');
    }
    sb.writeln('      ],');
    sb.writeln('      gridRows: ${gridSize},');
    sb.writeln('      gridCols: ${gridSize},');
    sb.writeln('      colorRuns: const [');
    if (i == 16) {
      final pizzaOrder = [103, 104, 11, 100, 42, 47, 93, 97];
      for (int colorId in pizzaOrder) {
        if (colorCounts.containsKey(colorId) && colorCounts[colorId]! > 0) {
          sb.writeln('        LevelColorRun(${colorId}, ${colorCounts[colorId]}),');
        }
      }
    } else {
      for (var entry in colorCounts.entries) {
        if (entry.value > 0) {
          sb.writeln('        LevelColorRun(${entry.key}, ${entry.value}),');
        }
      }
    }
    sb.writeln('      ],');
    sb.writeln('      paintOrder: LevelPaintOrder.rowSnake,');
    sb.writeln('    );');
    sb.writeln('  }');
    sb.writeln();
  }

  sb.writeln('}'); // Close LevelData class
  
  final outFile = File('../lib/models/level_data.dart');
  outFile.writeAsStringSync(sb.toString());
  print('Level data generated successfully!');
}

List<String> scaleGrid(List<String> original, int newSize) {
  int oldSize = original.length;
  List<String> scaled = [];
  for (int r = 0; r < newSize; r++) {
    int srcR = (r * oldSize) ~/ newSize;
    String srcRow = original[srcR];
    StringBuffer sb = StringBuffer();
    for (int c = 0; c < newSize; c++) {
      int srcC = (c * oldSize) ~/ newSize;
      sb.write(srcRow[srcC]);
    }
    scaled.add(sb.toString());
  }
  return scaled;
}

// ==========================================
// ANIMAL TEMPLATES (50 DISTINCT 16x16 GRIDS)
// ==========================================
final List<String> animalNames = [
  "Kedi", "Kopek", "Panda", "Kurbagha", "Domuz", "Ayi", "Tavsan", "Tilki", "Penguen", "Baykus",
  "Maymun", "Zurafa", "Fil", "Aslan", "Kaplan", "Ari", "Ugurbulu", "Kaplumbaga", "Balik", "Yengec",
  "Ahtapot", "Ordek", "Koyun", "Inek", "Fare", "Koala", "Kanguru", "Su Aygiri", "Gergedan", "Timsah",
  "Geyik", "Yarasa", "Kurt", "Yilan", "Yunus", "Balina", "Kopekbaligi", "Kelebek", "Civciv", "Sincap",
  "Deve", "Kugu", "Hamster", "Ugur Bocegi", "Baykus 2", "Kizil Tilki", "Penguen 2", "Kutup Ayisi", "Yavru Panda", "Disi Aslan"
];

final List<List<String>> animalTemplates = [
  // 1. Kedi
  [
    "................",
    ".mcm........mcl.",
    ".chnm......mFhc.",
    ".FHhnmmcmmmFhHF.",
    ".FHhhcccccchhHF.",
    ".FHhmFccccFmhHF.",
    ".FhFFFFccFFFFhF.",
    ".mFFFFFFFFFFFFm.",
    ".mFFFfFFFFFFFFm.",
    "mccFF.FFFF.FFccm",
    ".m..FLFccFLF..m.",
    "mnF.FFFFFFFF.Fnm",
    ".mFF.FLFFLF.FFm.",
    "...mFFFFFFFFn...",
    "....mmmmmmmm....",
    "................"
  ],
  // 2. Kopek
  [
    "................",
    "................",
    "................",
    "..Mklkmmmmkklt..",
    ".gkkkmmmmmmlklt.",
    ".kkklffmmmfmLkNi",
    "emkLlLNmmlLlLklu",
    "LkkklLLllkLLlkkk",
    "Lkkkmmg.gemmlkkk",
    "ekkkmg.LL.emlkkb",
    ".ukkf..iO.eelkb.",
    "..Lgf.L.OS.pLL..",
    "....LNT..TpN....",
    ".....TttttN.....",
    "................",
    "................"
  ],
  // 3. Panda
  [
    "................",
    ".LL.........LL..",
    "LLLL.LLLLL.LLLL.",
    "LLLLL.....LLLLLL",
    "LLLi.......iLLLL",
    ".LT.........iL..",
    ".L...........L..",
    "Li.LLL...LLL.iL.",
    "LiLL.L...L.LLiL.",
    "LiLLLL...LLLLiL.",
    "LiLLL.....LLLiL.",
    "Li....LLL....iL.",
    ".Li..L.L.L..iL..",
    "..Li.......iL...",
    "...LLLLLLLLL....",
    "................"
  ],
  // 4. Kurbagha
  [
    "................",
    "...LLLL..LLLL...",
    "..sIrrI..Irrrs..",
    ".LIr..rssrr..rs.",
    ".Lr.LL.rrr..L.s.",
    ".LrT..irrri..Ts.",
    ".srrTirrrrriirL.",
    "srrrrrrrrrrrHrrs",
    "srrHHrrrrrrrAHrs",
    "srrrrrrsssrrrrrs",
    "srrrrrrrrrrrrrrs",
    ".rrrrrrrrrrrrrr.",
    ".ssrrrrrrrrrrss.",
    "..ssrrrrrrrrss..",
    "....ssssssss....",
    "................"
  ],
  // 5. Domuz
  [
    ".LLL........OLL.",
    "LHddM.LLLL..MddL",
    "LHhNuLHdHHLLhhHL",
    "LHAhHHHHHHHHhAHL",
    "LHAHHHHHHHHHHAHL",
    ".LHHHHHHHHHHHHL.",
    ".LHHHHHHHHHHHHL.",
    "LHHL.HHHHHHL.HHL",
    "LHHddhAAAAhdgHHL",
    "LHHHhALAALAhHHHL",
    "LHHHhALAALAhHHHL",
    "LHHHHhAAAAhHHHHL",
    ".LHHHHhhhhHHHHL.",
    ".LHHdHHHHHHHHHL.",
    "..LLHHHHHHHHLL..",
    "....LLLLLLLL...."
  ],
  // 6. Ayi
  [
    "................",
    "..N..........N..",
    ".NNN........NNN.",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNLLNNNNNNLLNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNKKKKNNNNNN",
    ".NNNNNKKLLKNNNN.",
    "..NNNNNKKKNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................"
  ],
  // 7. Tavsan
  [
    "....K......K....",
    "....K......K....",
    "...KK......KK...",
    "...KH......HK...",
    "..KKH......HKK..",
    "..KKH......HKK..",
    ".KKKKKKKKKKKKKK.",
    ".KKKKKKKKKKKKKK.",
    "KKKKKKKKKKKKKKKK",
    "KKKAAKKKKKKAAKKK",
    "KKKKKKKKKKKKKKKK",
    ".KKKKKKKAAKKKKK.",
    "..KKKKKKKKKKKK..",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    "................"
  ],
  // 8. Tilki
  [
    "................",
    "..F..........F..",
    "..FF........FF..",
    "..FFF......FFF..",
    ".FFFFFFFFFFFFFF.",
    ".FFFFFFFFFFFFFF.",
    "FFFLLFFFFFFLLFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFKKKKKKFFFFF",
    ".FFFFKKLLKKFFFF.",
    "..FFFKKKKKKFFF..",
    "...FFFFFFFFFF...",
    "....FFFFFFFF....",
    "......FFFF......",
    "................"
  ],
  // 9. Penguen
  [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLKKKKKKLL...",
    "..LLKKLLKKKKL...",
    "..LLKKKKKKKKL...",
    "..LKKKLLKKKKL...",
    "..LKKKKKKKKKL...",
    "..LLKKKKKKKLL...",
    "..LLKKDDDDLLLL..",
    "..LLKKKDDLLKLL..",
    "....LLLLLLLL....",
    ".....LLLLLL.....",
    "....DD....DD....",
    "................"
  ],
  // 10. Baykus
  [
    "................",
    "....N......N....",
    "....NN....NN....",
    "...NNNNNNNNNN...",
    "..NNNNNNNNNNNN..",
    ".NNKKNNNNNNKKNN.",
    ".NKKLLNNNNKKLLN.",
    ".NKKLLNNNNKKLLN.",
    ".NNKKNNNNNNKKNN.",
    ".NNNNNNDDNNNNNN.",
    "..NNNNNDDDNNNN..",
    "..NNNNNNNNNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "....DD....DD....",
    "................"
  ],
  // 11. Maymun
  [
    "................",
    "......NNNN......",
    "..N..NNNNNN..N..",
    ".NN.NNNNNNNN.NN.",
    ".NNNNNNNNNNNNNN.",
    "NNNNNNNNNNNNNNNN",
    "NNNKKKKKKKKKKNNN",
    "NNKKLLKKKKLLKKNN",
    "NNKKKKKKKKKKKKNN",
    "NNNKKKKLLKKKKNNN",
    ".NNNKKLLLLKKNNN.",
    "..NNNNKKKKNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................"
  ],
  // 12. Zurafa
  [
    "................",
    "......D..D......",
    "......DDDD......",
    ".....DDDDDD.....",
    ".....DLDDLD.....",
    ".....DDDDDD.....",
    "......DDDD......",
    "......DNDD......",
    "......DNDD......",
    "......DDDD......",
    "......DDDD......",
    "......DNDD......",
    "......DDDD......",
    "......DDDD......",
    "......DDDD......",
    "................"
  ],
  // 13. Fil
  [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMKKMMMMMMKKMMM",
    "MMMKKMMMMMMKKMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    ".....MMMMMM.....",
    "................"
  ],
  // 14. Aslan
  [
    "................",
    "..F..FFFFFF..F..",
    ".FF.FFFFFFFF.FF.",
    "FFFFFFFFFFFFFFFF",
    "FFFDFFFFFDFFFFFF",
    "FFFDLFFFDLFFFFFF",
    "FFFDDFFFFDDFFFFF",
    "FFFFFDDDDFFFFFFF",
    "FFFFFFLLFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    ".FFFFFFFFFFFLLF.",
    "..FFFFFFFFFFLF..",
    "...FFFFFFFFFF...",
    "....FFFFFFFF....",
    "......FFFF......",
    "................"
  ],
  // 15. Kaplan
  [
    "................",
    "..F..........F..",
    ".FFF........FFF.",
    "FFFFFFFFFFFFFFFF",
    "FFFLFFFLFFFLFFFF",
    "FFFLFFFFFFFLFFFF",
    "FFKLLFFFFFLLKFFF",
    "FFKKKKKKKKKKFFFF",
    "FFFLFFFLFFFLFFFF",
    "FFFFFKKLLKKFFFFF",
    ".FFFFKKKKKKFFFF.",
    "..FFFFFFFFFFFF..",
    "...FFFFFFFFFF...",
    "....FFFFFFFF....",
    "......FFFF......",
    "................"
  ],
  // 16. Ari
  [
    "................",
    "......LLLL......",
    "....LLDDDDLL....",
    "...LLDDDDDDLL...",
    "...LLLLLLLLLL...",
    "..LLDDDDDDDDLL..",
    "..LLLLLLLLLLLL..",
    "..LLDDDDDDDDLL..",
    "..LLLLLLLLLLLL..",
    "..LLDDDDDDDDLL..",
    "..LLLLLLLLLLLL..",
    "...LLDDDDDDLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 17. Ugurbulu
  [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLAALLLAALL..",
    "..LAAAAALAAAAAL.",
    "..LAAAAALAAAAAL.",
    "..LAAALLAAALLLL.",
    "..LAAAAALAAAAAL.",
    "..LAAAAALAAAAAL.",
    "..LLAALLLAALL...",
    "...LLLLLLLLLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 18. Kaplumbaga
  [
    "................",
    "......CCCC......",
    "....CCCCCCCC....",
    "...CCCCCCCCCC...",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCLLCCCCLL..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "...CCCCCCCCCC...",
    "....CCCCCCCC....",
    "......CCCC......",
    "................",
    "................"
  ],
  // 19. Balik
  [
    "................",
    "........FF......",
    "......FFFFFF....",
    "....FFFFFFFFFF..",
    "..FFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFLFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "..FFFFFFFFFFFFFF",
    "....FFFFFFFFFF..",
    "......FFFFFF....",
    "........FF......",
    "................",
    "................"
  ],
  // 20. Yengec
  [
    "................",
    "..R..........R..",
    ".RRR........RRR.",
    "RRRRR......RRRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRLLRRRRRRLLRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    ".RRRRRRRRRRRRRR.",
    "..RRRRRRRRRRRR..",
    "...RRRRRRRRRR...",
    "....RRRRRRRR....",
    "......RRRR......",
    "................"
  ],
  // 21. Ahtapot
  [
    "................",
    "......EEEE......",
    "....EEEEEEEE....",
    "...EEEEEEEEEE...",
    "..EEEEEEEEEEEE..",
    "..EEEELLEEEELL..",
    "..EEEEEEEEEEEE..",
    "..EEEEEEEEEEEE..",
    "..EEEEEEEEEEEE..",
    "..EEEEEEEEEEEE..",
    "...EEEEEEEEEE...",
    "....EEEEEEEE....",
    "...EE..EE..EE...",
    "..EE...EE...EE..",
    ".EE....EE....EE.",
    "................"
  ],
  // 22. Ordek
  [
    "................",
    "......DDDD......",
    "....DDDDDDDD....",
    "...DDDDLDDDD....",
    "...DDDDDDDDDD...",
    "....DDDDDDDD....",
    "......DDDD......",
    "...DDDDDDDDDD...",
    "..DDDDDDDDDDDD..",
    ".DDDDDDDDDDDDDD.",
    ".DDDDDDDDDDDDDD.",
    ".DDDDDDDDDDDDDD.",
    "..DDDDDDDDDDDD..",
    "...DDDDDDDDDD...",
    "....FFFFFFFF....",
    "................"
  ],
  // 23. Koyun
  [
    "................",
    "......KKKK......",
    "....KKKKKKKK....",
    "...KKKKKKKKKK...",
    "..KKKLLKKKKLLKK.",
    "..KKKKKKKKKKKKK.",
    "..KKKKKKKKKKKKK.",
    "..KKKKKKKKKKKKK.",
    "..KKKKKKKKKKKKK.",
    "..KKKKKKKKKKKKK.",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    ".....KKKKKK.....",
    ".....LL..LL.....",
    ".....LL..LL.....",
    "................"
  ],
  // 24. Inek
  [
    "................",
    "..L..........L..",
    ".LLL........LLL.",
    "LLLLLLLLLLLLLLLL",
    "LLKKKKLLKKKKLLLL",
    "LKKKKKKKKKKKKKKL",
    "KKKKKKKKKKKKKKKK",
    "KKKLLKKKKKKLLKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKLLKKKKKKKKK",
    ".KKKKLLKKKKKKKK.",
    "..KKKKKKKKKKKK..",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    "......KKKK......",
    "................"
  ],
  // 25. Fare
  [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 26. Koala
  [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMLLMMMMMMMM",
    ".MMMMMLLMMMMMMM.",
    "..MMMMLLMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 27. Kanguru
  [
    "................",
    "......N..N......",
    "......NNNN......",
    ".....NNNNNN.....",
    ".....NLDDLD.....",
    ".....NNNNNN.....",
    "......NNNN......",
    "......NNNN......",
    ".....NNNNNN.....",
    "....NNNNNNNN....",
    "....NNNNNNNN....",
    "....NNNNNNNN....",
    "....NNNNNNNN....",
    ".....NNNNNN.....",
    "......NNNN......",
    "................"
  ],
  // 28. Su Aygiri
  [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 29. Gergedan
  [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 30. Timsah
  [
    "................",
    "......CCCC......",
    "....CCCCCCCC....",
    "...CCCCCCCCCC...",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCLLCCCCLL..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "...CCCCCCCCCC...",
    "....CCCCCCCC....",
    "......CCCC......",
    "................",
    "................"
  ],
  // 31. Geyik
  [
    "....N......N....",
    "....NN....NN....",
    "....NNNNNNNN....",
    "...NNNNNNNNNN...",
    "..NNNNNNNNNNNN..",
    ".NNLLNNNNNNLLNN.",
    ".NNNNNNNNNNNNNN.",
    ".NNNNNNNNNNNNNN.",
    ".NNNNNNNNNNNNNN.",
    ".NNNNNNNLLNNNNN.",
    "..NNNNNNLLNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    ".....NNNNNN.....",
    "......NNNN......",
    "................"
  ],
  // 32. Yarasa
  [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLLLLLLLLL...",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "...LLLLLLLLLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 33. Kurt
  [
    "................",
    "..M..........M..",
    ".MMM........MMM.",
    "MMMMM......MMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMLLMMMMMMLLMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    ".MMMMMMMMMMMMMM.",
    "..MMMMMMMMMMMM..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................"
  ],
  // 34. Yilan
  [
    "................",
    "......CCCC......",
    "....CCCCCCCC....",
    "...CCCCCCCCCC...",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCLLCCCCLL..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "..CCCCCCCCCCCC..",
    "...CCCCCCCCCC...",
    "....CCCCCCCC....",
    "......CCCC......",
    "................",
    "................"
  ],
  // 35. Yunus
  [
    "................",
    "......BBBB......",
    "....BBBBBBBB....",
    "...BBBBBBBBBB...",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBLLBBBBLL..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "...BBBBBBBBCC...",
    "....BBBBBBCC....",
    "......BBCC......",
    "................",
    "................"
  ],
  // 36. Balina
  [
    "................",
    "......BBBB......",
    "....BBBBBBBB....",
    "...BBBBBBBBBB...",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBLLBBBBLL..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "..BBBBBBBBBBBB..",
    "...BBBBBBBBCC...",
    "....BBBBBBCC....",
    "......BBCC......",
    "................",
    "................"
  ],
  // 37. Kopekbaligi
  [
    "................",
    "......MMMM......",
    "....MMMMMMMM....",
    "...MMMMMMMMBB...",
    "..MMMMMMMMMMMM..",
    "..MMMMMMMMMMMM..",
    "..MMMMLLMMMMLL..",
    "..MMMMMMMMMMMM..",
    "..MMMMMMMMMMMM..",
    "..MMMMMMMMMMMM..",
    "..MMMMMMMMMMBB..",
    "...MMMMMMMMMM...",
    "....MMMMMMMM....",
    "......MMMM......",
    "................",
    "................"
  ],
  // 38. Kelebek
  [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLLLLLLLLL...",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "..LLLLLLLLLLLL..",
    "...LLLLLLLLLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 39. Civciv
  [
    "................",
    "......DDDD......",
    "....DDDDDDDD....",
    "...DDDDLDDDD....",
    "...DDDDDDDDDD...",
    "....DDDDDDDD....",
    "......DDDD......",
    "...DDDDDDDDDD...",
    "..DDDDDDDDDDDD..",
    ".DDDDDDDDDDDDDD.",
    ".DDDDDDDDDDDDDD.",
    ".DDDDDDDDDDDDDD.",
    "..DDDDDDDDDDDD..",
    "...DDDDDDDDDD...",
    "....FFFFFFFF....",
    "................"
  ],
  // 40. Sincap
  [
    "................",
    "..N..........N..",
    ".NNN........NNN.",
    "NNNNN......NNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNLLNNNNNNLLNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    ".NNNNNNNLLNNNNN.",
    "..NNNNNNLLNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................"
  ],
  // 41. Deve
  [
    "................",
    "......NNNN......",
    "....NNNNNNNN....",
    "...NNNNNNNNNN...",
    "..NNNNNNNNNNNN..",
    "..NNNNNNNNNNNN..",
    "..NNNNLLNNNNLL..",
    "..NNNNNNNNNNNN..",
    "..NNNNNNNNNNNN..",
    "..NNNNNNNNNNNN..",
    "..NNNNNNNNNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................",
    "................"
  ],
  // 42. Kugu
  [
    "................",
    "......KKKK......",
    "....KKKKKKKK....",
    "...KKKKKKKKKK...",
    "..KKKKKKKKKKKK..",
    "..KKKKKKKKKKKK..",
    "..KKKKLLKKKKLL..",
    "..KKKKKKKKKKKK..",
    "..KKKKKKKKKKKK..",
    "..KKKKKKKKKKKK..",
    "..KKKKKKKKKKKK..",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    "......KKKK......",
    "................",
    "................"
  ],
  // 43. Hamster
  [
    "................",
    "..N..........N..",
    ".NNN........NNN.",
    "NNNNN......NNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNLLNNNNNNLLNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    ".NNNNNNNLLNNNNN.",
    "..NNNNNNLLNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "......NNNN......",
    "................"
  ],
  // 44. Ugur Bocegi
  [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLAALLLAALL..",
    "..LAAAAALAAAAAL.",
    "..LAAAAALAAAAAL.",
    "..LAAALLAAALLLL.",
    "..LAAAAALAAAAAL.",
    "..LAAAAALAAAAAL.",
    "..LLAALLLAALL...",
    "...LLLLLLLLLL...",
    "....LLLLLLLL....",
    "......LLLL......",
    "................",
    "................"
  ],
  // 45. Baykus 2
  [
    "................",
    "....N......N....",
    "....NN....NN....",
    "...NNNNNNNNNN...",
    "..NNNNNNNNNNNN..",
    ".NNLLNNNNNNLLNN.",
    ".NLLLLNNNNLLLLN.",
    ".NLLLLNNNNLLLLN.",
    ".NNLLNNNNNNLLNN.",
    ".NNNNNNDDNNNNNN.",
    "..NNNNNDDDNNNN..",
    "..NNNNNNNNNNNN..",
    "...NNNNNNNNNN...",
    "....NNNNNNNN....",
    "....DD....DD....",
    "................"
  ],
  // 46. Kizil Tilki
  [
    "................",
    "..F..........F..",
    "..FF........FF..",
    "..FFF......FFF..",
    ".FFFFFFFFFFFFFF.",
    ".FFFFFFFFFFFFFF.",
    "FFFFFFFFFFFFFFFF",
    "FFFLLFFFFFFLLFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    ".FFFFFFFLLFFFFF.",
    "..FFFFFKKKFFFF..",
    "...FFFKKKKKFFF..",
    "....FKKKKKKFFF..",
    "......KKKK......",
    "................"
  ],
  // 47. Penguen 2
  [
    "................",
    "......LLLL......",
    "....LLLLLLLL....",
    "...LLLLLLLLLL...",
    "...LLKKKKKKLL...",
    "..LLKKKKKKKKL...",
    "..LLKKLLKKKKL...",
    "..LKKLLLLKKKL...",
    "..LKKKLLKKKKL...",
    "..LKKKKKKKKKL...",
    "..LLKKKKKKKLL...",
    "..LLKKKKKKKLL...",
    "....LLKKKKLL....",
    ".....LLLLLL.....",
    "....DD....DD....",
    "................"
  ],
  // 48. Kutup Ayisi
  [
    "................",
    "..K..........K..",
    ".KKK........KKK.",
    "KKKKK......KKKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKLLKKKKKKLLKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKKKKKKKKKKKK",
    ".KKKKKKKLLKKKKK.",
    "..KKKKKKLLKKKK..",
    "...KKKKKKKKKK...",
    "....KKKKKKKK....",
    "......KKKK......",
    "................"
  ],
  // 49. Yavru Panda
  [
    "................",
    "..L..........L..",
    ".LLL........LLL.",
    "LLLLL......LLLLL",
    "LLKKKKKKKKKKKKLL",
    "LKKKKKKKKKKKKKKL",
    "KKKKKKKKKKKKKKKK",
    "KKKLLKKKKKKLLKKK",
    "KKKLLKKKKKKLLKKK",
    "KKKKKKKKKKKKKKKK",
    "KKKKKKKLLKKKKKKK",
    ".KKKKKKLLKKKKKK.",
    "..KKKKKKKKKKKK..",
    "...KKKKKKKKKK...",
    ".....KKKKKK.....",
    "................"
  ],
  // 50. Disi Aslan
  [
    "................",
    "..F..FFFFFF..F..",
    ".FF.FFFFFFFF.FF.",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFLLFFFFFFLLFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    "FFFFFFFFFFFFFFFF",
    ".FFFFFFFLLFFFFF.",
    "..FFFFFFLLFFFF..",
    "...FFFFFFFFFF...",
    "....FFFFFFFF....",
    "......FFFF......",
    "................"
  ]
];

// ==========================================
// OBJECT TEMPLATES (50 DISTINCT 16x16 GRIDS)
// ==========================================
final List<String> objectNames = [
  "Yildiz", "Kalp", "Elma", "Muz", "Portakal", "Karpuz", "Cilek", "Ananas", "Havuc", "Mantar",
  "Kupkek", "Kurabiye", "Donat", "Dondurma", "Burger", "Pizzadilimi", "Kupa", "Anahtar", "Kilit", "Sandik",
  "Kalkan", "Kilic", "Yuzuk", "Tac", "Elmas", "Para", "Kitap", "Kalem", "Palet", "Kamera",
  "Ampul", "Mum", "Hediye", "Balon", "Semsiye", "Capa", "Yelkenli", "Roket", "UFO", "Robot",
  "Konsol", "Zar", "Kupa 2", "Madalya", "Kum Saati", "Pusula", "Nota", "Zil", "Zarf", "Bayrak"
];

final List<List<String>> objectTemplates = [
  // 51. Star (Yildiz)
  [
    ".........................",
    "............L............",
    "...........LLL...........",
    "...........LKL...........",
    "..........LLKLL..........",
    "..........LKKKL..........",
    ".........LKKKKKL.........",
    ".........LKKKKKL.........",
    ".........LKKKKKL.........",
    "LLLLLLLLLKKKKKKKLLLLLLLLL",
    "LKKKKKKKKKKKKKKKKKKKKKKKL",
    ".LLKKKKKKKKKKKKKKKKKKKLL.",
    "...LLKKKKKKKKKKKKKKKLL...",
    ".....LLKKKKKKKKKKKLL.....",
    ".......LKKKKKKKKKL.......",
    ".......LKKKKKKKKKL.......",
    "......LLKKKKKKKKKLL......",
    "......LKKKKKKKKKKKL......",
    ".....LLKKKKKKKKKKKLL.....",
    ".....LKKKKKLLLKKKKKL.....",
    ".....LKKKKLL.LLKKKKL.....",
    "....LKKKLL.....LLKKKL....",
    "....LKLL.........LLKL....",
    "....LLL...........LLL....",
    "........................."
  ],
  // 52. Heart (Kalp)
  [
    "................",
    "..LLL......LLL..",
    ".LLAAALAALAAALL.",
    "LLAAAAALLAAAAALL",
    "LAAAAAAAAAAAAAAL",
    "LAAAAAAAAAAAAAAL",
    ".LAAAAAAAAAAAAL.",
    ".LAAAAAAAAAAAAL.",
    "..LAAAAAAAAAAL..",
    "...LAAAAAAAAL...",
    "....LAAAAAAL....",
    ".....LAAAAL.....",
    "......LAAL......",
    "......LLLL......",
    "................",
    "................"
  ],
  // 53. Apple (Elma)
  [
    "........................",
    "........................",
    "........................",
    ".............CC.........",
    "............CC..........",
    "............CCC.........",
    "........................",
    ".......CCCC....CCCC.....",
    "......CCCCCCCCCCCCCC....",
    ".....CCCCCCCCCCCCCCCC...",
    "....DDDDDDDDDDDDDDD.....",
    "....DDDDDDDDDDDDDDD.....",
    ".....FFFFFFFFFFFFF......",
    "....FFFFFFFFFFFFFF......",
    ".....FFFFFFFFFFFFF......",
    "....AAAAAAAAAAAAAAA.....",
    ".....AAAAAAAAAAAAAAA....",
    ".....EEEEEEEEEEEEEEEE...",
    "......EEEEEEEEEEEEEE....",
    "......BBBBBBBBBBBBB.....",
    ".......BBBBBBBBBBB......",
    "........BBB...BBB.......",
    "........................",
    "........................"
  ],
  // 54. Banana (Muz)
  [
    "........................",
    "........................",
    "........................",
    "................NN......",
    "................NN......",
    ".................NN.....",
    "..................N.....",
    "................pDo.....",
    "................pDD.....",
    "................pDD.....",
    "................pDo.....",
    "...............pDDo.....",
    "..............pDDDo.....",
    "..............pDDDo.....",
    "...........ppDDDDoo.....",
    "........pDDDDDDDoo......",
    "......DDDDDDDDoDDo......",
    ".....NoDDoDDoDoo........",
    ".....Nooooooooo.........",
    ".....N..ooooo...........",
    "........................",
    "........................",
    "........................",
    "........................"
  ],
  // 55. Orange (Portakal)
  [
    ".........LLLLLL.........",
    ".......LLLffffLLL.......",
    ".....LLfffppppfffLL.....",
    "....LffpppFppFpppffL....",
    "...LfLpFFFFppFFFFpLfL...",
    "..LfLppFFFFppFFFFppLfL..",
    "..LfppppFooppooFppppfL..",
    ".LfpFFpppooppoopppFFpfL.",
    ".LfpFFFpppoppopppFFFpfL.",
    "LLfpFFooppppppppooFFpfLL",
    "LfpFFFoooppppppoooFFFpfL",
    "LfppppppppppppppppppppfL",
    "LfppppppppppppppppppppfL",
    "LfpFFFoooppppppoooFFFpfL",
    "LLfpFFooppppppppooFFpfLL",
    ".LfpFFFpppoppopppFFFpfL.",
    ".LfpFFpppooppoopppFFpfL.",
    "..LfppppFooppooFppppfL..",
    "..LfLppFFFFppFFFFppLfL..",
    "...LfLpFFFFppFFFFpLfL...",
    "....LffpppFppFpppffL....",
    ".....LLfffppppfffLL.....",
    ".......LLLffffLLL.......",
    ".........LLLLLL........."
  ],
  // 56. Watermelon (Karpuz)
  [
    "........................",
    "........................",
    "........................",
    "........................",
    "...........AA...........",
    "..........AAAA..........",
    ".........AAAAAA.........",
    "........ALAAAALA........",
    ".......AAAAAAAAAA.......",
    "......AAAAAAAAAAAA......",
    ".....AAALALAALALAAA.....",
    "....AAAAAAAAAAAAAAAA....",
    "...KAAAAAAAAAAAAAAAAK...",
    "..qKKKLAALAAAALAALKKKq..",
    ".rrqqKKKKKKKKKKKKKKqqrr.",
    "..rrrqqqKKKKKKKKqqqrrr..",
    "....rrrrqqqqqqqqrrrr....",
    "......rrrrrrrrrrrr......",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................"
  ],
  // 57. Strawberry (Cilek)
  [
    "........................",
    "...........LL...........",
    ".......LL.LqqL.LL.......",
    "......LqqLqqqqLqqL......",
    ".....LqqqqqqqqqqqqL.....",
    "....LqqqqqqqqqqqqqqL....",
    "....LqqqqqqqqqqqqqqL....",
    "....LAAAAAAAAAAAAAAL....",
    "...LAAKAAKAAAAKAAKAAL...",
    "...LAAAAAAAAAAAAAAAAL...",
    "...LAKAAKAAKKAAKAAKAL...",
    "...LAAAAAAAAAAAAAAAAL...",
    "....LAKAAKAAAAKAAKAL....",
    "....LAAAAAAAAAAAAAAL....",
    ".....LAKAAKAAKAAKAL.....",
    "......LAAAAAAAAAAL......",
    ".......LAKAAAAKAL.......",
    ".......LAAAAAAAAL.......",
    "........LAAAAAAL........",
    ".........LAAAAL.........",
    ".........LAAAAL.........",
    "..........LAAL..........",
    "...........LL...........",
    "........................"
  ],
  // 58. Pineapple (Ananas)
  [
    "................................................",
    "................................................",
    ".......................zz.......................",
    "...............z.......zz.......................",
    "...............zz......xx.......................",
    "................zz....zxxz....zz................",
    "................zxz...zxxz...zxz................",
    ".................zxxy.zxxz..xxy.................",
    ".................zxxxzxxxxzxxyz.................",
    ".............zxzzzyxxzxxxxzxyyzzzxz.............",
    "..............zxxxzzxzxxxxzyzzxxxz..............",
    "...............zxxxxzzxxxxzzxxxxz...............",
    "................zxxxxzzxxxzxxxxz................",
    "................zxxxxxzxxzxxxxx.................",
    "............zzyxxzzxxxzxxzxxxzzxxxzz............",
    "..............zzyxxzzxzxxxxzzxxyz...............",
    "................zyxxxzxxxxzxxxyz................",
    ".................zyxxxxxxzxxyyz.................",
    "..............zzyzzyxxzxxxxyyzzyzz..............",
    "................zyyzxxxzzxxyzyyz................",
    "..................zyzzxzzwyzyy..................",
    "..................zzvwwvvwwwzz..................",
    ".................zwwwzvvvvzzwwy.................",
    "................yzwwvvv.vvvvwwwy................",
    "................zzzvvvvvvvvvwzwz................",
    "...............ywvvzvzvvvvvwzvvvy...............",
    "...............zwvyvvzvvvwzvvyvvz...............",
    "...............zwvvvvvvwwvvvvvywy...............",
    "..............ywzwKKzzvvvvKKzzvzwy..............",
    "..............ywvKKzzzvvvvKKzzzwwy..............",
    "..............zwwzzzzzvvvvzzzzzwwz..............",
    "..............ywwzzzKzvvvvzzzzKwwy..............",
    ".............yywwvzzzvvvvvzzzzvwwy..............",
    "..............wwvvvvvvzzzzvv.vwvwy..............",
    "..............z.vv0vvv0000vvvv0vwy..............",
    "..............zzvv0vzvv00v.vzv0wwy..............",
    "..............yvzvvvvvvvvvvvvvvwwy..............",
    "..............ywzzvvvvvvvvvvvvvwwy..............",
    "..............ywwvvvvzvvvwwvvvvvwz..............",
    "..............ywwvvzvvvvwwwvzvvwwy..............",
    "..............wwwwvvvvvwwvvvvwwwwy..............",
    "...............ywzvvvvvzzvvvvwvzy...............",
    "...............ywwvvwzvvvvvwwvwwy...............",
    "...............yywwvzvvvvv.wwwwz................",
    ".................yzywwzwwwwwyyy.................",
    "...................yyyyyyyyyy...................",
    "......................y.........................",
    "................................................"
  ],
  // 59. Carrot (Havuc)
  [
    "................................................",
    "...............................66666............",
    ".........................66666.63336............",
    "........................663336636636............",
    ".........................66333336666............",
    "..........................66666633666...........",
    "...........................6.666333366..........",
    ".............................666636666..........",
    "..........................66666..6666...........",
    "........................661122266...............",
    ".......................66612266666..............",
    "......................664462644622..............",
    "......................6646616646222.............",
    ".....................62646626646226.............",
    ".....................61644666446222.............",
    ".....................11666626622222.............",
    "....................611666666662266.............",
    ".............666....611664444462226.............",
    "............6446....611167777762226.............",
    ".........6666446....616667777762226.............",
    "........66644446....61166666662226..............",
    "........6664446.....61166666122666..............",
    ".......66664666.....61666662222226..............",
    "........66666666....61.66612222266..............",
    "...............66.666112221112266666............",
    "....................611222621226.6666...........",
    "....................661221112226...666..........",
    "....................666221122.66....666.........",
    ".....................11122212666....66..........",
    ".....................1112222226......66.........",
    ".....................6112222226....6666.........",
    "......................611222226...64446.........",
    "......................611222226..664446.........",
    "......................222.22226..6644446........",
    ".......................622.6222..6646666........",
    "........................6222226...66666.........",
    "........................662222......6...........",
    ".........................6622666....6...........",
    ".........................666666.................",
    "...................6666...6666...66.............",
    "..................6666.....666.6.666............",
    "..................6666666..666666666............",
    "..................6666655666...66556............",
    "...................666555666...65556............",
    "....................6655566....65556............",
    ".....................665566....66556............",
    "......................6666.....66666............",
    "........................6.......66.............."
  ],
  // 60. Mushroom (Mantar)
  [
    "................................................",
    "..................####88+-##....................",
    ".................##8888+++888##.................",
    "...............##888888#9+88888##...............",
    "..............#88888888+9+8888888#..............",
    "............#+88888888899988888888#.............",
    "...........##98888888888998888888888#...........",
    "..........#=99+88.8888888888888+88888#..........",
    ".........#===9=88888888888888+=99+8888#.........",
    "........#====9=88888888888888=999988888#........",
    ".......#======+888888+++8888899999+88888#.......",
    "......#-+====+88888+=999=+888=999=888888#.......",
    ".....#---+++8--888+999999=8888=9=+8888888#......",
    "....##----------8+99999999=8888888888+==8-......",
    "....#------.-----+9999999998888888888+==88#.....",
    "....#------------+99999999988888888888++88#.....",
    "....8-----------.+==99999998888888888888888.....",
    "...#===+----------===99999=8888888888888888#....",
    "..##====+---------+====99=+88888888888+===+#....",
    "...#=====+-----.---+=====+88888888888+99999#....",
    "....#=====-----------8+8----888888888=9999#.....",
    "....#=====+-----------------------88+99999#.....",
    ".....#====+-------------------------+====#......",
    "......##==+-------.-----------------8==##.......",
    "......#+###-.-----------------------###+#.......",
    "......#++++#########################++++#.......",
    "......#+++#.#+++#.#+++###+++#.#+++#.#+++#.......",
    ".......###..#+##..#+++#+#+++#..##+#..###........",
    "..................#++#+++#++#...................",
    "...................##+====##....................",
    "...................+++======#...................",
    "..................#+++======#...................",
    "..................#+++======#...................",
    "..................#++========...................",
    ".................#+++========#..................",
    ".................#+++========#..................",
    ".................++++=========#.................",
    "................#++++=========#.................",
    "................+++++==========.................",
    "...............#+++++=====*====#................",
    "...............#++++++====*****#................",
    "...............+++++++====*****=................",
    "...............#++++++====*****#................",
    "...............#+++++++====***=#................",
    "...............#+++++++=====*==#................",
    "................#+++++========#.................",
    ".................#++++++=+===#..................",
    "..................##++++==+##..................."
  ],
  // 61. Cupcake (Kupkek)
  [
    "................................................",
    "................................................",
    "................................................",
    "................................................",
    ".........................{{{{...................",
    "....................{{{{{{{{{{..................",
    "...................{{{{{{{{{{{..................",
    "..................{{{{{{{{{{{{..................",
    "..................{{{{{{{{{{{{>>................",
    "................}}>{{{{{{{{{{>>>................",
    "...............}}}}<<<<<{<<<>}}}................",
    "..............}}}}}}}<<<<<>>}}}}}}..............",
    ".............}}}}}}}}}}}}}}}}}}}}}}.............",
    "............}}}}}}}}}}}}}}}}}}}}}}}}............",
    "............}}}}}}}}}}}}}}}}}}}}}}}}}...........",
    "...........}}}}}}}}}}}}}}}}}}}}}}}}}}}..........",
    "..........[]}}}]>[}}}}}}}]}}}}}}}}}}}}]]........",
    ".........[[]]]][[[]}}}}]][[]}}}][[]}}]]]........",
    ".........[[]]][[[[>}}}]][[[]}}}][[[]][]]........",
    ".........[[[[[[[[[[]]]][[[[]}}}][[[[[[..........",
    "........[[[[[[[[[[[[]][[[[[]}}}}[[[[[[[.........",
    "........][[[[[[[[[[[[[[[[[[]}}}}>[[[[[[.........",
    "........]][[[[[[[[[[[[[[[[[]}}}}][[[[[..........",
    "........]]][[[[[[[[[[[[[[[[]}}}}][[[[[..........",
    "........]]]][[[[[[[[[[[[[[[]}}}}[[[[[]].........",
    ".......]]]]]]][[[[[[[[[[[[[[]]]>[[[[]]]]........",
    ".......]]]]]]]]]][[[[[[[[[[[[[[[[]]]]]]]........",
    "......]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]].......",
    "......]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]].......",
    ".......]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]].......",
    "........]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]........",
    "........]]]]]]]]]]]]]]]]]>>]]]]]]]]]]]].........",
    "........<><<><<>]]]]]]]<><<><]]]]]<<><..........",
    ".........><<><<><]]]]><<><<><<><<><<><..........",
    ".........><<><<><<[]<><<><<><<><<><<><..........",
    ".........><<><<><<]<<><<><<><<><<><<><..........",
    ".........><<><<><<><<><<><<><<><<><<><..........",
    ".........><<><<><<><<><<><<><<><<><<><..........",
    "..........<<><<><<><<><<><<><<><<><<>...........",
    "..........<<><<><<><<><<><<><<><<><<>...........",
    "..........<<><<><<><<><<><<><<><<><<>...........",
    "...........<><<><<><<><<><<><<><<><<>...........",
    "...........<><<><<><<><<><<><<><<><<............",
    "...........<><<><<><<><<><<><<><<><<............",
    "............><<><<><<><<><<><<><<><<............",
    "............><<><<><<><<><<><<><<><.............",
    ".............<<><<><<><<><<><<><<><.............",
    "..............<><<><<><<><<><<><<>.............."
  ],
  // 62. Cookie (Kurabiye)
  [
    ".______________________________________________.",
    "________________________________________________",
    "________________________________________________",
    "____________________)))))))_____________________",
    "________________)))))))))))__________))_________",
    "______________)))))(((((())_________))))________",
    "____________))))((((((((())_________))))________",
    "__________))))((((((((((())_________))))________",
    "_________)))((((((((((((())_____________________",
    "________)))(((((((((((((())_____________________",
    "_______)))(((((((((((((((()))___________________",
    "______)))(((((((((((((((((()))____________)_____",
    "_____)))((((()(((((((((((((())____________))____",
    "____)))((((()))((((((((((((())_____)))__________",
    "____))((((((()(((((((((((((()_____))))__________",
    "___))((((((((((((((((((((((()______)))__________",
    "___))(((((((((((((()))((((())_______)________))_",
    "__))(((((((((((((())))(((((()________________)))",
    "__))((((((((((((((()))(((((())_______________))_",
    "_))((((((((((((((((((((((((())__________________",
    "_))(((((((((((((((((((((((((())_________________",
    "_))((((((((((((((((((((((((((()))____)))________",
    "))((((((((())))(((((((((((((((())))))))))_______",
    "))(((((((())))))((((((((((((((((())))(()))___))_",
    "))(((((((())))))(((((((((((((((((((((((())))))))",
    "))(((((((())))))((((((((((((((((((((((((())))())",
    "))(((((((())))))(((((()))((((((((((((((((((((())",
    "))((((((((())))((((((()))((((((((((((((((((((())",
    "))(((((((((((((((((((()))((((())(((((((((((((())",
    "))((((((((((((((((((((((((((((()(((((((((()((())",
    "))((((((((((((((((((((((((((((((((((((((()))(())",
    "))(((((((((((((((((((((((((((((((((())(((()((())",
    "_))((((((((((((((((((((((((((((((((())((((((())_",
    "_))(((((((((((((((((((((((((((((((((((((((((())_",
    "_))(((((((((())))(((((((((((())(((((((((((((())_",
    "__))((((((((())))((((((((((())))(((((((((((()))_",
    "__))((((((((())))(((((((((())))))((((((((((())__",
    "__)))((((((((()))(((((((((())))))((((((((((())__",
    "___))(((((((((((((((((((((())))))(((((((((())___",
    "____))(((((((((((((((((((((())))(((((((((()))___",
    "____)))((((((((((((((((((((((((((((((((((())____",
    "_____))(((((((((((((((((((((((((((((((((())_____",
    "______))(((((((((((((((((((((((((((((((())______",
    "_______))(((((((((((((((((((((((((((((())_______",
    "________)))((((((((((((((((((((((((((_))________",
    "________________________________________________",
    "________________________________________________",
    ".______________________________________________."
  ],
  // 63. Donut (Donat)
  [
    ".~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&&&&&&&&&&&.",
    "??????????????~!!!!!!!!!&&&&&&&&&&&&&&&&&&&&&&&&",
    "??????????????~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "??????????????~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "??????????????~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "??????????????~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "??????????????~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "??????????????~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "??????????????~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "??????????????~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "??????????????~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "?&&&&&&&&&&?&&~!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "&&&&&&&&&&&???~!!!!!!!?!!!!!!!!~~~~??&&&&&&&&&&&",
    "&&&&&&&&&?~~!!!!!!!^&!!!!!!!!&!&!!!!~~~&&&&&&&&&",
    "&&&&&&&?~!!!!!?!!~^^!!!!&!&!&!^^!!!!&&!~~?&&&&&&",
    "&&&&&??!!~!!!!!~?^^!&?!&!&!&!&&^^!!&&!!!!~~&&&&&",
    "&&&&&~!!!%%!&&&&^^&&&&!!!!!&!!??&^^&!!!~!!!&&&&&",
    "&&&&&!!!!!%%%&&^^!~!!!!!!!?!!!!!&!!^^?!!!!!&&&&&",
    "&&&&&!!!&&&&!!^^!!!!!!!!!~!!!!!!&&!&^&!!&&&&&&&&",
    "&&&&&!!&&&&!!^^!!!!!!!!!!~~?!!!!&!!!&^&&&!!&&&&&",
    "&&&&&!&&&@@&&^!!!!!?~!&!~???~!!??!!!&^&\$\$!!&&&&&",
    "&&&&&&&!&~@@@^!!!!~??~~~~???~!~??!!?&^&!\$\$!&&&&&",
    "&&&&&&!!!!&&&^&&&~~???~?????~~~~!!?&^!!&!\$!&&&&&",
    "&&&&&&!!!!&!!&^&!!~~~~~~~~~~~~!!!?&^!&&&!!&&&&&&",
    "&&&&&&?!!!!&?!!^!!!!!!!~~!!!!!!!?&^&&&&!!&!&&&&&",
    "&&&&&!&&&\$\$!&&&&^!?!!!&&&&!!?!!~^^&&!!!!!!!&&&&&",
    "&&&&&!!~~~\$\$\$&&&&^~!!&&&&&&&&!^^!&!??!@@!!!&&&&&",
    "&&&&&~!!!!!!~!&&&&&^&&!&!&!!!&&&&!!??!?@@!!&&&&&",
    "&&&&&?~~!!!~~!&&&!!!&&!!!!!?&&!&!!!!!!!!@!!&&&&&",
    "&&&&&????~!!!!!!??!!&&!!!&&&!!!!!!!!!!!~!!!&&&&&",
    "&&&&&????~!!!!!!??!!!!!!%%&!!!!!!!!!!!~?~~~&&&&&",
    "&&&&&?????~!!!!!!!!!!&!!&%%!!!!!!!~!!~?&???&&&&&",
    "&&&&&?????~!!!!!!!!!!!!!!!%!!!!!!!!!!~???&?&&&&&",
    "&&&&&?????~~!!!!!!~~~~!!&&~~???~!!!!!~?&???&&&&&",
    "&&&&&??????~!!!!!~~??~~~~~?&&?&?~!!!&~?&???&&&&&",
    "&&&&&??????~~!!!~~?????~~?&????&?~!!!~&????&&&&&",
    "&&&&&~??????~~~~~???????&???????&~~~~?????~&&&&&",
    "&&&&&?~~??????~??????????????????&???????~~&&&&&",
    "&&&&&&&~~??????????????????????????????~~?&&&&&&",
    "&&&&&&&&?~~??????????????????????????~~~&&&&&&&&",
    "&&&&&?&&&&?~~~????????????????????~~~?&&&&?&&&&&",
    "&&&&&&&?&?&&???~~~~~???????~~~~~~???&&&&&&&&&&&&",
    "&&&&&&&&&&&&&&&&?????~~~~~?????&&&&&&&&&&&&&&&&&",
    "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",
    ".&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&."
  ],
    // 64. Ice Cream (Dondurma)
  [
    ".CCCCCCCCC_____CCCC///////____CCCCCCCCCC_____CC.",
    "CCCCCCCCC_____CCCC/KKKKK:,/__CCCCCCCCCC_____CCCC",
    "CCCCCCCC_____CCCC/,KK||||K|/CCCCCCCCCC_____CCCCC",
    "CCCCCCC_____CCCC/|K|||||||||/CCCCCCCC_____CCCCCC",
    "CCCCCC_____CCCC/|K|||||||/|||/CCCCCC_____CCCCCCC",
    "CCCCC_____CCCCC/|||||||||||||/CCCCC_____CCCCCCCC",
    "CCCC_____CCCCCC/|||||||||||||/CCCC_____CCCCCCCCC",
    "CCC_____CCCCCC|/|||||||||||||//CC_____CCCCCCCCCC",
    "CC_____CCCCCCC|/||||||/|||||||//_____CCCCCCCCCC_",
    "C_____CCCCCCCC///||||||||||||||~/___CCCCCCCCCC__",
    "_____CCCCCCCC|~///||||||||||///~~~_CCCCCCCCCC___",
    "____CCCCCCCCC~////|||||||/||/~~~/~~CCCCCCCCC____",
    "___CCCCCCCCC~~~~/////|||////~~~~~|~/CCCCCCC_____",
    "__CCCCCCCCC/~~~~~~~~~/|//~~~~~~~~//~CCCCCC_____C",
    "_CCCCCCCCCC~~~~~~~~~~~~~~~~~~~~~~~|~~CCCC_____CC",
    "CCCCCCCCCC_~~~~~~~~~~~~~~~~~~~~~~~~,~CCC_____CCC",
    "CCCCCCCCC_:~~::::~::::::,~`~,,,~,,,,``C_____CCCC",
    "CCCCCCCC__:~~:::~~::~;::~~`~`,,,~``,``_____CCCCC",
    "CCCCCCC___:~~::~~::~~::~~~~~~~,,`~~``_____CCCCCC",
    "CCCCCC_____~~::~:::~::~~~~~~,`~`,,,``____CCCCCCC",
    "CCCCC_____C;~;:::~~~::::~~~~`,``,,`~____CCCCCCCC",
    "CCCC_____CCC~~::~::::~~~~~~,`,,,,,~`___CCCCCCCCC",
    "CCC_____CCCC;~~::~~~~~~~~~`,,,,,,,~___CCCCCCCCCC",
    "CC________EECC~:;~~~~~;;~~~,,,,,,~`__EEEEECCCCC_",
    "C_____EEEEECCC;~~~~~~~;;`~~,,~,~~~__EEEEECCCCC__",
    "_____EEEEECCCCC;~~~~~;;;`~~,,~~~~`_EEEEECCCCC___",
    "____EEEEECCCCC__;)~;;;;;``~,`~~~~_EEEEECCCCC____",
    "___EEEEECCCCC____))))),??)))))))))EEEECCCCC_____",
    "__EEEEECCCCC_____?))))?)?))))))))EEEECCCCC_____E",
    "_EEEEECCCCC_____EE))))?))?~))))))EEECCCCC_____EE",
    "EEEEECCCCC_____EEE)))))))~?))))))EECCCCC_____EEE",
    "EEEECCCCC_____EEEEE)))))?~))))))EECCCCC_____EEEE",
    "EEECCCCC_____EEEEEC)))))))))?)))ECCCCC_____EEEEE",
    "EECCCCC_____EEEEECC)))??~?)~?)))CCCCC_____EEEEEC",
    "ECCCCC_____EEEEECCCC)))))))))??)CCCC_____EEEEECC",
    "CCCCC_____EEEEECCCCC))))?)~?)?))CCC_____EEEEECCC",
    "CCCC_____EEEEECCCCC__))))))))?)CCC_____EEEEECCCC",
    "CCC_____EEEEECCCCC___)))))?))?)CC_____EEEEECCCCC",
    "CC_____EEEEECCCCC_____))?)?)??)C_____EEEEECCCCC_",
    "C_____EEEEECCCCC_____E))??))??)_____EEEEECCCCC__",
    "_____EEEEECCCCC_____EEE~)?))?))____EEEEECCCCC___",
    "____EEEEECCCCC_____EEEE)))))?)____EEEEECCCCC____",
    "___EEEEECCCCC_____EEEEE)))???)___EEEEECCCCC_____",
    "__EEEEECCCCC_____EEEEECC))???)__EEEEECCCCC_____E",
    "_EEEEECCCCC_____EEEEECCC)))?))_EEEEECCCCC_____EE",
    "EEEEECCCCC_____EEEEECCCCC))))_EEEEECCCCC_____EEE",
    "EEEECCCCC_____EEEEECCCCC_)~))EEEEECCCCC_____EEEE",
    ".EECCCCC_____EEEEECCCCC___)~)EEEECCCCC_____EEEE.",
  ],
  // 65. Burger (Burger)
  [
    ".ÇÇÇÇÉÇÇÇÇÉÇÇÇÇÉÇÇÇÇÉÇÇÇÇÉÇÇÇÇÉÇÇÇÇÉÇÇÇÇÉÇÇÇÇÉÇ.",
    "ÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇ",
    "ÇÇÉÉÇÇÇÉÉÇÇÇÉÉÇÇÇÉ\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÉÉÇÇÇÉÉÇÇÇÉÉÇÇÇÉ",
    "ÇÇÉÉÇÇÇÉÉÇÇÇÉÉÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÇÉÉÇÇÇÉÉÇÇÇÉ",
    "ÇÉÇÇÉÇÉÇÇÉÇÉ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÉÇÇÉÇÉÇÇÉÇÉÇ",
    "ÉÇÇÇÇÉÇÇÇÇÉ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÉÇÇÇÇÉÇÇ",
    "ÇÉÇÇÉÇÉÇÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÉÇÉÇÇÉÇÉÇ",
    "ÇÇÉÉÇÇÇÉ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÉÉÇÇÇÉ",
    "ÇÇÉÉÇÇÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÉÉÇÇÇÉ",
    "ÇÉÇÇÉÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÉÇÉÇ",
    "ÉÇÇÇÇÉ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÉÇÇ",
    "ÇÉÇÇÉ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÉÇÉÇ",
    "ÇÇÉÉ¶\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÇÉ",
    "ÇÇÉÉ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\¶ÇÇÉ",
    "ÇÉÇ¶\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\¶ÇÉÇ",
    "ÉÇÇ¶\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÉÇÇ",
    "ÇÉÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\¶ÉÇ",
    "ÇÇ¶\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\É",
    "Ç¶\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\¶",
    "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\",
    "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\",
    "ÇÉ®®®®®®®®®®®®®®®®®®®®®®\\®®®®®®®®®®®®®®®®¿¿¿¿¿ÉÇ",
    "ÇÇ¿¿¿¿¿¿¿®®®®®®®®®®®®®®®®®®®®®®®®®®®®¿¿¿¿¿¿®®¿ÇÉ",
    "ÇÇ'''''''''''''''''''''''''''''''''''''''''''ÇÇÉ",
    "ÇÉÇ''''''''''''''''''''''''''''''''''''''''''¿'Ç",
    "ÉÇÇ'''''''''''''''''''''''''''''''''''''''''¿'¿Ç",
    "ÇÉÇ\\¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿°°°¶®°°®¿¿¿¿¿¿¿¿¿¿¿¿¿¿°°°°°",
    "ÇÇÉ\\\\\\¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿°°°°°°¿¿¿¿¿¿¿¿¿¿¿¿¿°°°°°°É",
    "ÇÇ°°°°°°°°¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿°°°°°°°°°°ÇÉ",
    "ÇÉÇ''''''''''''¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿'''''''''ÉÇ",
    "ÉÇÇ'''''''''''''''''''''¿''¿¿'''''''''''''''¿'ÇÇ",
    "ÇÉ'''''''''''''''''''''''''''''''¿'''''¿''''''ÉÇ",
    "ÇÇ\\\\\\\\\\¿\\\\\\\\\\¿¿¿¿¿¿\\\\\\\\\\\\¿¿\\\\\\\\¿¿\\¿¿¿¿¿¿\\\\\\\\¿\\ÇÉ",
    "ÇÇÉ¿\\\\\\\\\\\\\\\\\\\\¿¿\\\\\\¿¿¿¿¿¿¿¿¿¿\\¿¿\\\\\\¿¿¿¿\\\\\\\\¿¿ÇÇÉ",
    "ÇÉÇ\\¿¿\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\¿¿\\\\\\\\\\¿¿¿\\\\\\\\\\\\\\\\\\\\¿¿¿\\ÇÉÇ",
    "ÉÇÇ\\\\¿¿¿¿\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\¿¿¿¿¿\\\\\\ÉÇÇ",
    "ÇÉÇ\\ÉÇ\\\\¿¿¿¿¿¿¿\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\¿¿¿¿¿¿¿\\\\\\\\\\ÇÉÇ",
    "ÇÇÉÉÇÇÇÉÉ\\\\\\¿¿¿¿¿¿¿¿¿¿¿ÇÇ¿¿¿¿¿¿¿¿¿¿\\\\\\\\\\\\\\\\\\\\ÇÇÉ",
    "ÇÇÉÉÇÇÇÉÉÇÇÇÉ\\ÇÇ\\\\\\\\\\\\¿Ç\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÉ",
    "ÇÉÇ\\ÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÇÇÇÇÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÉÇ",
    "ÉÇÇ\\\\ÉÇÇÇÇÉÇÇÇÇÉÇÇÇÇÇÇÇÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÉÇÇ",
    "ÇÉÇÇ\\\\ÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÉÇÉÇ",
    "ÇÇÉÉÇÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÉÉÇÇÇÉ",
    "ÇÇÉÉÇÇÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÉÉÇÇÇÉ",
    "ÇÉÇÇÉÇÉÇÇÉ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÉÇÉÇÇÉÇÉÇ",
    "ÉÇÇÇÇÉÇÇÇÇÉÇÇÇ\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ÇÇÇÉÇÇÇÇÉÇÇÇÇÉÇÇ",
    "ÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇÇÉÇÉÇ",
    ".ÇÉÉÇÇÇÉÉÇÇÇÉÉÇÇÇÉÉÇÇÇÉÉÇÇÇÉÉÇÇÇÉÉÇÇÇÉÉÇÇÇÉÉÇÇÇ."
  ],
  // 66. Pizza Slice (Pizzadilimi)
  [
    ".ÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍ.",
    "ÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍKKKKÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍ",
    "ÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎKKKKpppÍKÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍ",
    "ÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍKKKppppppuupKÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎ",
    "ÍÎÍÍÍÍÎÍÍÍÍÎÍKKKpuuuppppuuuuKKÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍ",
    "ÎÍÍÍÍÎÍÍÍÍÎÍKKpuuuupuuuuuuuuKKÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍ",
    "ÍÍÍÍÎÍÍÍÍÎKKpuuuuuuuuuuu''uuÍKÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍ",
    "ÍÍÍÎÍÍÍÍÎKpuppuuuuuuu''uu®®®pKÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍ",
    "ÍÍÎÍÍÍÍKKpuppuuuuuu''u®®u''u®pKÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎ",
    "ÍÎÍÍÍÍKKuppuuuuuuu'u®®®''''''uKKÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍ",
    "ÎÍÍÍÍKKuppuuuuuu''u®®®'''''''upKÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍ",
    "ÍÍÍÍÎKuupuuuuuu'u®®uu®'''''''uppKÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍ",
    "ÍÍÍÎKp'uuuuuuu'u®®Î®®®u''''u'u®p¿KÍÍÍÍÎÍÍÍÍÎÍÍÍÍ",
    "ÍÍÎKÍ'upuuuuu'u®®uuu®®®u''''u®®®pKÍÍÍÎÍÍÍÍÎÍÍÍÍÎ",
    "ÍÎÍK¿upppu'u'u®u''''''®®uuuu®®u'uKÍÍÎÍÍÍÍÎÍÍÍÍÎÍ",
    "ÎÍÍKpupppp''u®®''''''''®®®®®u''''pKÎÍÍÍÍÎÍÍÍÍÎÍÍ",
    "ÍÍÍÍKpuppp'uu®u''u'''''u®u®®'''''uKÍÍÍÍÎÍÍÍÍÎÍÍÍ",
    "ÍÍÍppKKpppuuuu'''u'''''u®®®u''uu''ÍKÍÍÎÍÍÍÍÎÍÍÍÍ",
    "ÍÍÎÍppÍKpuuuu®''u''''''u®®®u'u''''uKÍÎÍÍÍÍÎÍÍÍÍÎ",
    "ÍÎÍÍÍppÍKÍuuuuu'''u'u''®u®®u'u'''''KÎÍÍÍÍÎÍÍÍÍÎÍ",
    "ÎÍÍÍÍÎppÍKuuuuuu'''''u®®u®®®'''u'u'pKÍÍÍÎÍÍÍÍÎÍÍ",
    "ÍÍÍÍÎÍÍÍÍK¿Ípuuuuuuu®®®®Î®u®®u'''''uKÍÍÎÍÍÍÍÎÍÍÍ",
    "ÍÍÍÎÍÍÍÍKÍuKKp®®uu®®®®®u''''u®®uu®®®pKÎÍÍÍÍÎÍÍÍÍ",
    "ÍÍÎÍÍÍÍÎKK'ÍKpu®uuuu®®u'''''''®®®u®®pKÍÍÍÍÎÍÍÍÍÎ",
    "ÍÎÍÍÍÍÎÍÍKKKKK¿upu®®®u''''''u''®®®®u®¿KÍÍÎÍÍÍÍÎÍ",
    "ÎÍÍÍÍÎÍÍÍÍKÍpKp¿puup®®u''u'''''®®®®®u'KÍÎÍÍÍÍÎÍÍ",
    "ÍÍÍÍÎÍÍÍÍppppKp®pÍpKp®®u'''''''u®®Îu''pKÍÍÍÍÎÍÍÍ",
    "ÍÍÍÎÍÍÍÍÎÍppÍKu®pKKKpupu®u'uu''®®®®'''uKÍÍÍÎÍÍÍÍ",
    "ÍÍÎÍÍÍÍÎÍÍÍÍÎKu®ÍÎÍKupKKu®u''''®u®u'u''pKÍÎÍÍÍÍÎ",
    "ÍÎÍÍÍÍÎÍÍÍÍÎÍKuuKÍÍ¿upKKK'uu'u®®®®u''''uKÎÍÍÍÍÎÍ",
    "ÎÍÍÍÍÎÍÍÍÍÎÍÍKÍpKpÍKuKÍpKpuuuuu®®®®''u''¿KÍÍÍÎÍÍ",
    "ÍÍÍÍÎÍÍÍÍÎÍÍÍÍKKÍpÍKKKppÎKuÍKu®u®®®®''''pKÍÍÎÍÍÍ",
    "ÍÍÍÎÍÍÍÍÎÍÍÍÍppppÍÎppppÎÍK'ÍKpupuuu®®uu'uKÍÎÍÍÍÍ",
    "ÍÍÎÍÍÍÍÎÍÍÍÍÎÍpppÎÍpppÎÍÍKpKKÍpKp®uu®®u®®pKÍÍÍÍÎ",
    "ÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍKKÍÍKKKpupu®®®®®pKKÍÍÎÍ",
    "ÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍpppppÎKuuKKu®®®®®pKÍÎÍÍ",
    "ÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍppÍpKÍuuKKKu®®u®pKKÍÍÍ",
    "ÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍKÍ'pKpKÍ¿uuuupKÍÍÍ",
    "ÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍK¿KÍpÍKupuuuuKÍÍÎ",
    "ÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎKÍpÍÎKKKKuupKÍÎÍ",
    "ÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎppppÎÍpÍpKpuKÍÎÍÍ",
    "ÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍppÎÍÍpppKÍuKpÍÍÍ",
    "ÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎpKpuKÍÍÍÍ",
    "ÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍKKKKÍÍÍÎ",
    "ÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎKpÍÍÎÍ",
    "ÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎpppÍÎÍÍ",
    "ÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍppÍÎÍÍÍ",
    ".ÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÎÍÍÍÍÍÍÍÍ.",
  ],
  // 67. Cup (Kupa)
  [
    ".........................æ......................",
    ".........................åå.....................",
    ".........................åå.....................",
    ".........................á......................",
    "........................áæ......................",
    "......................áá........................",
    "......................åáæ.......................",
    "......................áæ.å......................",
    "......................áá..á.....................",
    ".....................æá...áæ....................",
    "....................áæ...æáå....................",
    "....................á...ááæ.....................",
    "....................æ..æá.......................",
    ".....................å..........................",
    "................................................",
    "................................................",
    "...............åæááàààààààààááææ................",
    "...........æáàààããããããããããããããããààáæ............",
    "........åæàãããããããããããããããããããããããããàáæ.........",
    ".......æáããããããâââäääääääääääâââããããããàá........",
    "......æååããââäääääääääääääääääääääââãããáá.......",
    ".....ååæãâäääääääääääääääääääääääääääâãàáå......",
    ".....áà.âääääääääääääääääääääääääääääààæàá......",
    ".....áààæâäääääääääääääääääääääääääääàààâââãàæ..",
    "......ââãáàâäääääääääääääääääääääääâàáãâââââââàæ",
    "......âââããàáàãââäääääääääääääââãàáàãââââãæ..àâã",
    "......ãâããããããààààààãããããããààààààãããããââã.....æâ",
    "......áââãããããããããããããããããããããããããããããââã......â",
    ".......ââãããããããããããããããããããããããããããããâââá....áâ",
    ".......ãâãããããããããããããããããããããããããããããâââããàáàââ",
    ".......åâããããããããããããããããããããããããããããââããâââââã.",
    "........ãâãããããããããããããããããããããããããããââãããããàæ..",
    "......æááããããããããããããããããããããããããããããâãàá.......",
    "....æáááæàããããããããããããããããããããããããããâãááæ.......",
    "..æáááááááãããããããããããããããããããããããããâãáááááæ.....",
    ".æáááááááááãããããããããããããããããããããããããááááááááæ...",
    "æáááááááááááãããããããããããããããããããããããááááááááááæ..",
    "áááááááááááààãããããããããããããããããããããààááááááááááæ.",
    "æááááááááááàããââãããããããããããããããââããàááááááááááæ.",
    "áæáááááááááààããââââãããããããããââââããààááááááááááá.",
    "áææáááááááááààãããâââââââââââââãããààáááááááááæàæ.",
    ".àææááááááááááààààãããããããããããààààááááááááááæàà..",
    "..àáåæááááááááááááàààààààààààááááááááááááááàà...",
    "...ààáææáááááááááááááááááááááááááááááááááàãá....",
    "....åàãàáæææááááááááááááááááááááááááááààãà......",
    ".......àããààáææææáááááááááááááááááààããàá........",
    ".........åáàãããàààáááááááááààààããããàá...........",
    "..............æáààãããããããããããààáæ...............",
  ],
  // 68. Key (Anahtar)
  [
    "DDDDDDDDDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCCCCCCCCCCC",
    "DAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBC",
    "DADDDDDDDDDDDDDDDDDDDDDD..CCCCCCCCCCCCCCCCCCCCBC",
    "DAD..........................................CBC",
    "DAD..........................................CBC",
    "DAD..........................................CBC",
    "DAD..........................................CBC",
    "DAD..........................................CBC",
    "DAD..........................................CBC",
    "DAD..........................................CBC",
    "DAD....................LLL...................CBC",
    "DAD...................L.LLLLLL...............CBC",
    "DAD....................LLL..L.L..............CBC",
    "DAD..........................................CBC",
    "DAD..........................................CBC",
    "DAD..........................................CBC",
    "DAD....KKKKK.................................CBC",
    "DAD..KKKKKKKKK...............................CBC",
    "DADKKKKKK.KKKKK..............................CBC",
    "DADKKK.......KKK.............................CBC",
    "DAKKK...KKK...KKK............................CBC",
    "DAKK.....K.....KK............................CBC",
    "DAKK.....K.....KKKKKKK.......................CBC",
    "DKKK.KKKKKKKK..KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKC",
    "BKKK.KKKKKKKKK.KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKA",
    "BKKK.....K.....KKKKKKK..............KKKKKKKK..DA",
    "BCKK.....K.....KK.....................KKKKK...DA",
    "BCKKK...KKK...KKK.....................KKKK....DA",
    "BCBKKK...K...KKK....................KKKK.KKK.ADA",
    "BCBKKKKKK.KKKKK.....................KKK...KK.ADA",
    "BCB..KKKKKKKKK.....................KKKKK.KKKKADA",
    "BCB....KKKKK........................KK.....K.ADA",
    "BCB..........................................ADA",
    "BCB..........................................ADA",
    "BCB..........................................ADA",
    "BCB....................LLL...................ADA",
    "BCB...................L.LLLLLL...............ADA",
    "BCB....................LLL..L.L..............ADA",
    "BCB..........................................ADA",
    "BCB..........................................ADA",
    "BCB..........................................ADA",
    "BCB..........................................ADA",
    "BCB..........................................ADA",
    "BCB..........................................ADA",
    "BCB..........................................ADA",
    "BCBBBBBBBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAAAAAAAADA",
    "BCCCCCCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDDDDDA",
    "BBBBBBBBBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAAAAAAAAAA",
  ],
  // 69. Lock (Kilit)
  [
    "..................ìì............................",
    "...................ì............................",
    "...................ììììììììì....................",
    "..................ìììììììììììì..................",
    "................ìììììììììììììììì................",
    "...............ììçìììììììììììììì................",
    "...............ìììììëëëëëëëìììììì...............",
    "..............ìììììëëì....ëëìììììì..............",
    ".............ììçììëë.......ìëììììë..............",
    ".............ìììììë.........ìëìììëì.............",
    ".............ììììëë..........ëìììëì.............",
    ".............ììììëì..........ìììììë.............",
    ".............ììììë...........ìììììë.............",
    ".............ììììë...........ìììììë.............",
    ".............ììììë...........ìììììë.............",
    ".............ììììë...........ìììììë.............",
    ".............ììììë............ììììë.............",
    ".............ììììë............ììììë.............",
    ".............ììììë...........ìëìëëë.............",
    ".............ììììë............ìììì..............",
    ".............ììììë..............................",
    ".............ììììë..............................",
    ".............ììììë..............................",
    ".............ììììë..............................",
    ".............ìëëìë..............................",
    "...........çççççççç.ééééééééééééééééééè.........",
    "........éççççç..çççéééééééééééééééèèèèè.........",
    "........éçççç..ççççéééééééééééééééèèèèè.........",
    "........çççç..ççççééééééééééééééééèèèèè.........",
    "........ççç..ççççéééééééééééééééééèèèèè.........",
    "........çç..ççççéééééééééèèééééééèèèèèè.........",
    "........é..çççééééé...íéíêêíèééééèèèèèè.........",
    "........éççççéééééé.êêêíêêêêíééééèèèèèè.........",
    "........éçççééééééëêêêêêêêêêíéééèèèèèèè.........",
    "........éççééééééééêêêêêêêêêíéééèèèèèèè.........",
    "........éçéééééééééíêêêêêêêêèéééèèèèèèè.........",
    "........ééééééééééééíêêêêêêèéééèèèèèèèè.........",
    "........éééééééééééééíêêêíèèééèèèèèèèèè.........",
    "........éééééééééééééíêêêíèéééèèèèèèèèè.........",
    "........ééééééééééééèíêêêíèéèèèèèèèèèèè.........",
    "........ééééééééééééèíííííèèèèèèèèèèèèè.........",
    "........éééééééééééééèèèèèèèèèèèèèèèèèè.........",
    "........ééééééééééééééééèèèèèèèèèèèèèèè.........",
    "........éèèèèèèéééèèèèèèèèèèèèèèèèèèèèè.........",
    "........éèèèèèèèèèèèèèèèèèèèèèèèèèèèèèè.........",
    ".........èèèèèèèèèèèèèèèèèèèèèèèèèèèèè..........",
    "................................................",
    "................................................",
  ],
  // 70. Chest (Sandik)
  [
    ".øøøøøùøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøø.",
    "øõõõõõùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùù",
    "øùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùù",
    "øùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùù",
    "øøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøø",
    "ùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùù",
    "ùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùù",
    "ùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùùùùùùøùùù",
    "øøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøø",
    "øùùùùùùùøùùùùùùùøùùùùùùùøùóóóôôôøòòòòöööøùùùùùùù",
    "øùùùùùùùøùùöùùùùøùùùùùùùøùùöóóôôôôóòóóôöøùùùùùùù",
    "øùùùùùùùøùùööùùöôóóôôôôóóóóòòóóôóòóóóóôôöùùùùùùù",
    "øøøøøøøöôóóóôóóóóóóóôóóóóóôôóóóóôóóóóóóôôöøøøøøø",
    "ùùùùøùöóóóóóóôóóôôóóóôóóôôóôôôôóóôóôôôóóôôùùøùùù",
    "ùùùùøùóóòóóóóóôóóóóóóóôóôôôôôôôôóóôóôôóóóôöùøùùù",
    "ùùùùøöóóóóóóóóôôóôôôóóôóóôôôôôôôóóõóóóóóóôôùøùùù",
    "øøøøøôóòóóóóóóóôóôôôôóóôóôôóôóôóóóôôóôôôóôóøøøøø",
    "øùùùùóóóóóóóóóóôóóóóóóóõóóôôôôôôôóóôóôôôóôóùùùùù",
    "øùùùùóóóóóóóóóóôôóôôôóóôóôôôôôôôôóóôóóóóóôóùùùùù",
    "øùùùùóóóóòóóóóóóôóôôôóóôóóôôóóóóóóóõóóóôôõóùùùùù",
    "øøøøøòóóóóóòóóóóôóóóóóóôóóóóóóóóóôõõõõõõõôóøøøøø",
    "ùùùùøóôóóóôôóòóóôóóóóóôõõôôóôôôôôõôôôóóóóóòùøùùù",
    "ùùùùøóóóóóóóóôóóõõõõõõõõõôôóôôõóóóóóôôôôôôóùøùùù",
    "ùùùùøóóòòóóóóóóóôõôôôóóóóóôôóóõôôõõõôóóóóóóùøùùù",
    "øøøøøóóóóòòóóôóòóóôôôôõõõõôôôôôôóóóôóóóóóóóøøøøø",
    "øùùùùóóóóóóóòóôóôõôôôôóõóóóòôôôôóóóôóôôôóóóùùùùù",
    "øùùùùóóóóóóóóóóóôóóóóóóôóóóóôôóôóóóôóôôôóóóùùùùù",
    "øùùùùóóòóóóóóóóóôóóôôóóôóóôóôõõôôóóôóôôôóóóùùùùù",
    "øøøøøóóòóóóóóóóóôóôôôóóôóôôóóóóóôóóôóóôôóóóøøøøø",
    "ùùùùøóóóóóóóóóóóôóôôôôóôóóôóóóóôôóóôóôôôóóóùøùùù",
    "ùùùùøóóóóóóóóóóóôóôôôóóôóóôôôôôôôóóôóôôôóóóùøùùù",
    "ùùùùøóóóóóóóóóóóôóóôôóóôóôôôôôôôôóóôóôôôóóóùøùùù",
    "øøøøøóóóóóóóóóóóôóôôôôóôóóôôôôôôôóóôóôôôóóóøøøøø",
    "øùùùùóóòóóóóóóóóôóôôôôóôóóôôôôôôôóóôóóóôóóóùùùùù",
    "øùùùùóóóóóóóóóóóôóôôôôóôóóôôôôóôôóóôóôôôóóóùùùùù",
    "øùùùùóóòóóóóóóóóôóôôôóóôóóôôôôôôôóóôóóôóóóóùùùùù",
    "øøøøøóôóóóóóóóóóôóóôôóóôóóôôôóóóóóóôóóóóóôóøøøøø",
    "öõúöõôóóóóóóóóóóôóôôôóóôóóóóóóóóóóôõôôôôôôóõúöõú",
    "õúöõúöõôóóôóóòóóôóóóóóòôóóóóóôôõôôôóóôôöööõúöõúö",
    "úöõúöõúööôóóóóóóôóòóóóôõõôôôôôôóôôôöööõúöõúöõúöõ",
    "öõúöõúöõúöõöôóôóôõôôôôôôôôôööööõúöõúöõúöõúöõúöõú",
    "õúöõúöõúöõúöõöôòóóôôôöööõúöõúöõúöõúöõúöõúöõúöõúö",
    "úöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõ",
    "öõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõú",
    "õúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúö",
    "úöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõ",
    "öõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõú",
    ".úöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõúöõú.",
  ],
  // 71. Shield (Kalkan)
  [
    "................................................",
    "................................................",
    "......................ċ.ýþċ.....................",
    ".....................ċþ.ýüþċ....................",
    "...................ċċþþþýüüþċċ..................",
    ".................ċċþþþþþýýüüüþċċ................",
    "..............ċċċþþþýþýýýýýýüüüþċċċ.............",
    ".....ý....ċċċċþþþþýýýýýÿÿýýýýýüüüüþþþċċ.........",
    ".....ýċċċċþýýýýýýýýýýýÿÿćÿýýýýýüüüüüüüþþþþ......",
    ".....ýýýýýýýýýýýýýýýÿÿććććÿÿýýýýüüüüüüüüü.......",
    "......ýþýýýýýýýýüü...ćććććććÿÿýýýýüüüüüüüü......",
    "......ýþþýüüüüüÿÿÿććććć..ćććććÿÿýýýýýýýýýü......",
    "......ýþþþüÿÿÿÿćććććĉĉĉ.ĉĉĉĉćććććÿÿÿýýýýü.......",
    "......ýþþþüÿććććććĉĉĉĉĉĉĉĉĉĉĉĉćććććććýýýü.......",
    "......þþþþüÿććććĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉćććÿýýüüþ......",
    "......ċþþþüÿćććĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉććÿýýüüċ......",
    "......ċþþþýÿććĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉććÿýýüüċ......",
    "......ċýþþýÿććĉĉĉĉĉĉĉċċċċċċċĉĉĉĉĉĉććýýüüüċ......",
    "......ċýþþýüććĉĉĉĉĉċċċċċċċċċċĉĉĉĉĉććýüüüüċ......",
    "......ċýþþýüććĉĉĉĉċċċċċċċċċċċċĉĉĉĉććýüüüüċ......",
    "......ċýýþýüÿćĉĉĉĉċċċċċċċċċċċċĉĉĉĉćÿýüüüüċ......",
    ".......ċýýýýÿćĉĉĉċċċċċċċċċċċċċċĉĉĉćÿüüüüþ.......",
    ".......ċýýýýüćĉĉĉċċċċċċċċċċċċċċĉĉĉćýüüüüċ.......",
    ".......ċýýýýüÿćĉĉċċċċċċċċċċċċċċĉĉććýüüüüċ.......",
    ".......ċýýýýüÿćĉĉċċċċċċċċċċċċċċĉĉćÿýüüüüċ.......",
    "........ċýýýýÿćĉĉċċċċċċċċċċċċċċĉĉćÿüüüüþ........",
    "........ċýýýýüÿćĉċċċċċċċċċċċċċċĉćÿýüüüüċ........",
    "........ċýýýýüÿćĉĉċċċċċċċċċċċċĉĉćÿýüüüýċ........",
    ".........ċýýýýÿććĉĉċċċċċċċċċċĉĉććÿüüüüċ.........",
    ".........ċýýýýüÿćĉĉĉċċċċċċċċĉĉĉćÿýüüüüċ.........",
    ".........ċýýýýüÿććĉĉĉĉċċċċĉĉĉĉććÿýüüüýċ.........",
    "..........ċýýýýüÿćĉĉĉĉĉĉĉĉĉĉĉĉćÿýüüüüċ..........",
    "..........ċþýýýüÿććĉĉĉĉĉĉĉĉĉĉććÿýüüüýċ..........",
    "...........ċüýýýüÿććĉĉĉĉĉĉĉĉććÿýüüüüċ...........",
    "...........ċþýýýüÿÿććĉĉĉĉĉĉććÿÿüüüüýċ...........",
    "............ċüýýüüÿććććĉĉććććÿýüüüüċ............",
    "............ċþüýýüüÿććććććććÿýüüüûýċ............",
    ".............ċþüüüüüÿććććććÿýüüûûýċ.............",
    "..............ċüüüüüÿÿććććÿÿýüûûûþ..............",
    "..............ċþüüüüüÿÿÿÿÿÿüüûûûþċ..............",
    "...............ċþüüüüüÿÿÿÿüüûûûþċ...............",
    "................ċþüüüüüüüüüûûûþċ................",
    ".................ċþüüüüüüûûûüþċ.................",
    "..................ċþüüüüüûûüþċ..................",
    "...................ċþüüüüüüþċ...................",
    "....................ċċþüüþċċ....................",
    "......................ċþþċ......................",
    "................................................"
  ],
  // 72. Sword (Kilic)
  [
    ".UUUVWWWWWWWWWWWWWWWWWWWWWWWVVVVVVVVVVVVVVVVVVV.",
    "WWWWWWWWWWWWWWWWWWWWWWWLLWWVVVVVVVVVVVVVVVVVVVVV",
    "WWWWWWWWWWWWWWWWWWWWWWL«ºLVVVVVVVVVVVVVVVVVVVVVV",
    "WWWWWWWWWWWWWWWWWWWWWL««ººLVVVVVVVVVVVVVVVVVVVVV",
    "WWWWWWWWWWWWWWWWWWWWWL««ººLVVVVVVVVVVVVVVVVVVVVV",
    "WWWWWWWWWWWWWWWWWWWWL«««ºººLVVVVVVVVVVVVVVVVVVVV",
    "WWWWWWWWWWWWWWWWWWWWWL««ººLVVVVVVVVVVVVVVVVVVVVV",
    "WWWWWWWWWWWWWWWWWWWWL«««ºººLVVVVVVVVVVVVVVVVVVVV",
    "WWWWWWWWLLWWWWWWWWWWVL««ººLVVVVVVVVVVVLLVVVVVVVV",
    "WWWWWWWL«ºLWWWWWWWWVL«««ºººLVVVVVVVVVL«ºLVVVVVVV",
    "WWWWWWWL«ºLWWWWWWWVVVL««ººLVVVVVVVVVVL«ºLVVVVVVV",
    "WWWWWWL««ººLWWWWWVVVL«««ºººLVVVVVVVVL««ººLVVVVVV",
    "WWWWWWWL«ºLWWWWWVVVVVL««ººLVVVVVVVVVVL«ºLVVVVVVV",
    "WWWWWWL««ººLWWWVVVVVL«««ºººLVVVVVVVVL««ººLVVVVVV",
    "WWWWWWWL«ºLWWWVVVVVVVL««ººLVVVVVVVVVVL«ºLVVVVVVV",
    "WWWWWWL««ººLWVVVVVVVL«««ºººLVVVVVVVVL««ººLVVVVVV",
    "WWWWWWWL«ºLWVVVVVVVVVL««ººLVVVVVVVVVVL«ºLVVVVVVV",
    "WWWWWWL««ººLVVVVVVVVL«««ºººLVVVVVVVVL««ººLVVVVVV",
    "WWWWWWWL«ºLVVVVVVVVVVL««ººLVVVVVVVVVVL«ºLVVVVVVV",
    "WWWWWWL««ººLVVVVVVVVL«««ºººLVVVVVVVVL««ººLVVVVVV",
    "WWWWWWWL«ºLVVVVVVVVVVL««ººLVVVVVVVVVVL«ºLVVVVVVV",
    "WWWWWWL««ººLVVVVVVVVL«««ºººLVVVVVVVVL««ººLVVVVVU",
    "WWWWWWVLLLLVVVVVVVVVVL««ººLVVVVVVVVVVLLLLVVVVVUU",
    "WWWWWVLL«ºLLVVVVVVVVL«««ºººLVVVVVVVVLL«ºLLVVVUUU",
    "WWWWVL««¥¥ººLVVVVVVVVL««ººLVVVVVVVVL««¥¥ººLVUUUU",
    "WWWVL««¥¥¥¥ººLVVVVVVL«««ºººLVVVVVVL««¥¥¥¥ººLUUUU",
    "WWVVVVVL¤¢LVVVVVVVVVVL««ººLVVVVVVVVVVL¤¢LVUUUUUU",
    "WVVVVVVL¤¢LVVVVVVVVVL«««ºººLVVVVVVVVVL¤¢LUUUUUUU",
    "VVVVVVVL¤¢LVVVVVVVVVVL««ººLVVVVVVVVVVL¤¢LUUUUUUU",
    "VVVVVVVL¤¢LVVVVVVVVVVLLLLLLVVVVVVVVVVL¤¢LUUUUUUU",
    "VVVVVVL«¥¥ºLVVVVVVVL««««ººººLVVVVVVVL«¥¥ºLUUUUUU",
    "VVVVVVVL«ºLVVVVVVL«««¥££¥¥¥ºººLVVVVVVL«ºLUUUUUUU",
    "VVVVVVVVLLVVVVVL««««££££¥¥¥¥ººººLVVVUULLUUUUUUUU",
    "VVVVVVVVVVVVVL««««££££££¥¥¥¥¥¥ººººLUUUUUUUUUUUUU",
    "VVVVVVVVVVVL««««££££££££¥¥¥¥¥¥¥¥ººººLUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVL¤¤¢¢LVVVVVVUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVL¤¤¢¢LVVVVVUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVL¤¤¢¢LVVVVUUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVL¤¤¢¢LVVVUUUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVL¤¤¢¢LVVUUUUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVL¤¤¢¢LVUUUUUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVL««¥¥ººLUUUUUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVL««ººLUUUUUUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVVLLLLUUUUUUUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVVVVUUUUUUUUUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVVVUUUUUUUUUUUUUUUUUUUUUUUUU",
    "VVVVVVVVVVVVVVVVVVVVVVUUUUUUUUUUUUUUUUUUUUUUUUUU",
    ".VVVVVVVVVVVVVVVVVVVVUUUUUUUUUUUUUUUUUUUUUUUUUU."
  ],
  // 73. Ring (Yuzuk)
  [
    "................................................",
    "................LLLLLLLLLLLLLLLL................",
    "..............LLTTTLKBKKKKBKLTTTLL..............",
    "............LLLTTTTLKYKKKKYKLTTTTLLL............",
    "..........LL.LTTTTLKKKKKKKKKKLTTTTL.LL..........",
    "........LL...LTTTTLYKKKKKKKKYLTTTTL...LL........",
    "........LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL........",
    "..........LLBBLBBBLYYYYYYYYYYLBBBLBBLL..........",
    "............LL.LBBLLYYYYYYYYLLBBL.LL............",
    "..............LLBBLLYYYYYYYYLLBBLL..............",
    "................LL.LLYYYYYYLL.LL................",
    "..................LLLLYYYYLLLL..................",
    "...................LLLLèèLLLL...................",
    "...................LèèLLLLèèL...................",
    "................LL£LèèèèèèèèL£LL................",
    "..............LL££££LLLLLLLL££££LL..............",
    ".............L£££èèè¥¥¥¥¥¥¥¥èèè£££L.............",
    "............L£££èè¥¥¥¥¥¥¥¥¥¥¥¥èè£££L............",
    "...........L££èè¥¥¥LLL.¥¥.LLL¥¥¥èè££L...........",
    "..........L££èè¥¥LL..........LL¥¥èè££L..........",
    ".........L££èè¥¥L..............L¥¥èè££L.........",
    ".........L£èè¥¥L................L¥¥èè£L.........",
    "........L££è¥¥L..................L¥¥è££L........",
    "........L£è¥¥L....................L¥¥è£L........",
    ".......L££è¥L......................L¥è££L.......",
    ".......L£è¥¥L......................L¥¥è£L.......",
    ".......££è¥¥........................¥¥è££.......",
    "......L££è¥L........................L¥è££L......",
    "......L££è¥L........................L¥è££L......",
    "......L££è¥L........................L¥è££L......",
    "......L£èè¥L........................L¥èè£L......",
    "......L££è¥L........................L¥è££L......",
    "......L££è¥L........................L¥è££L......",
    "......L££è¥L........................L¥è££L......",
    "......¥££è¥¥........................¥¥è££¥......",
    ".......L£è¥¥........................¥¥è£L.......",
    ".......L££è¥L......................L¥è££L.......",
    "........L£è¥¥L....................L¥¥è£L........",
    "........L££è¥¥L..................L¥¥è££L........",
    ".........L£èè¥¥L................L¥¥èè£L.........",
    ".........L££èè¥¥L..............L¥¥èè££L.........",
    "..........L££èè¥¥LL..........LL¥¥èè££L..........",
    "...........L££èè¥¥¥LLL....LLL¥¥¥èè££L...........",
    "............L£££èè¥¥¥¥¥¥¥¥¥¥¥¥èè£££L............",
    ".............L£££èèè¥¥¥¥¥¥¥¥èèè£££L.............",
    "..............LL££££èèèèèèèè££££LL..............",
    "................LL££££££££££££LL................",
    "...................LLLLLLLLLL..................."
  ],
  // 74. Crown (Tac)
  [
    ".²²¼¼²¼¼¼¼¼¼¼¼¼¼²¼¼¼¼¼¼¼¼¼¼¼¼¼¼²¼¼¼¼¼¼¼¼¼¼²¼¼²².",
    "²¼²²²²²¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼²²²²²¼²",
    "²²²²²²²²¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼²²²²²²²²",
    "²²²²²²²²²¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼²²²²²²²²²",
    "²²²²²²²²²²¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼²²²²²²²²²²",
    "¼²²²¼²²²²²²¼¼¼¼¼²¼¼¼¼¼¼¼¼¼¼¼¼¼¼²¼¼¼¼¼²²²²²²¼²²²¼",
    "²²²²²²²²²²²²¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼¼²²²²²²²²²²²²",
    "²¼²²²²²¼²²²²²¼¼¼¼¼¼¼¼¼¼LL¼¼¼¼¼¼¼¼¼¼²²²²²¼²²²²²¼²",
    "²²²¼²²²²²²²²²²¼¼¼¼¼¼LLL½½LLL¼¼¼¼¼¼²²²²²²²²²²¼²²²",
    "²²²²²²²²²²¼²²²²¼¼¼¼¼LL÷½½÷LL¼¼¼¼¼²²²²¼²²²²²²²²²²",
    "²²²²²²²¼²²¼²²²²²¼¼¼¼L¾¾½½¾¾L¼¼¼¼²²²²²¼²²¼²²²²²²²",
    "²¼²²¼²¼²²²²²LLLL²¼¼¼L¾×¾¾×¾L¼¼¼²LLLL²²²²²¼²¼²²¼²",
    "²²²²²²²²²²²L¾¾¾÷LL¼¼L¾¾½½¾¾L¼¼LL÷¾¾¾L²²²²²²²²²²²",
    "²²²²²²²²²²²L¾÷¾×L²²¼LL¾¾¾¾LL¼²²L×¾÷¾L²²²²²²²²²²²",
    "²²²²²²²²²²L¾×½÷¾×²²²LLL××LLL²²²×¾÷½×¾L²²²²²²²²²²",
    "²²¼²²²²²¼²²L¾××¾L²²²L½¾½½¾½L²²²L¾××¾L²²¼²²²²²¼²²",
    "¼¼¼¼LLLL¼³³L¾½½¾L³³LL¾½××½¾LL³³L¾½½¾L³³¼LLLL¼¼¼¼",
    "¼¼¼L÷¾¾¾L³LLLLLLL³³LL×÷××÷×LL³³LLLLLLL³L¾¾¾÷L¼¼¼",
    "¼¼¼L×½¾×L³³L¾¾××LL³LL×½÷÷½×LL³LL××¾¾L³³L×¾½×L¼¼¼",
    "¼¼¼L¾½¾÷L³LL½¾×÷LLL³L÷¾¾¾¾÷L³LLL÷×¾½LL³L÷¾½¾L¼¼¼",
    "¼¼¼LLLLL³¼LL½¾×½L³L³L÷½¾¾½÷L³L³L½×¾½LL¼³LLLLL¼¼¼",
    "¼¼¼L½×LL¼¼LL¾×¾÷L³L³L÷½¾¾½÷L³L³L÷¾×¾LL¼¼LL×½L¼¼¼",
    "¼¼¼L×¾½L¼LØL¾¾¾×LLØLL¾¾¾¾¾¾LLØLL×¾¾¾LØL¼L½¾×L¼¼¼",
    "¼¼³L÷×¾LLLØL÷¾½¾LLØLL¾×½½×¾LLØLL¾½¾÷LØLLL¾×÷L³¼¼",
    "¼¼¼L½¾×L¼LØLLLLßLLØLLLLLLLLLLØLLßLLLLØL¼L×¾½L¼¼¼",
    "¼¼¼L½÷¾LLØØLĐ»»»LLØLLª¾ÝÝ¾ªLLØLL»»»ĐLØØLL¾÷½L¼¼¼",
    "³¼¼L÷×¾LLØØLĐ»»ßLLØLLÝªÝÝªÝLLØLLß»»ĐLØØLL¾×÷L¼¼³",
    "³³¼L½¾¾LLØØLß»»»LØØØLªÝªªÝªLØØØL»»»ßLØØLL¾¾½L¼³³",
    "¼¼¼L¾÷½LLØØL»»»»LØØØLªÞÞÞÞªLØØØL»»»»LØØLL½÷¾L¼¼¼",
    "¼¼¼L¾¾×LLØØL»»»ßLØØØLÝªÞÞªÝLØØØLß»»»LØØLL×¾¾L¼¼¼",
    "¼¼¼L¾×¾LØØØLĐĐ»»LØØØLÝªªªªÝLØØØL»»ĐĐLØØØL¾×¾L¼¼¼",
    "¼¼³L×½×LØØØLLLLLLØØØLÞªÞÞªÞLØØØLLLLLLØØØL×½×L³¼¼",
    "³²²L½½¾LØØØL××÷¾LØØØLLLLLLLLØØØL¾÷××LØØØL¾½½L²²³",
    "³²²L¾×¾LØØØL¾×½×LØØØL×¾¾¾¾×LØØØL×½×¾LØØØL¾×¾L²²³",
    "³²³L¾¾÷LØØØL¾½××LØØØL¾¾¾¾¾¾LØØØL××½¾LØØØL÷¾¾L³²³",
    "³²²L¾¾¾LØØØL×¾¾×LØØØL½¾¾¾¾½LØØØL×¾¾×LØØØL¾¾¾L²²³",
    "²²²L½×¾LØØØL½¾÷½LØØØL¾¾½½¾¾LØØØL½÷¾½LØØØL¾×½L²²²",
    "²²²L¾¾÷LØØØL¾×¾¾LØØØL÷¾××¾÷LØØØL¾¾×¾LØØØL÷¾¾L²²²",
    "²²²LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL²²²",
    "²²³LLÝªªL¾×L»»ĐĐL¾÷½LªªÞÞªªL½÷¾LĐĐ»»L×¾LªªÝLL³²²",
    "²²²LLÝªªL¾½LĐĐß»L¾×½LÞªªªªÞL½×¾L»ßĐĐL½¾LªªÝLL²²²",
    "²²²LLªÞªL××Lß»ß»L×¾×LªªÞÞªªL×¾×L»ß»ßL××LªÞªLL²²²",
    "²²²LLªÝÞL÷¾L»»ßßL×¾½LªªÝÝªªL½¾×Lßß»»L¾÷LÞÝªLL²²²",
    "²²²LLªªªL¾¾Lß»ĐĐL×¾¾LªªªªªªL¾¾×LĐĐ»ßL¾¾LªªªLL²²²",
    "²³²LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL²³²",
    "²³³²L²²³³²²²²³²²²L²³²²²²²²²²³²L²²²³²²²²³³²²L²³³²",
    "²²²³²²²²²²²²²²²²³³³²²²³²²³²²²³³³²²²²²²²²²²²²³²²²",
    ".²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²².",
  ],
    // 75. Diamond (Elmas)
  [
    "................................................",
    "................................................",
    "................................................",
    "................................................",
    "............L..........L........................",
    "..........LLLLLLLLLLLLLLLLċLLLLLLLLLÿ...........",
    "..........Lÿ__ċċċċċċċċċċċċċĉLĉċċċċċċÿL..........",
    ".........Lÿ__ċċċċċĉċċċ_ċċċċċĉċĉĉċĉċċċÿL.........",
    "........Lÿċ_ċĉĉĉĉĉĉċ_ċċċĉċċċċĉĉĉĉĉĉċċċċL........",
    ".......LLċċċċĉĉĉĉċĉċ___ċċĉĉċċĉĉĉĉĉĉĉċċćL........",
    "......LLċċċĉĉċĉĉĉċ__ċċċċĉĉĉċċċċĉĉĉĉĉĉĉċććL......",
    "......Lċċċċĉċċĉĉĉċċ_ċċċċĉĉĉċċċĉĉĉĉĉĉĉĉĉĉćL......",
    ".....Lćċċċċċċċĉċ_____ċċċĉĉĉĉĉċċċććĉĉćććććÿÿ.....",
    "....Lćċċċċċċċċćċ_ĉ_ċĉċċċċċċċċċċċċĉććććććććÿL....",
    "....LÿÿÿććććććććĉĉĉĉĉĉĉĉĉććććććććÿÿÿÿÿÿÿÿÿÿL....",
    "....LÿÿÿÿÿććććććĉĉććććććÿćććÿÿććÿÿÿÿÿÿÿÿÿÿÿL....",
    ".....LććććććććććććććććććÿćÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿL.....",
    ".....LÿćććććććććććććććććÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿL.....",
    "......LÿÿćććććććććććććććÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿćÿL......",
    ".......ÿććÿććććććććććććććÿÿÿÿćÿÿÿÿÿÿÿÿÿÿL.......",
    ".......LLććÿćććććććććććććććććććÿÿÿÿÿÿÿÿLL.......",
    "........LÿćÿććććććććććććććććÿćÿÿÿÿÿÿÿÿÿL........",
    ".........Lÿćÿćććććÿććććććććććÿÿÿÿÿÿÿÿÿÿ.........",
    "..........ÿÿÿÿććććÿććććććććććÿÿÿÿÿÿÿÿL..........",
    "..........LÿćÿćĉćĉÿÿĉććććććÿćÿćÿćÿÿÿÿL..........",
    "...........LÿÿÿćĉĉćććĉććććććÿććććÿÿÿL...........",
    "............LÿÿÿĉććÿÿĉĉĉćććÿÿÿćććÿÿL............",
    ".............LÿÿćĉĉÿÿĉĉĉćććÿÿććÿÿÿL.............",
    ".............LÿÿÿćċćÿÿĉĉććÿÿÿćÿÿÿÿL.............",
    "..............ÿÿÿÿĉćÿććĉćććÿÿćÿÿLL..............",
    "...............LÿÿÿĉÿÿÿĉĉÿÿÿćÿÿÿL...............",
    "................LÿÿććÿÿÿćÿÿÿÿÿÿL................",
    "................LLÿÿćÿÿÿÿÿÿÿÿÿLL................",
    ".................LÿÿÿÿÿÿÿÿÿÿÿÿL.................",
    "..................LÿÿÿÿÿÿÿÿÿÿL..................",
    "..................LLÿÿÿÿÿÿÿÿLL..................",
    "...................LÿÿÿÿÿLÿÿL...................",
    "....................LLÿÿÿÿÿL....................",
    ".....................Lÿÿÿÿÿ.....................",
    ".....................LLÿÿLL.....................",
    "......................LÿLL......................",
    ".......................LLL......................",
    "........................L.......................",
    "................................................",
    "................................................",
    "................................................",
    "................................................",
    "................................................",
  ],
// 76. Coin (Para)
  [
    "................",
    "......DDDD......",
    "    DDDDDDDD    ",
    "  DDDDDDDDDDDD  ",
    " DDDDDDDDDDDDDD ",
    "DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD",
    " DDDDDDDDDDDDDD ",
    "  DDDDDDDDDDDD  ",
    "    DDDDDDDD    ",
    "      DDDD      ",
    "................",
    "................"
  ],
  // 77. Book (Kitap)
  [
    "................",
    "  RRRRRRRRRRRR  ",
    "  RRRRRRRRRRRR  ",
    "  RKKKKKKKKKRR  ",
    "  RKKKKKKKKKRR  ",
    "  RKKKKKKKKKRR  ",
    "  RKKKKKKKKKRR  ",
    "  RKKKKKKKKKRR  ",
    "  RKKKKKKKKKRR  ",
    "  RKKKKKKKKKRR  ",
    "  RKKKKKKKKKRR  ",
    "  RKKKKKKKKKRR  ",
    "  RKKKKKKKKKRR  ",
    "  RRRRRRRRRRRR  ",
    "  RRRRRRRRRRRR  ",
    "................"
  ],
  // 78. Pencil (Kalem)
  [
    ".............F..",
    "............FF..",
    "...........FFF..",
    "..........FFF...",
    ".........FFF....",
    "........FFF.....",
    ".......FFF......",
    "......FFF.......",
    ".....FFF........",
    "....FFF.........",
    "...FFF..........",
    "..FFF...........",
    ".FFF............",
    "NN..............",
    "................",
    "................"
  ],
  // 79. Paint Palette (Palet)
  [
    "................",
    "......NNNN......",
    "    NNNNNNNN    ",
    "  NNNNNNNNNNNN  ",
    " NNNNNNNNNNNNNN ",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    "NNNNNNNNNNNNNNNN",
    " NNNNNNNNNNNNNN ",
    "  NNNNNNNNNNNN  ",
    "    NNNNNNNN    ",
    "      NNNN      ",
    "................",
    "................"
  ],
  // 80. Camera (Kamera)
  [
    "................",
    "......MMMM......",
    "    MMMMMMMM    ",
    "  MMMMMMMMMMMM  ",
    " MMMMMMMMMMMMMM ",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    " MMMMMMMMMMMMMM ",
    "  MMMMMMMMMMMM  ",
    "    MMMMMMMM    ",
    "................",
    "................",
    "................"
  ],
  // 81. Light Bulb (Ampul)
  [
    "................",
    "......DDDD......",
    "    DDDDDDDD    ",
    "  DDDDDDDDDDDD  ",
    " DDDDDDDDDDDDDD ",
    "DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD",
    " DDDDDDDDDDDDDD ",
    "  DDDDDDDDDDDD  ",
    "    MMMMMMMM    ",
    "      MMMM      ",
    "      MMMM      ",
    "................"
  ],
  // 82. Candle (Mum)
  [
    "................",
    ".......F........",
    "......FFF.......",
    "......FFF.......",
    ".....KKKKK......",
    "    KKKKKKK     ",
    "    KKKKKKK     ",
    "    KKKKKKK     ",
    "    KKKKKKK     ",
    "    KKKKKKK     ",
    "    KKKKKKK     ",
    "    KKKKKKK     ",
    "    KKKKKKK     ",
    "    KKKKKKK     ",
    "   KKKKKKKKK    ",
    "................"
  ],
  // 83. Gift Box (Hediye)
  [
    "................",
    "  RRRRRRRRRRRR  ",
    "  RRRRRRRRRRRR  ",
    "  RRDDRRDDRRDR  ",
    "  RRDDRRDDRRDR  ",
    "  RRRRRRRRRRRR  ",
    "  RRRRRRRRRRRR  ",
    "  RRDDRRDDRRDR  ",
    "  RRDDRRDDRRDR  ",
    "  RRRRRRRRRRRR  ",
    "  RRRRRRRRRRRR  ",
    "  RRDDRRDDRRDR  ",
    "  RRDDRRDDRRDR  ",
    "  RRRRRRRRRRRR  ",
    "  RRRRRRRRRRRR  ",
    "................"
  ],
  // 84. Balloon (Balon)
  [
    "................",
    "......RRRR......",
    "    RRRRRRRR    ",
    "  RRRRRRRRRRRR  ",
    " RRRRRRRRRRRRRR ",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    "RRRRRRRRRRRRRRRR",
    " RRRRRRRRRRRRRR ",
    "  RRRRRRRRRRRR  ",
    "    RRRRRRRR    ",
    "      RRRR      ",
    "       RR       ",
    "       LL       "
  ],
  // 85. Umbrella (Semsiye)
  [
    "................",
    "......BBBB......",
    "    BBBBBBBB    ",
    "  BBBBBBBBBBBB  ",
    " BBBBBBBBBBBBBB ",
    "BBBBBBBBBBDDDDDD",
    "BBBBBBBBBBBBBBBB",
    "      MMMM      ",
    "      MMMM      ",
    "      MMMM      ",
    "      MMMM      ",
    "      MMMM      ",
    "      MMMM      ",
    "      MMMM      ",
    "     MMMM       ",
    "................"
  ],
  // 86. Anchor (Capa)
  [
    "................",
    "      MMMM      ",
    "      MMMM      ",
    "      MMMM      ",
    "      MMMM      ",
    "    MMMMMMMM    ",
    "  MMMMMMMMMMMM  ",
    "  MMMMMMMMMMMM  ",
    "  MMMMMMMMMMMM  ",
    "  MMMMMMMMMMMM  ",
    "  MMMMMMMMMMMM  ",
    "   MMMMMMMMMM   ",
    "    MMMMMMMM    ",
    "      MMMM      ",
    "                ",
    "................"
  ],
  // 87. Sailboat (Yelkenli)
  [
    "................",
    "       K        ",
    "      KK        ",
    "     KKK        ",
    "    KKKK        ",
    "   KKKKK        ",
    "  KKKKKK        ",
    " KKKKKKK        ",
    "KKKKKKKK        ",
    "       L        ",
    "  NNNNNNNNNNNN  ",
    "   NNNNNNNNNN   ",
    "    NNNNNNNN    ",
    "................",
    "................",
    "................"
  ],
  // 88. Rocket (Roket)
  [
    "................",
    "       R        ",
    "      RRR       ",
    "      RRR       ",
    "     KKKKK      ",
    "     KKKKK      ",
    "    KKKKKKK     ",
    "    KKKKKKK     ",
    "   KKKKKKKKK    ",
    "   KKKKKKKKK    ",
    "  KKKKKKKKKKK   ",
    "  RRRRRRRRRRR   ",
    "  RRR     RRR   ",
    "    FFFFFFF     ",
    "     FFFFF      ",
    "      FFF       "
  ],
  // 89. UFO (UFO)
  [
    "................",
    "......GGGG......",
    "    GGGGGGGG    ",
    "   GGGGGGGGGG   ",
    "  MMMMMMMMMMMM  ",
    " MMMMMMMMMMMMMM ",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    " MMMMMMMMMMMMMM ",
    "  MMMMMMMMMMMM  ",
    "   MMMMMMMMMM   ",
    "................",
    "................",
    "................",
    "................"
  ],
  // 90. Robot (Robot)
  [
    "................",
    "    MMMMMMMM    ",
    "   MMMMMMMMMM   ",
    "   MMDDMMDDMM   ",
    "   MMMMMMMMMM   ",
    "    MMMMMMMM    ",
    "      MMMM      ",
    "  MMMMMMMMMMMM  ",
    " MMMMMMMMMMMMMM ",
    " MMMMMMMMMMMMMM ",
    " MMMMMMMMMMMMMM ",
    "  MMMMMMMMMMMM  ",
    "   MMMMMMMMMM   ",
    "   MM      MM   ",
    "   MM      MM   ",
    "................"
  ],
  // 91. Controller (Konsol)
  [
    "................",
    "  BBBBBBBBBBBB  ",
    "  BBBBBBBBBBBB  ",
    "  BBBBBBBBBBBB  ",
    "  BBBBBBBBBBBB  ",
    "  BBBBBBBBBBBB  ",
    "  BBBBBBBBBBBB  ",
    "   BBBBBBBBBB   ",
    "    BBBBBBBB    ",
    "     BBBBBB     ",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................"
  ],
  // 92. Dice (Zar)
  [
    "................",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKLLKKKKLLKK  ",
    "  KKLLKKKKLLKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKLLLLKKKK  ",
    "  KKKKLLLLKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKLLKKKKLLKK  ",
    "  KKLLKKKKLLKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "................",
    "................",
    "................"
  ],
  // 93. Cup 2 (Kupa 2)
  [
    "................",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDD   ",
    "   DDDDDDDDD    ",
    "    DDDDDDD     ",
    "     DDDDD      ",
    "      DDD       ",
    "................",
    "................",
    "................",
    "................",
    "................"
  ],
  // 94. Medal (Madalya)
  [
    "................",
    "      RRRR      ",
    "      RRRR      ",
    "      RRRR      ",
    "      RRRR      ",
    "    DDDDDDDD    ",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDDD  ",
    "   DDDDDDDDDD   ",
    "    DDDDDDDD    ",
    "      DDDD      ",
    "                ",
    "................"
  ],
  // 95. Hourglass (Kum Saati)
  [
    "................",
    "  MMMMMMMMMMMM  ",
    "  MMMMMMMMMMMM  ",
    "   MMDDDDDDMM   ",
    "    MDDDDDD     ",
    "     MDDDD      ",
    "      MDD       ",
    "      MDD       ",
    "     MDDDD      ",
    "    MDDDDDD     ",
    "   MMDDDDDDMM   ",
    "  MMMMMMMMMMMM  ",
    "  MMMMMMMMMMMM  ",
    "................",
    "................",
    "................"
  ],
  // 96. Compass (Pusula)
  [
    "................",
    "......MMMM......",
    "    MMMMMMMM    ",
    "  MMMMMMMMMMMM  ",
    " MMMMMMRRMMMMMM ",
    "MMMMMMRRRRMMMMMM",
    "MMMMMMRRRRMMMMMM",
    "MMMMMRRRRRRMMMMM",
    "MMMMMMMMMMMMMMMM",
    "MMMMMMMMMMMMMMMM",
    " MMMMMMMMMMMMMM ",
    "  MMMMMMMMMMMM  ",
    "    MMMMMMMM    ",
    "      MMMM      ",
    "................",
    "................"
  ],
  // 97. Note (Nota)
  [
    "................",
    "        LLLLL   ",
    "       LLLLLL   ",
    "       LL  LL   ",
    "       LL  LL   ",
    "       LL  LL   ",
    "       LL  LL   ",
    "       LL  LL   ",
    "     LLLL  LL   ",
    "    LLLLL  LL   ",
    "    LLLLL  LL   ",
    "     LLLL  LL   ",
    "           LL   ",
    "         LLLL   ",
    "        LLLLL   ",
    "        LLLLL   "
  ],
  // 98. Bell (Zil)
  [
    "................",
    "      DDDD      ",
    "      DDDD      ",
    "     DDDDDD     ",
    "     DDDDDD     ",
    "    DDDDDDDD    ",
    "    DDDDDDDD    ",
    "   DDDDDDDDDD   ",
    "   DDDDDDDDDD   ",
    "  DDDDDDDDDDDD  ",
    "  DDDDDDDDDDDD  ",
    "DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD",
    "      DDDD      ",
    "       DD       ",
    "................"
  ],
  // 99. Envelope (Zarf)
  [
    "................",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "  KKKKKKKKKKKK  ",
    "................"
  ],
  // 100. Flag (Bayrak)
  [
    "................",
    "  RRRRRRRRRRR   ",
    "  RRRRRRRRRRR   ",
    "  RRRRRRRRRRR   ",
    "  RRRRRRRRRRR   ",
    "  RRRRRRRRRRR   ",
    "  RRRRRRRRRRR   ",
    "  RRRRRRRRRRR   ",
    "  L             ",
    "  L             ",
    "  L             ",
    "  L             ",
    "  L             ",
    "  L             ",
    "  L             ",
    "................"
  ]
];

List<String> adjustColorCounts(List<String> grid, Map<String, int> charToColor) {
  int numRows = grid.length;
  int numCols = grid[0].length;
  List<List<String>> cells = grid.map((r) => r.split('')).toList();

  List<Point> getPositions(String char) {
    List<Point> pos = [];
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        if (cells[r][c] == char) {
          pos.add(Point(r, c));
        }
      }
    }
    return pos;
  }

  Map<String, int> counts = {};
  for (int r = 0; r < numRows; r++) {
    for (int c = 0; c < numCols; c++) {
      String char = cells[r][c];
      if (charToColor.containsKey(char)) {
        counts[char] = (counts[char] ?? 0) + 1;
      }
    }
  }

  if (counts.isEmpty) return grid;

  // Identify background color (color with the most pixels)
  String bgChar = counts.keys.first;
  int maxBgCount = counts[bgChar]!;
  counts.forEach((char, count) {
    if (count > maxBgCount) {
      maxBgCount = count;
      bgChar = char;
    }
  });

  counts.forEach((char, count) {
    int target = count;
    if (char == bgChar) {
      // Background must be: 40 or >= 70 (multiple of 10) to guarantee >= 6 weapons
      if (target <= 40) {
        target = 40;
      } else {
        if (target < 70) {
          target = 70;
        } else if (target % 10 != 0) {
          target = ((target + 9) ~/ 10) * 10;
        }
      }
    } else {
      // Non-background must be a multiple of 5, >= 10
      if (target < 10) {
        target = 10;
      } else if (target % 5 != 0) {
        target = ((target + 4) ~/ 5) * 5;
      }
    }

    int diff = target - count;
    if (diff > 0) {
      List<Point> current = getPositions(char);
      List<Point> candidates = [];
      Set<String> visited = current.map((p) => '${p.r},${p.c}').toSet();

      List<Point> dirs = [
        Point(0, 1), Point(0, -1), Point(1, 0), Point(-1, 0),
        Point(1, 1), Point(1, -1), Point(-1, 1), Point(-1, -1)
      ];

      List<Point> queue = List.from(current);
      int qIdx = 0;
      while (qIdx < queue.length && candidates.length < diff) {
        Point p = queue[qIdx++];
        for (var d in dirs) {
          int nr = p.r + d.r;
          int nc = p.c + d.c;
          if (nr >= 0 && nr < numRows && nc >= 0 && nc < numCols) {
            String key = '$nr,$nc';
            if (!visited.contains(key)) {
              visited.add(key);
              if (cells[nr][nc] == '.') {
                candidates.add(Point(nr, nc));
                queue.add(Point(nr, nc));
                if (candidates.length == diff) break;
              }
            }
          }
        }
      }

      if (candidates.length < diff) {
        for (int r = 0; r < numRows; r++) {
          for (int c = 0; c < numCols; c++) {
            if (cells[r][c] == '.' && !visited.contains('$r,$c')) {
              candidates.add(Point(r, c));
              if (candidates.length == diff) break;
            }
          }
          if (candidates.length == diff) break;
        }
      }

      for (var p in candidates) {
        cells[p.r][p.c] = char;
      }
    }
  });

  int totalTarget = 0;
  counts.clear();

  for (int r = 0; r < numRows; r++) {
    for (int c = 0; c < numCols; c++) {
      String char = cells[r][c];
      if (charToColor.containsKey(char)) {
        counts[char] = (counts[char] ?? 0) + 1;
        totalTarget++;
      }
    }
  }

  if (totalTarget < 60) {
    int C = counts[bgChar] ?? 0;
    int minX = 60 - totalTarget;
    int X = minX;
    while (true) {
      int newBg = C + X;
      if (newBg == 40 || (newBg >= 70 && newBg % 10 == 0)) {
        break;
      }
      X++;
    }

    List<Point> current = getPositions(bgChar);
    List<Point> candidates = [];
    Set<String> visited = current.map((p) => '${p.r},${p.c}').toSet();

    List<Point> dirs = [
      Point(0, 1), Point(0, -1), Point(1, 0), Point(-1, 0),
      Point(1, 1), Point(1, -1), Point(-1, 1), Point(-1, -1)
    ];

    List<Point> queue = List.from(current);
    int qIdx = 0;
    while (qIdx < queue.length && candidates.length < X) {
      Point p = queue[qIdx++];
      for (var d in dirs) {
        int nr = p.r + d.r;
        int nc = p.c + d.c;
        if (nr >= 0 && nr < numRows && nc >= 0 && nc < numCols) {
          String key = '$nr,$nc';
          if (!visited.contains(key)) {
            visited.add(key);
            if (cells[nr][nc] == '.') {
              candidates.add(Point(nr, nc));
              queue.add(Point(nr, nc));
              if (candidates.length == X) break;
            }
          }
        }
      }
    }

    if (candidates.length < X) {
      for (int r = 0; r < numRows; r++) {
        for (int c = 0; c < numCols; c++) {
          if (cells[r][c] == '.' && !visited.contains('$r,$c')) {
            candidates.add(Point(r, c));
            if (candidates.length == X) break;
          }
        }
        if (candidates.length == X) break;
      }
    }

    for (var p in candidates) {
      cells[p.r][p.c] = bgChar;
    }
  }

  return cells.map((row) => row.join('')).toList();
}

class Point {
  final int r;
  final int c;
  Point(this.r, this.c);
}