import 'dart:io';

void main() {
  // Let's reload build_levels.dart since it was modified by the previous run,
  // but we want to apply the remaining fixes. Or we can just restore/write it clean.
  // Actually, let's just write the fix script to do replacements on the CURRENT build_levels.dart.
  final file = File('build_levels.dart');
  var content = file.readAsStringSync();

  // Fix Animal 46 (Kizil Tilki) row 4, 5, 12, 13
  content = content.replaceFirst(
    '  // 46. Red Fox\n  [\n    "................",\n    "..F..........F..",\n    "..FF........FF..",\n    "..FFF......FFF..",\n    ".FFFFFFFFFFFFF.",\n    ".FFFFFFFFFFFFF.",\n    "FFFFFFFFFFFFFFFF",\n    "FFFLLFFFFFFLLFFF",\n    "FFFFFFFFFFFFFFFF",\n    "FFFFFFFFFFFFFFFF",\n    ".FFFFFFFLLFFFFF.",\n    "..FFFFFKKKFFFF..",\n    "...FFFKKKKKFFF...",\n    "....FKKKKKKKFFF..",',
    '  // 46. Red Fox\n  [\n    "................",\n    "..F..........F..",\n    "..FF........FF..",\n    "..FFF......FFF..",\n    ".FFFFFFFFFFFFFF.",\n    ".FFFFFFFFFFFFFF.",\n    "FFFFFFFFFFFFFFFF",\n    "FFFLLFFFFFFLLFFF",\n    "FFFFFFFFFFFFFFFF",\n    "FFFFFFFFFFFFFFFF",\n    ".FFFFFFFLLFFFFF.",\n    "..FFFFFKKKFFFF..",\n    "...FFFKKKKKFFF..",\n    "....FKKKKKKFFF..",'
  );

  // Fix Object 56 (Karpuz) row 8 (which was changed to 17 characters in the last run)
  content = content.replaceFirst(
    '" CAAALAAAALAAAAC "',
    '" CAAALAAAALAAAC "'
  );

  file.writeAsStringSync(content);
  print('Remaining fixes applied successfully!');
}
