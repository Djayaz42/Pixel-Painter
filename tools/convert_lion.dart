import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\207310fe-d18b-41db-9e82-841d9e42a8ad\\media__1782466524938.jpg';
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

  // Find bounding box of non-white pixels to crop margins
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
      // Background is plain white/light
      if (!(r > 240 && g > 240 && b > 240)) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  // Crop tightly (padding = 0)
  final padding = 0;
  minX = (minX - padding).clamp(0, image.width - 1);
  maxX = (maxX + padding).clamp(0, image.width - 1);
  minY = (minY - padding).clamp(0, image.height - 1);
  maxY = (maxY + padding).clamp(0, image.height - 1);

  final cropWidth = maxX - minX + 1;
  final cropHeight = maxY - minY + 1;

  final cropped = img.copyCrop(image, x: minX, y: minY, width: cropWidth, height: cropHeight);

  // Resize to 48x48
  final size = 48;
  final resized = img.copyResize(cropped, width: size, height: size);

  // Game palette mapping:
  // 11: Color(0xFFF7F8FF) -> White (K)
  // 12: Color(0xFF12131A) -> Black (L)
  // 4:  Color(0xFFFFD447) -> Yellow (D)
  // 6:  Color(0xFFFF8A3D) -> Orange (F)
  // 14: Color(0xFF7A4E2D) -> Brown/Dark Orange (N)
  // 29: Color(0xFFFFB25F) -> Peach/Soft Orange (Y)
  // 1:  Color(0xFFFF4D67) -> Red/Pink (A)
  final colorMap = {
    11: [247, 248, 255], // White
    12: [18, 19, 26],     // Black
    4: [255, 212, 71],    // Yellow
    6: [255, 138, 61],    // Orange
    14: [122, 78, 45],    // Brown
    29: [255, 178, 95],   // Peach
    1: [255, 77, 103],    // Red/Pink
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

  // Run flood fill from edges to mark background as transparent
  for (int x = 0; x < size; x++) {
    if (!visited[0][x]) floodFill(x, 0);
    if (!visited[size - 1][x]) floodFill(x, size - 1);
  }
  for (int y = 0; y < size; y++) {
    if (!visited[y][0]) floodFill(0, y);
    if (!visited[y][size - 1]) floodFill(size - 1, y);
  }

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
    print('    "$row",');
  }

  print('\n=== Color Runs ===');
  for (var entry in colorCounts.entries) {
    int count = entry.value;
    int roundedCount = ((count + 2) ~/ 5) * 5;
    if (roundedCount == 0 && count > 0) roundedCount = 5;
    print('    LevelColorRun(${entry.key}, $roundedCount),');
  }
}
