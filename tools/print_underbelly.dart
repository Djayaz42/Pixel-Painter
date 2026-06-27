import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'C:\\Users\\Abdullah\\.gemini\\antigravity\\brain\\207310fe-d18b-41db-9e82-841d9e42a8ad\\media__1782480741840.jpg';
  final file = File(imagePath);
  if (!file.existsSync()) {
    print('Error: Image file not found');
    exit(1);
  }

  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return;

  // Bounding box bounds
  final minX = 212;
  final maxX = 815;
  final minY = 273;
  final maxY = 779;
  final size = 604;
  final cropY = minY - (size - (maxY - minY + 1)) ~/ 2; // 225

  final cropped = img.copyCrop(image, x: minX, y: cropY, width: size, height: size);
  final resized = img.copyResize(cropped, width: 48, height: 48);

  print('Print grid of colors around the center:');
  for (int y = 16; y <= 26; y++) {
    final List<String> row = [];
    for (int x = 16; x <= 32; x++) {
      final p = resized.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      // Print as a simplified hex code
      row.add('${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}');
    }
    print('y=$y: ${row.join(" ")}');
  }
}
