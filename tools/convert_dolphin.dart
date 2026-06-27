import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\207310fe-d18b-41db-9e82-841d9e42a8ad\\media__1782482401913.jpg';
  final file = File(imagePath);
  if (!file.existsSync()) {
    print('Error: Image file not found at $imagePath');
    exit(1);
  }

  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Error: Could not decode image');
    exit(1);
  }

  final topLeft = image.getPixel(0, 0);
  int startX = 0;
  int startY = 0;
  int width = image.width;
  int height = image.height;

  if (topLeft.r > 240 && topLeft.g > 240 && topLeft.b > 240) {
    int minX = image.width;
    int maxX = 0;
    int minY = image.height;
    int maxY = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        if (pixel.r < 240 || pixel.g < 240 || pixel.b < 240) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    startX = minX;
    startY = minY;
    width = maxX - minX + 1;
    height = maxY - minY + 1;
  }

  final cropped = img.copyCrop(image, x: startX, y: startY, width: width, height: height);
  final size = 48;
  final resized = img.copyResize(cropped, width: size, height: size);

  // Palette color definitions
  final colorMap = {
    11: [247, 248, 255],  // White (K)
    12: [18, 19, 26],      // Black/Outline (L)
    5: [176, 108, 255],    // Purple (E)
    10: [154, 167, 255],   // Lavender (J)
    15: [108, 122, 137],   // Slate Grey (O)
    16: [44, 94, 138],     // Indigo Blue (P)
    2: [66, 165, 255],     // Mavi (B)
    21: [15, 107, 122],    // Teal Koyu (U)
    22: [20, 150, 168],    // Teal Orta (V)
    23: [29, 183, 200],    // Teal Acik (W)
    24: [143, 220, 232],   // Light Teal/Splash (X)
    25: [121, 215, 242],   // Sky Blue (Y)
    30: [245, 162, 143],   // Peach/Pink (d)
    31: [243, 231, 208],   // Pale Sun Cream (e)
    34: [217, 106, 89],    // Sunset Coral (h)
    36: [11, 16, 32],      // Deep Navy/Dolphin back (j)
    42: [255, 231, 181],   // Cream (p)
    48: [255, 179, 71],    // Sun Orange (w)
  };

  final colorToChar = {
    11: 'K', 12: 'L', 5: 'E', 10: 'J', 15: 'O', 16: 'P', 2: 'B', 21: 'U',
    22: 'V', 23: 'W', 24: 'X', 25: 'Y', 30: 'd', 31: 'e', 34: 'h', 36: 'j',
    42: 'p', 48: 'w'
  };

  final charToColor = colorToChar.map((k, v) => MapEntry(v, k));

  // Initialize raw grid
  final List<List<String>> grid = List.generate(size, (y) {
    return List.generate(size, (x) {
      final pixel = resized.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      int closestId = 12;
      double minDistance = double.maxFinite;

      for (var entry in colorMap.entries) {
        final c = entry.value;
        final dist = (r - c[0]) * (r - c[0]) +
                     (g - c[1]) * (g - c[1]) +
                     (b - c[2]) * (b - c[2]);
        if (dist < minDistance) {
          minDistance = dist.toDouble();
          closestId = entry.key;
        }
      }
      return colorToChar[closestId]!;
    });
  });

  // Force 4 corners to be empty '.'
  grid[0][0] = '.';
  grid[0][size - 1] = '.';
  grid[size - 1][0] = '.';
  grid[size - 1][size - 1] = '.';

  // 1. Merge minor colors to keep the level clean
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final c = grid[y][x];
      if (c == 'w' || c == 'h') {
        grid[y][x] = 'd'; // Merge orange/coral sunset colors to peach pink 'd'
      }
      if (c == 'W') {
        grid[y][x] = 'V'; // Merge light teal wave 'W' to mid teal wave 'V'
      }
      if (c == 'E') {
        grid[y][x] = 'J'; // Merge purple sky 'E' to lavender sky 'J'
      }
      if (c == 'j') {
        grid[y][x] = 'P'; // Merge navy dolphin 'j' to indigo dolphin 'P'
      }
    }
  }

  // Count occurrences helper
  int countChar(String char) {
    int count = 0;
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        if (grid[y][x] == char) count++;
      }
    }
    return count;
  }

  // Get neighbors helper
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

  // Background colors
  final bgColors = {'J', 'e', 'd', 'Y', 'B', 'V'};

  // 2. Balance foreground colors (K, L, O, P, X, p, U)
  final fgColors = ['K', 'L', 'O', 'P', 'X', 'p', 'U'];
  for (final char in fgColors) {
    int count = countChar(char);
    if (count == 0) continue;
    int rem = count % 5;
    if (rem == 0) continue;

    if (rem < 3) {
      // Decrease count to nearest multiple of 5
      int diff = rem;
      int removedCount = 0;
      for (int y = 0; y < size && removedCount < diff; y++) {
        for (int x = 0; x < size && removedCount < diff; x++) {
          if (grid[y][x] == char) {
            // Find a neighbor that is a background color
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
      // Increase count to nearest multiple of 5
      int diff = 5 - rem;
      int addedCount = 0;
      for (int y = 0; y < size && addedCount < diff; y++) {
        for (int x = 0; x < size && addedCount < diff; x++) {
          if (grid[y][x] == char) {
            // Find a background color neighbor and turn it to char
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

  // 3. Balance background colors sequentially:
  // J -> balance with e
  // e -> balance with d
  // d -> balance with Y
  // Y -> balance with B
  // B -> balance with V
  // V -> automatically balanced because all other colors are multiples of 5 and total cells are 2304 - 4 = 2300.
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
      // Decrease by converting rem cells of char to nextChar
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
      // Increase by converting 5 - rem cells of nextChar to char
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

  // Print final grid
  print('=== Perfect Balanced Dolphin Grid ===');
  for (final row in grid) {
    final rowStr = row.join('');
    print('    "$rowStr",');
  }

  print('\n=== Perfect Balanced Color Runs ===');
  int totalTargets = 0;
  for (final char in colorToChar.values) {
    int count = countChar(char);
    if (count > 0) {
      final colorId = charToColor[char]!;
      print('Color $colorId ($char): $count');
      totalTargets += count;
    }
  }
  print('Total target cells: $totalTargets (should be 2300)');
}
