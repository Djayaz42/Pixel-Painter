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

  print('Image dimensions: ${image.width}x${image.height}');

  // Crop the white borders if present. The dolphin image seems to have a thin white margin, but let's check
  // if we can just resize the whole image since it spans all edges.
  // Actually, let's crop the outer white border of the image to get a clean layout.
  // Let's sample the top-left pixel to see if it is white.
  final topLeft = image.getPixel(0, 0);
  print('Top-left pixel color: R=${topLeft.r.toInt()}, G=${topLeft.g.toInt()}, B=${topLeft.b.toInt()}');

  // Let's crop if it's white (R > 250, G > 250, B > 250)
  int startX = 0;
  int startY = 0;
  int width = image.width;
  int height = image.height;

  if (topLeft.r > 240 && topLeft.g > 240 && topLeft.b > 240) {
    // Find content bounds (where pixels are not white)
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
    print('Cropping white border: x=$startX, y=$startY, w=$width, h=$height');
  }

  final cropped = img.copyCrop(image, x: startX, y: startY, width: width, height: height);

  // Resize to 48x48
  final size = 48;
  final resized = img.copyResize(cropped, width: size, height: size);

  // We want to map to standard palette color IDs:
  // Dolphin: dark gray/purple-gray -> e.g. Color 15 (Slate Grey: 0xFF6C7A89) or Color 12 (Black: 0xFF12131A) or Color 16 (Indigo Blue: 0xFF2C5E8A) or Color 36 (Dark Blue: 0xFF0B1020).
  // Sunset Sky (gradient from top to bottom):
  //   - Top: Purple (Color 5: 0xFFB06CFF or Color 146: 0xFF7A4FA5)
  //   - Middle: Sunset Pink/Peach (Color 30: 0xFFF5A28F or Color 8: 0xFFFF7AC8 or Color 34: 0xFFD96A59)
  // Sun: Bright orange/yellow (Color 4: 0xFFFFD447 or Color 42: 0xFFFFE7B5)
  // Sea: Cyan/blue waves -> Color 21 (0xFF0F6B7A), Color 22 (0xFF1496A8), Color 23 (0xFF1DB7C8), Color 2 (0xFF42A5FF), Color 16 (0xFF2C5E8A)
  // Splash: Light cyan/white -> Color 24 (0xFF8FDCE8) or Color 25 (0xFF79D7F2) or Color 11 (0xFFF7F8FF)

  // Let's list some palette colors to choose from:
  final colorMap = {
    11: [247, 248, 255],  // White/Sun center (K)
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
    11: 'K',
    12: 'L',
    5: 'E',
    10: 'J',
    15: 'O',
    16: 'P',
    2: 'B',
    21: 'U',
    22: 'V',
    23: 'W',
    24: 'X',
    25: 'Y',
    30: 'd',
    31: 'e',
    34: 'h',
    36: 'j',
    42: 'p',
    48: 'w',
  };

  final List<String> grid = [];
  final colorCounts = <int, int>{};

  for (int y = 0; y < size; y++) {
    final StringBuffer sb = StringBuffer();
    for (int x = 0; x < size; x++) {
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
    grid.add(sb.toString());
  }

  print('=== Dolphin Grid ===');
  for (final row in grid) {
    print('    "$row",');
  }

  print('\n=== Color Runs ===');
  for (var entry in colorCounts.entries) {
    print('Color ${entry.key}: ${entry.value}');
  }
}
