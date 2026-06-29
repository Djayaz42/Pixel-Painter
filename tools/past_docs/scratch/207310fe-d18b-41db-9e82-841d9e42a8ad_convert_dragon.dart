import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\207310fe-d18b-41db-9e82-841d9e42a8ad\\media__1782476448454.jpg';
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

  // No cropping needed as it's a full square artwork with sky border
  final size = 48;
  final resized = img.copyResize(image, width: size, height: size);

  // Game palette mapping:
  final colorMap = {
    11: [247, 248, 255], // White (K)
    12: [18, 19, 26],     // Black (L)
    6: [255, 138, 61],    // Orange (F)
    40: [228, 127, 18],   // Dark Orange (n)
    26: [169, 201, 185],  // Sage Green (Z)
    16: [44, 94, 138],    // Indigo Blue (P)
    10: [154, 167, 255],  // Lavender Blue (J)
    5: [176, 108, 255],   // Purple/Violet (E)
    15: [108, 122, 137],  // Slate Grey (O)
    46: [93, 64, 55],     // Dark Brown (t)
    42: [255, 231, 181],  // Cream (p)
  };

  final colorToChar = {
    11: 'K',
    12: 'L',
    6: 'F',
    40: 'n',
    26: 'Z',
    16: 'P',
    10: 'J',
    5: 'E',
    15: 'O',
    46: 't',
    42: 'p',
  };

  // Generate the character grid
  final List<String> grid = [];
  final colorCounts = <int, int>{};

  for (int y = 0; y < size; y++) {
    final StringBuffer sb = StringBuffer();
    for (int x = 0; x < size; x++) {
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
