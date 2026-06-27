import 'dart:io';

void main() {
  final List<String> originalGrid = [
    "........................K.......................",
    ".......................KD.......................",
    "...............NNN.Nc.KccD..cN.NNN..............",
    "...........KNFNNFFNFcNNccDNNcFNFFNNcN...........",
    "..........KNNNFFcNFFcFFcccFFcFFNDFFNNNK.........",
    ".......NFFFFFFFFFFNFcNFFcFFNcFNFFFFFFFFFFN......",
    "........NFFNFNNFFFFNFNFFcFFFFNFFFFNNNNFFN.......",
    ".......NDFNFFFFDNFFNNFNNFNFFNNFFNDFFFcNFcN......",
    ".....NccDFcFFFNFFNNNNNNNFNNNNNNNFFNFFFNFcccN....",
    "....NFFFNNNFNNNFFFNNFNNNNNNNFNNFFFNNFFNNNFFFN...",
    ".....KNFNNNFNNNNNNFDDDFFNFFDDDFNFNNNNFNNNFNK....",
    "......NFFFFNFNFNNFDDDDDDFDDDDDDFNNFNFNFFFcN.....",
    "....KcFFFNNNNNNNFDDKFKDDFDDKFKDDFNNFNNNNFFFD....",
    "...KDFFNFNNNNFNFDFFcFKDFFcDKFccFFFNFNNNNFNFFD...",
    "..NcFNFFNNNFFNNFNNFNcFFDFDFFcNFNNFNNFFNNNFFNFcN.",
    ".KFFFFFNNNFFFNFFFKccNccDDDFcNcDKFFFNFFFNNNFFFFF.",
    "....NNFFFcFFNFFFDFKKKcccccDcKKKFDFFFNFFcFFFNN...",
    "...NFFFNNFNFFNDFcccccFcccccFcccccFDFFFNFNNFFFN..",
    "...cFNNNNcFFFNNFFFccKFccccccKccFFcNFFFFcNNNFFc..",
    "..NFNFNNFFFFNFNccFFKKNFFNFFNKKFFccNFNFFFFNNFNFN.",
    ".NFFFFNFFFFNFFFNFFNKKKNNNNNKKKNFFNFFFNFFFFNFFFFN",
    ".KNNNFNNNNFFFNFNNFNKKKKcNcKKKKNFNNFNFFFNNNNFNNNK",
    "....FFFNNFFFNFNNNNNKKKKcNcKKKKNNFNNFNFFFNNFFF...",
    "...NFFNNcFFNFFNNNNNNcccNcNcccNNNFNNFFNFFcNNFFN..",
    "...FFNNNNNNFFFFFNNNNccKKKKKccNNNNFFFFFNNNNNNFF..",
    "...FFNNFFNcFFFFFNNNNccKKKKKccNNNNFFFFFcNFFNNFF..",
    "...NNK.FFNFFFcFNNNNNNNccKccNNNNNNNFDFFFNFF.cNN..",
    ".......FNNFFNFNNNNNNNNNcccNNNFNNNFNFNFFNNF......",
    "......NNNNNFDFFNNNNNNNNNNNNNFNNNNNFFDFNNNNN.....",
    ".....KNN.NFFcFFFNFNNNFNNNNFNNNNFNNFFcFFN.NN.....",
    ".........NcFDFFFNFFNNFFFNFFFNNFFFFFFDFcN........",
    "........cccFNFFFFFFFNNFFNFFNNFNFFFFFNFNcN.......",
    "......NccDNFFcNNFNNFNNFFFFFNNFNNFNNcFcNDDcN.....",
    ".....NcDDDNcFFFFFNNFFNNFFFNNFFNNFFFFFcNDDDcN....",
    ".....ccDDDFccFFFNNFNFNNNFNNNFNFNFFFFccccDDcc....",
    ".....cccccFNcDccFFFNFNNNFNNNFNFFFDFccNFccccc....",
    ".....cccccFNccccFFFNNNNNNNNNNNFFFccccFFccccc....",
    ".....cFFFFFFcccccFFNNNNNNNNNNNFFccccNFFFFFFc....",
    ".....NFFFFFFNcFcFFFNNNNNNNNNNNFFFFccNFFFFFFN....",
    ".....cFFFFFFFcFFFFFNNFFNNNFFNNFFFFFcFFFFFFF.....",
    "......NFFFFFFcFFFFFNNFFFNFFFNNFFFFFNFFFFFFN.....",
    ".......NFFFFFNFFFFFNNFFFFFFFNFFFFFFNFFFFFN......",
    "........NFFFFNFFFFFFNNNNNNNNNFFFFFFNFFFFN.......",
    ".......KNFNNFNFFFFFFNNNNNNNNNFFFFFFNFNNFN.......",
    "......cKKNccFNFFFFFFNNNNNNNNNFFFFFFNFccNKKK.....",
    ".....NNcccccNKKKKKKccNNNNNNNccKKNKKKNcccccFN....",
    ".....NccccccKNKcKKcccNcNNNKNcccKKcKNKccccccN....",
    "............NNcccccccN.....NccccNccNN..........."
  ];

  final List<String> modifiedGrid = [];
  final finalCounts = {'<': 0, '@': 0, '&': 0, '.': 0};

  for (int y = 0; y < originalGrid.length; y++) {
    final row = originalGrid[y];
    final sb = StringBuffer();
    for (int x = 0; x < row.length; x++) {
      final char = row[x];
      if (char == '.') {
        String bgChar;
        if (y < 18) {
          bgChar = '<';
        } else if (y < 34) {
          bgChar = '@';
        } else {
          bgChar = '&';
        }

        // Place 3 dots at symmetric corner/edge positions:
        // For J (<): 1 dot at top-left corner [0, 0]
        if (y == 0 && x == 0) {
          bgChar = '.';
        }
        // For X (@): 2 dots at the outer left/right of row 19 [18, 0] and [18, 47]
        else if (y == 18 && (x == 0 || x == 47)) {
          bgChar = '.';
        }

        sb.write(bgChar);
        finalCounts[bgChar] = finalCounts[bgChar]! + 1;
      } else {
        sb.write(char);
      }
    }
    modifiedGrid.add(sb.toString());
  }

  print('Tuned counts:');
  print('<: ${finalCounts['<']} (mod 5 = ${finalCounts['<']! % 5})');
  print('@: ${finalCounts['@']} (mod 5 = ${finalCounts['@']! % 5})');
  print('&: ${finalCounts['&']} (mod 5 = ${finalCounts['&']! % 5})');
  print('Dots: ${finalCounts['.']}');

  print('\n=== Generated Grid ===');
  for (final row in modifiedGrid) {
    print('    "$row",');
  }
}
