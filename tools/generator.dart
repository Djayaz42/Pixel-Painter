import 'dart:io';
import 'dart:math';

class Canvas {
  final int rows;
  final int cols;
  late List<List<String>> grid;

  Canvas(this.rows, this.cols) {
    grid = List.generate(rows, (_) => List.generate(cols, (_) => ' '));
  }

  void clear([String char = ' ']) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        grid[r][c] = char;
      }
    }
  }

  void setPixel(int r, int c, String char) {
    if (r >= 0 && r < rows && c >= 0 && c < cols) {
      grid[r][c] = char;
    }
  }

  void fillRect(int r, int c, int h, int w, String char) {
    for (int i = r; i < r + h; i++) {
      for (int j = c; j < c + w; j++) {
        setPixel(i, j, char);
      }
    }
  }

  void drawRect(int r, int c, int h, int w, String char) {
    for (int i = r; i < r + h; i++) {
      setPixel(i, c, char);
      setPixel(i, c + w - 1, char);
    }
    for (int j = c; j < c + w; j++) {
      setPixel(r, j, char);
      setPixel(r + h - 1, j, char);
    }
  }

  void fillCircle(int cy, int cx, int radius, String char) {
    for (int r = cy - radius; r <= cy + radius; r++) {
      for (int c = cx - radius; c <= cx + radius; c++) {
        if ((r - cy) * (r - cy) + (c - cx) * (c - cx) <= radius * radius) {
          setPixel(r, c, char);
        }
      }
    }
  }

  void drawCircle(int cy, int cx, int radius, String char) {
    for (int r = cy - radius; r <= cy + radius; r++) {
      for (int c = cx - radius; c <= cx + radius; c++) {
        int distSq = (r - cy) * (r - cy) + (c - cx) * (c - cx);
        if (distSq >= (radius - 1) * (radius - 1) && distSq <= radius * radius) {
          setPixel(r, c, char);
        }
      }
    }
  }

  void fillEllipse(int cy, int cx, int ry, int rx, String char) {
    for (int r = cy - ry; r <= cy + ry; r++) {
      for (int c = cx - rx; c <= cx + rx; c++) {
        if (((r - cy) * (r - cy)) / (ry * ry) + ((c - cx) * (c - cx)) / (rx * rx) <= 1.0) {
          setPixel(r, c, char);
        }
      }
    }
  }

  void replaceColor(String oldChar, String newChar) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == oldChar) {
          grid[r][c] = newChar;
        }
      }
    }
  }

  void applyDither(String targetChar, String ditherChar, double probability) {
    Random rand = Random();
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == targetChar && rand.nextDouble() < probability) {
          if ((r + c) % 2 == 0) {
             grid[r][c] = ditherChar;
          }
        }
      }
    }
  }

  void drawLine(int r1, int c1, int r2, int c2, String char) {
    int dr = (r2 - r1).abs();
    int dc = (c2 - c1).abs();
    int sr = r1 < r2 ? 1 : -1;
    int sc = c1 < c2 ? 1 : -1;
    int err = (dc > dr ? dc : -dr) ~/ 2;

    while (true) {
      setPixel(r1, c1, char);
      if (r1 == r2 && c1 == c2) break;
      int e2 = err;
      if (e2 > -dc) { err -= dr; c1 += sc; }
      if (e2 < dr) { err += dc; r1 += sr; }
    }
  }

  List<String> getOutput() {
    return grid.map((row) => '"${row.join('')}"').toList();
  }
}
