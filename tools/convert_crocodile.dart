import 'dart:io';
import 'dart:collection';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\207310fe-d18b-41db-9e82-841d9e42a8ad\\media__1782477838029.jpg';
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

  // Crocodile Palette Mapping:
  final colorMap = {
    12: [18, 19, 26],     // Black outline (L)
    45: [27, 94, 32],     // Koyu Cam Yesili (s)
    44: [46, 125, 50],    // Cam Yesili (r)
    43: [102, 187, 106],  // Acik Cam Yesili (q)
    46: [93, 64, 55],     // Govde Rengi / Brown scales (t)
    42: [255, 231, 181],  // Cream underbelly (p)
    1: [255, 77, 103],    // Kirmizi / Mouth inside (A)
    4: [255, 212, 71],    // Sari / Eyes (D)
    11: [247, 248, 255],  // White teeth/claws (K)
  };

  final colorToChar = {
    12: 'L',
    45: 's',
    44: 'r',
    43: 'q',
    46: 't',
    42: 'p',
    1: 'A',
    4: 'D',
    11: 'K',
  };

  // Perform BFS Flood-fill from corners to identify background pixels (solid black)
  final isBg = List.generate(size, (_) => List<bool>.filled(size, false));
  final queue = Queue<Point>();

  // Helper to check if pixel is black/dark background
  bool isDark(int x, int y) {
    final pixel = resized.getPixel(x, y);
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    // Distance to absolute black
    return (r * r + g * g + b * b) < 2500; // threshold
  }

  // Seed corners
  final corners = [
    Point(0, 0),
    Point(size - 1, 0),
    Point(0, size - 1),
    Point(size - 1, size - 1)
  ];

  for (final c in corners) {
    if (isDark(c.x, c.y)) {
      queue.add(c);
      isBg[c.y][c.x] = true;
    }
  }

  final dx = [0, 0, 1, -1];
  final dy = [1, -1, 0, 0];

  while (queue.isNotEmpty) {
    final curr = queue.removeFirst();
    for (int i = 0; i < 4; i++) {
      final nx = curr.x + dx[i];
      final ny = curr.y + dy[i];
      if (nx >= 0 && nx < size && ny >= 0 && ny < size) {
        if (!isBg[ny][nx] && isDark(nx, ny)) {
          isBg[ny][nx] = true;
          queue.add(Point(nx, ny));
        }
      }
    }
  }

  // Generate character grid
  final List<String> grid = [];
  final colorCounts = <int, int>{};

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

        sb.write(colorToChar[closestId] ?? '.');
        colorCounts[closestId] = (colorCounts[closestId] ?? 0) + 1;
      }
    }
    grid.add(sb.toString());
  }

  // Output level representation
  print('=== Grid ===');
  for (final row in grid) {
    print('    "$row",');
  }

  print('\n=== Color Runs ===');
  for (var entry in colorCounts.entries) {
    int count = entry.value;
    print('Color ${entry.key}: $count');
  }
}

class Point {
  final int x;
  final int y;
  Point(this.x, this.y);
}
