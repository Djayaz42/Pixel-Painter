import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\207310fe-d18b-41db-9e82-841d9e42a8ad\\media__1782465830563.jpg';
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

  // Ignore bottom 20% of the image to skip Shutterstock watermarks/logos
  int scanHeight = (image.height * 0.80).toInt();

  // Find bounding box of non-white pixels to crop margins
  int minX = image.width;
  int maxX = 0;
  int minY = image.height;
  int maxY = 0;

  for (int y = 0; y < scanHeight; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      // Background is plain white/light
      if (!(r > 240 && g > 240 && b > 240)) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  // Add small padding
  final padding = 12;
  minX = (minX - padding).clamp(0, image.width - 1);
  maxX = (maxX + padding).clamp(0, image.width - 1);
  minY = (minY - padding).clamp(0, image.height - 1);
  maxY = (maxY + padding).clamp(0, scanHeight - 1);

  final cropWidth = maxX - minX + 1;
  final cropHeight = maxY - minY + 1;

  final cropped = img.copyCrop(image, x: minX, y: minY, width: cropWidth, height: cropHeight);

  // Resize to 48x48
  final size = 48;
  final resized = img.copyResize(cropped, width: size, height: size);

  // Game palette mapping:
  // 11: Color(0xFFF7F8FF) -> White (K)
  // 12: Color(0xFF12131A) -> Black (L)
  // 17: Color(0xFF0A84FF) -> Scarf blue (Q)
  // 2:  Color(0xFF42A5FF) -> Scarf light blue (B)
  // 6:  Color(0xFFFF8A3D) -> Beak/feet orange (F)
  // 19: Color(0xFFD8D8DE) -> Gray shadow (S)
  // 13: Color(0xFF8D99AE) -> Ground shadow (M)
  final colorMap = {
    11: [247, 248, 255], // White
    12: [18, 19, 26],     // Black
    17: [10, 132, 255],   // Scarf Blue
    2: [66, 165, 255],    // Scarf Light Blue
    6: [255, 138, 61],    // Orange
    19: [216, 216, 222],  // Light Gray
    13: [141, 153, 174],  // Dark Gray
  };

  final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxy';
  final colorToChar = <int, String>{};
  for (var i = 0; i < chars.length; i++) {
    colorToChar[i + 1] = chars[i];
  }

  // Flood fill algorithm to detect outer background (white/light colors)
  final visited = List.generate(size, (_) => List.generate(size, (_) => false));
  final isBg = List.generate(size, (_) => List.generate(size, (_) => false));

  bool isWhiteBg(int x, int y) {
    final pixel = resized.getPixel(x, y);
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    return r > 240 && g > 240 && b > 240;
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

  // Run flood fill from corners
  if (!visited[0][0]) floodFill(0, 0);
  if (!visited[0][size - 1]) floodFill(size - 1, 0);
  if (!visited[size - 1][0]) floodFill(0, size - 1);
  if (!visited[size - 1][size - 1]) floodFill(size - 1, size - 1);

  // Generate the character grid
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

        // Find closest color id
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

  // Output level code representation
  print('=== Grid ===');
  for (final row in grid) {
    print('        "$row",');
  }

  print('\n=== Color Runs ===');
  for (var entry in colorCounts.entries) {
    int count = entry.value;
    int roundedCount = ((count + 2) ~/ 5) * 5;
    if (roundedCount == 0 && count > 0) roundedCount = 5;
    print('        LevelColorRun(${entry.key}, $roundedCount),');
  }
}
