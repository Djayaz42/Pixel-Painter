void main() {
  int initialL = 270;
  int initialK = 19;
  int initialX = 161;
  int initialV = 20;
  int initialU = 124;
  int initialM = 72;

  // We want:
  // L: 265
  // K: 20
  // X: 165
  // V: 20
  // U: 125
  // M: 70

  for (int lToK = 1; lToK <= 1; lToK++) {
  for (int mToX = 0; mToX <= 10; mToX++) {
  for (int mToU = 0; mToU <= 10; mToU++) {
  for (int mToL = 0; mToL <= 10; mToL++) {
  for (int uToX = 0; uToX <= 10; uToX++) {
  for (int uToL = 0; uToL <= 10; uToL++) {
  for (int lToX = 0; lToX <= 10; lToX++) {
  for (int lToU = 0; lToU <= 10; lToU++) {
  for (int xToL = 0; xToL <= 10; xToL++) {
  for (int xToU = 0; xToU <= 10; xToU++) {
    int deltaL = -lToK - lToX - lToU + mToL + uToL + xToL;
    int deltaK = lToK;
    int deltaM = -mToX - mToU - mToL;
    int deltaU = -uToX - uToL + mToU + lToU + xToU;
    int deltaX = -xToL - xToU + mToX + uToX + lToX;

    if (initialL + deltaL == 265 &&
        initialK + deltaK == 20 &&
        initialM + deltaM == 70 &&
        initialU + deltaU == 125 &&
        initialX + deltaX == 165) {
      print('Solution found:');
      print('  lToK: $lToK, mToX: $mToX, mToU: $mToU, mToL: $mToL');
      print('  uToX: $uToX, uToL: $uToL, lToX: $lToX, lToU: $lToU');
      print('  xToL: $xToL, xToU: $xToU');
      return;
    }
  }
  }
  }
  }
  }
  }
  }
  }
  }
  }
  print('No solution found.');
}
