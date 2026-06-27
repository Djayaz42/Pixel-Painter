import 'dart:io';
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

  print('Image dimensions: ${image.width}x${image.height}');

  // Sample colors at different background locations
  final points = [
    [0, 0],
    [10, 10],
    [image.width - 11, 10],
    [10, image.height - 11],
    [image.width - 11, image.height - 11],
    [image.width ~/ 2, 10],
  ];

  print('Background color samples:');
  for (final pt in points) {
    final pixel = image.getPixel(pt[0], pt[1]);
    print('At (${pt[0]}, ${pt[1]}): R=${pixel.r.toInt()}, G=${pixel.g.toInt()}, B=${pixel.b.toInt()}');
  }

  // Count distinct colors or cluster them to see what is foreground
  // Let's print out some non-background pixel positions
  final bgPixel = image.getPixel(10, 10);
  final bgR = bgPixel.r.toInt();
  final bgG = bgPixel.g.toInt();
  final bgB = bgPixel.b.toInt();

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
      if (distSq >= 225) { // Threshold of 15
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  print('Foreground bounding box: minX=$minX, maxX=$maxX, minY=$minY, maxY=$maxY');
  print('Width=${maxX - minX + 1}, Height=${maxY - minY + 1}');
}
