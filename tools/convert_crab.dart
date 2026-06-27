import 'dart:io';
import 'dart:collection';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\207310fe-d18b-41db-9e82-841d9e42a8ad\\media__1782480741840.jpg';
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

  // Background color is exactly R=223, G=188, B=146
  final bgR = 223;
  final bgG = 188;
  final bgB = 146;

  // Foreground bounding box: minX=212, maxX=815, minY=273, maxY=779
  final minX = 212;
  final maxX = 815;
  final minY = 273;
  final maxY = 779;

  final w = maxX - minX + 1; // 604
  final h = maxY - minY + 1; // 507
  final size = 604; // Square crop size

  // Centering on Y axis:
  final cropX = minX;
  final cropY = minY - (size - h) ~/ 2; // 225

  print('Cropping image with square bounds: x=$cropX, y=$cropY, w=$size, h=$size');
  final cropped = img.copyCrop(image, x: cropX, y: cropY, width: size, height: size);

  final gridSize = 48;
  final resized = img.copyResize(cropped, width: gridSize, height: gridSize);

  // Define target game colors with their actual RGB values from the image
  final colorMap = {
    12: [60, 20, 20],      // Outline (L) - dark outline
    1: [214, 76, 56],      // Red (A) - crab shell
    30: [239, 208, 192],   // Light Red/Pink (d) - underbelly
    42: [214, 184, 144],   // Sand/Cream (p) - island/sand
    11: [255, 255, 255],   // White (K) - highlights
    23: [75, 150, 178],    // Teal (W) - waves
  };

  final colorToChar = {
    12: 'L',
    1: 'A',
    30: 'd',
    42: 'p',
    11: 'K',
    23: 'W',
  };

  bool isBgPixel(int x, int y) {
    final pixel = resized.getPixel(x, y);
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    final distSq = (r - bgR) * (r - bgR) + (g - bgG) * (g - bgG) + (b - bgB) * (b - bgB);
    return distSq < 100; // Very tight threshold to capture exact background pixels
  }

  // Generate character grid
  final List<String> grid = [];
  final colorCounts = <int, int>{};

  for (int y = 0; y < gridSize; y++) {
    final StringBuffer sb = StringBuffer();
    for (int x = 0; x < gridSize; x++) {
      if (isBgPixel(x, y)) {
        // Fill background with sky/sea colors to make the crab stand out
        if (y < 18) {
          sb.write('Y'); // Color 25 - Sky Blue
          colorCounts[25] = (colorCounts[25] ?? 0) + 1;
        } else if (y < 38) {
          sb.write('T'); // Color 20 - Soft Aqua
          colorCounts[20] = (colorCounts[20] ?? 0) + 1;
        } else {
          sb.write('P'); // Color 16 - Navy Blue
          colorCounts[16] = (colorCounts[16] ?? 0) + 1;
        }
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
    print('Color ${entry.key}: ${entry.value}');
  }

  // Save the result to tools/bee_grid.txt
  final outFile = File('tools/bee_grid.txt');
  final outSb = StringBuffer();
  outSb.writeln('=== Grid ===');
  for (final row in grid) {
    outSb.writeln('    "$row",');
  }
  outSb.writeln('\n=== Color Runs ===');
  for (var entry in colorCounts.entries) {
    outSb.writeln('Color ${entry.key}: ${entry.value}');
  }
  outFile.writeAsStringSync(outSb.toString());
  print('Saved grid to tools/bee_grid.txt');
}
