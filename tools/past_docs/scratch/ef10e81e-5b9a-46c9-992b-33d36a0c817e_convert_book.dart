import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\ef10e81e-5b9a-46c9-992b-33d36a0c817e\\media__1782394127125.jpg';
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

  final size = 48;
  final resized = img.copyResize(image, width: size, height: size);

  // LevelData color values
  final colorMap = {
    1: [255, 77, 103],    // 0xFFFF4D67
    2: [66, 165, 255],    // 0xFF42A5FF
    3: [66, 232, 138],    // 0xFF42E88A
    4: [255, 212, 71],    // 0xFFFFD447
    5: [176, 108, 255],   // 0xFFB06CFF
    6: [255, 138, 61],    // 0xFFFF8A3D
    7: [56, 232, 212],    // 0xFF38E8D4
    8: [255, 122, 200],   // 0xFFFF7AC8
    9: [168, 240, 74],    // 0xFFA8F04A
    10: [154, 167, 255],  // 0xFF9AA7FF
    11: [247, 248, 255],  // 0xFFF7F8FF
    12: [18, 19, 26],     // 0xFF12131A
    13: [141, 153, 174],  // 0xFF8D99AE
    14: [122, 78, 45],    // 0xFF7A4E2D
    15: [62, 70, 90],     // 0xFF3E465A
    16: [23, 33, 58],     // 0xFF17213A
    17: [10, 132, 255],   // 0xFF0A84FF
    18: [94, 92, 230],    // 0xFF5E5CE6
    19: [216, 216, 222],  // 0xFFD8D8DE
    20: [234, 251, 252],  // 0xFFEAFBFC
    21: [15, 107, 122],   // 0xFF0F6B7A
    22: [20, 150, 168],   // 0xFF1496A8
    23: [29, 183, 200],   // 0xFF1DB7C8
    24: [143, 220, 232],  // 0xFF8FDCE8
    25: [121, 215, 242],  // 0xFF79D7F2
    26: [169, 201, 185],  // 0xFFA9C9B9
    27: [246, 182, 110],  // 0xFFF6B66E
    28: [45, 41, 37],     // 0xFF2D2925
    29: [255, 178, 95],   // 0xFFFFB25F
    30: [245, 162, 143],  // 0xFFF5A28F
    31: [243, 231, 208],  // 0xFFF3E7D0
    32: [215, 131, 72],   // 0xFFD78348
    33: [185, 177, 163],  // 0xFFB9B1A3
    34: [217, 106, 89],   // 0xFFD96A59
    35: [220, 223, 216],  // 0xFFDCDFD8
    36: [11, 16, 32],     // 0xFF0B1020
    37: [90, 30, 24],     // 0xFF5A1E18
    38: [143, 51, 18],    // 0xFF8F3312
    39: [184, 90, 19],    // 0xFFB85A13
    40: [228, 127, 18],   // 0xFFE47F12
    41: [244, 165, 30],   // 0xFFF4A51E
    42: [255, 231, 181],  // 0xFFFFE7B5
  };

  // Build char list mapper
  final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxy';
  final colorToChar = <int, String>{};
  for (var i = 0; i < chars.length; i++) {
    colorToChar[i + 1] = chars[i];
  }

  // Flood fill algorithm to detect outer background (white/light colors)
  final visited = List.generate(size, (_) => List.generate(size, (_) => false));
  final isBg = List.generate(size, (_) => List.generate(size, (_) => false));

  // A helper function to check if a pixel color is close to white/light-gray background
  bool isWhiteBg(int x, int y) {
    final pixel = resized.getPixel(x, y);
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    // Background is generally very white, e.g. R, G, B > 230
    return r > 230 && g > 230 && b > 230;
  }

  void floodFill(int startX, int startY) {
    final queue = <List<int>>[];
    queue.add([startX, startY]);
    visited[startY][startX] = true;

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final cx = current[0];
      final cy = current[1];

      if (isWhiteBg(cx, cy)) {
        isBg[cy][cx] = true;

        // check 4-neighbors
        final neighbors = [
          [cx + 1, cy],
          [cx - 1, cy],
          [cx, cy + 1],
          [cx, cy - 1]
        ];

        for (final n in neighbors) {
          final nx = n[0];
          final ny = n[1];
          if (nx >= 0 && nx < size && ny >= 0 && ny < size) {
            if (!visited[ny][nx]) {
              visited[ny][nx] = true;
              queue.add([nx, ny]);
            }
          }
        }
      }
    }
  }

  // Run flood fill from the 4 corners
  if (!visited[0][0]) floodFill(0, 0);
  if (!visited[0][size - 1]) floodFill(size - 1, 0);
  if (!visited[size - 1][0]) floodFill(0, size - 1);
  if (!visited[size - 1][size - 1]) floodFill(size - 1, size - 1);

  // Generate the character grid
  final List<String> grid = [];
  for (int y = 0; y < size; y++) {
    final StringBuffer sb = StringBuffer();
    for (int x = 0; x < size; x++) {
      if (isBg[y][x]) {
        sb.write('.');
      } else {
        final pixel = resized.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Find closest color id
        int closestId = 12; // default black outline
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

        sb.write(colorToChar[closestId] ?? '.');
      }
    }
    grid.add(sb.toString());
  }

  // Output as Dart list of strings
  for (final row in grid) {
    print('        "$row",');
  }
}
