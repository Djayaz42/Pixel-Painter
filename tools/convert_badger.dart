import 'dart:io';
import 'dart:collection';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\207310fe-d18b-41db-9e82-841d9e42a8ad\\media__1782478604870.jpg';
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

  // 1. Bounding box detector for auto-cropping
  final bgR = 254;
  final bgG = 251;
  final bgB = 230;

  int minX = image.width;
  int maxX = 0;
  int minY = image.height;
  int maxY = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      final distSq = (r - bgR) * (r - bgR) + (g - bgG) * (g - bgG) + (b - bgB) * (b - bgB);
      if (distSq >= 900) { // Distance threshold of 30
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  // Add a small padding (e.g. 5% of width/height) to the crop region
  final padW = ((maxX - minX) * 0.05).round();
  final padH = ((maxY - minY) * 0.05).round();
  minX = math.max(0, minX - padW);
  maxX = math.min(image.width - 1, maxX + padW);
  minY = math.max(0, minY - padH);
  maxY = math.min(image.height - 1, maxY + padH);

  final cropW = maxX - minX + 1;
  final cropH = maxY - minY + 1;

  print('Auto-cropping bounding box: x=$minX, y=$minY, w=$cropW, h=$cropH');
  final cropped = img.copyCrop(image, x: minX, y: minY, width: cropW, height: cropH);

  final size = 48;
  final resized = img.copyResize(cropped, width: size, height: size);

  // Palette mapping:
  final colorMap = {
    12: [18, 19, 26],     // Black outline (L)
    15: [108, 122, 137],  // Slate Grey (O)
    46: [93, 64, 55],     // Dark Brown (t)
    42: [255, 231, 181],  // Cream (p)
    11: [247, 248, 255],  // White (K)
    40: [228, 127, 18],   // Dark Orange / Tail (n)
  };

  final colorToChar = {
    12: 'L',
    15: 'O',
    46: 't',
    42: 'p',
    11: 'K',
    40: 'n',
  };

  // Perform BFS Flood-fill from corners on resized image to detect background
  final isBg = List.generate(size, (_) => List<bool>.filled(size, false));
  final queue = Queue<Point>();

  bool isBgPixel(int x, int y) {
    final pixel = resized.getPixel(x, y);
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    final distSq = (r - bgR) * (r - bgR) + (g - bgG) * (g - bgG) + (b - bgB) * (b - bgB);
    return distSq < 1600; // Threshold of 40 for corners
  }

  // Seed corners
  final corners = [
    Point(0, 0),
    Point(size - 1, 0),
    Point(0, size - 1),
    Point(size - 1, size - 1)
  ];

  for (final c in corners) {
    if (isBgPixel(c.x, c.y)) {
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
        if (!isBg[ny][nx] && isBgPixel(nx, ny)) {
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
