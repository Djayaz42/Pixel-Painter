import 'dart:io';
import 'dart:collection';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\207310fe-d18b-41db-9e82-841d9e42a8ad\\media__1782480156758.jpg';
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

  // 1. Crop to the bee area
  final minX = 80;
  final minY = 90;
  final cropW = 820;
  final cropH = 720;
  
  print('Cropping image at: x=$minX, y=$minY, w=$cropW, h=$cropH');
  final cropped = img.copyCrop(image, x: minX, y: minY, width: cropW, height: cropH);
  
  final size = 48;
  final resized = img.copyResize(cropped, width: size, height: size);

  // Palette mapping:
  final colorMap = {
    12: [25, 25, 25],     // Black outline (L)
    46: [93, 64, 55],     // Dark Brown (t)
    4: [255, 212, 71],    // Yellow (D)
    41: [244, 165, 30],   // Lion Gold (o)
    15: [140, 150, 160],  // Slate Grey for wings (O)
    42: [255, 231, 181],  // Cream (p)
    11: [247, 248, 255],  // White (K)
  };

  final colorToChar = {
    12: 'L',
    46: 't',
    4: 'D',
    41: 'o',
    15: 'O',
    42: 'p',
    11: 'K',
  };

  // Determine Core Pixels (dark parts, wings, body highlights of the bee)
  final isCore = List.generate(size, (_) => List<bool>.filled(size, false));
  final distToCore = List.generate(size, (_) => List<int>.filled(size, 999));
  final queue = Queue<Point>();

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final pixel = resized.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      final brightness = 0.299 * r + 0.587 * g + 0.114 * b;
      
      // Core check:
      // 1. Dark pixels (legs, head, body stripes, thorax outline)
      final isDark = (r < 95 && g < 90 && b < 90);
      
      // 2. Wing grey/white highlights (slate grey, white)
      final isGreyOrWhite = (r - g).abs() < 22 && (r - b).abs() < 22 && r > 115;
      
      if (isDark || isGreyOrWhite) {
        if (x > 1 && x < size - 2 && y > 1 && y < size - 2) {
          isCore[y][x] = true;
          distToCore[y][x] = 0;
          queue.add(Point(x, y));
        }
      }
    }
  }

  // BFS to expand the core by a distance of up to 3 pixels to capture the yellow stripes and details
  final dx = [0, 0, 1, -1, 1, 1, -1, -1];
  final dy = [1, -1, 0, 0, 1, -1, 1, -1];

  while (queue.isNotEmpty) {
    final curr = queue.removeFirst();
    final d = distToCore[curr.y][curr.x];
    if (d >= 3) continue; // Maximum expansion distance

    for (int i = 0; i < 8; i++) {
      final nx = curr.x + dx[i];
      final ny = curr.y + dy[i];
      if (nx >= 0 && nx < size && ny >= 0 && ny < size) {
        if (distToCore[ny][nx] > d + 1) {
          distToCore[ny][nx] = d + 1;
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
      var isBee = distToCore[y][x] <= 3;
      
      // Apply clean-up mask to remove bleeding honeycomb segments
      if (isBee) {
        // 1. Bottom-right honeycomb segment
        if (y >= 45 && x >= 18) {
          isBee = false;
        }
        // 2. Right edge honeycomb segment
        if (y >= 14 && y <= 21 && x >= 35) {
          isBee = false;
        }
      }

      if (!isBee) {
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

  // Save output to file
  final outputFile = File('tools/bee_grid.txt');
  final iosb = StringBuffer();
  iosb.writeln('=== Grid ===');
  for (final row in grid) {
    iosb.writeln('    "$row",');
  }
  iosb.writeln('\n=== Color Runs ===');
  for (var entry in colorCounts.entries) {
    iosb.writeln('Color ${entry.key}: ${entry.value}');
  }
  outputFile.writeAsStringSync(iosb.toString());
  print('Saved grid to tools/bee_grid.txt');
}

class Point {
  final int x;
  final int y;
  Point(this.x, this.y);
}
