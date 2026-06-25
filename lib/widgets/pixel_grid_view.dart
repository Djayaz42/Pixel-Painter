import 'package:flutter/material.dart';

import '../models/pixel_cell.dart';

class PixelGridView extends StatelessWidget {
  const PixelGridView({
    super.key,
    required this.cells,
    required this.colorValues,
    required this.rows,
    required this.cols,
    this.artScale = 0.64,
    this.backgroundColors = const <int>{},
    this.activeMotorsCount = 0,
  });

  final List<PixelCell> cells;
  final Map<int, Color> colorValues;
  final int rows;
  final int cols;
  final double artScale;
  final Set<int> backgroundColors;
  final int activeMotorsCount;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PixelGridPainter(
        cells: cells,
        colorValues: colorValues,
        rows: rows,
        cols: cols,
        artScale: artScale,
        backgroundColors: backgroundColors,
        activeMotorsCount: activeMotorsCount,
      ),
    );
  }
}

class _PixelGridPainter extends CustomPainter {
  const _PixelGridPainter({
    required this.cells,
    required this.colorValues,
    required this.rows,
    required this.cols,
    required this.artScale,
    required this.backgroundColors,
    required this.activeMotorsCount,
  });

  final List<PixelCell> cells;
  final Map<int, Color> colorValues;
  final int rows;
  final int cols;
  final double artScale;
  final Set<int> backgroundColors;
  final int activeMotorsCount;

  @override
  void paint(Canvas canvas, Size size) {
    final frameSize = size.shortestSide;
    final frameOrigin = Offset(
      (size.width - frameSize) / 2,
      (size.height - frameSize) / 2,
    );
    final cellSize = frameSize * artScale / rows;
    final artWidth = cellSize * cols;
    final artHeight = cellSize * rows;
    final origin =
        frameOrigin +
        Offset((frameSize - artWidth) / 2, (frameSize - artHeight) / 2);
    final gridRect = frameOrigin & Size(frameSize, frameSize);
    final artRect = origin & Size(artWidth, artHeight);
    final paint = Paint()..style = PaintingStyle.fill;
    final gap = cellSize * 0.09;

    // 1. Draw main frame container
    canvas.drawRRect(
      RRect.fromRectAndRadius(gridRect, const Radius.circular(20)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF434C5E), Color(0xFF2E3440)], // Slate-gray highlight to dark slate-gray
        ).createShader(gridRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gridRect.deflate(3), const Radius.circular(18)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFF1A1D24),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gridRect.deflate(10), const Radius.circular(14)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF434C5E).withAlpha(120),
    );

    // 2. Draw conveyor racetrack path
    final laneInset = frameSize * 0.075;
    final laneRect = gridRect.deflate(laneInset);
    
    // Draw thick track background
    canvas.drawRRect(
      RRect.fromRectAndRadius(laneRect, const Radius.circular(14)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = frameSize * 0.105
        ..color = const Color(0xFF4C566A), // Nord slate gray
    );

    // Draw center track slot/groove
    canvas.drawRRect(
      RRect.fromRectAndRadius(laneRect, const Radius.circular(14)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xFF1A1D24),
    );
    
    // Draw outer outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(laneRect.inflate(frameSize * 0.105 / 2), const Radius.circular(18)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFF1A1D24),
    );

    // Draw inner outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(laneRect.deflate(frameSize * 0.105 / 2), const Radius.circular(10)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFF1A1D24),
    );

    // 3. Draw direction chevrons along the track (counter-clockwise movement)
    final chevronPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF2E3440).withAlpha(180);
    final chevronSize = frameSize * 0.010;
    
    // Top side: Right to Left (<)
    for (int i = 1; i <= 6; i++) {
      final x = laneRect.right - (laneRect.width * i / 7);
      final y = laneRect.top;
      final path = Path()
        ..moveTo(x + chevronSize * 0.8, y - chevronSize * 0.8)
        ..lineTo(x - chevronSize * 0.2, y)
        ..lineTo(x + chevronSize * 0.8, y + chevronSize * 0.8);
      canvas.drawPath(path, chevronPaint);
    }
    // Bottom side: Left to Right (>)
    for (int i = 1; i <= 6; i++) {
      final x = laneRect.left + (laneRect.width * i / 7);
      final y = laneRect.bottom;
      final path = Path()
        ..moveTo(x - chevronSize * 0.8, y - chevronSize * 0.8)
        ..lineTo(x + chevronSize * 0.2, y)
        ..lineTo(x - chevronSize * 0.8, y + chevronSize * 0.8);
      canvas.drawPath(path, chevronPaint);
    }
    // Left side: Top to Bottom (v)
    for (int i = 1; i <= 6; i++) {
      final x = laneRect.left;
      final y = laneRect.top + (laneRect.height * i / 7);
      final path = Path()
        ..moveTo(x - chevronSize * 0.8, y - chevronSize * 0.8)
        ..lineTo(x, y + chevronSize * 0.2)
        ..lineTo(x + chevronSize * 0.8, y - chevronSize * 0.8);
      canvas.drawPath(path, chevronPaint);
    }
    // Right side: Bottom to Top (^)
    for (int i = 1; i <= 6; i++) {
      final x = laneRect.right;
      final y = laneRect.bottom - (laneRect.height * i / 7);
      final path = Path()
        ..moveTo(x - chevronSize * 0.8, y + chevronSize * 0.8)
        ..lineTo(x, y - chevronSize * 0.2)
        ..lineTo(x + chevronSize * 0.8, y + chevronSize * 0.8);
      canvas.drawPath(path, chevronPaint);
    }

    // 4. Draw custom roller conveyor tiled border around the grid
    final rollerWidth = 8.0;
    final rollerPaintLight = Paint()..color = const Color(0xFFE5E9F0);
    final rollerPaintDark = Paint()..color = const Color(0xFFD8DEE9);
    final rollerSeparatorPaint = Paint()
      ..color = const Color(0xFF1A1D24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
   
    // Top Edge Rollers
    for (double x = origin.dx - 12; x < origin.dx + artWidth + 12; x += rollerWidth) {
      final rect = Rect.fromLTWH(x, origin.dy - 12, rollerWidth - 1, 12);
      canvas.drawRect(rect, (x ~/ rollerWidth) % 2 == 0 ? rollerPaintLight : rollerPaintDark);
      canvas.drawRect(rect, rollerSeparatorPaint);
    }
   
    // Bottom Edge Rollers
    for (double x = origin.dx - 12; x < origin.dx + artWidth + 12; x += rollerWidth) {
      final rect = Rect.fromLTWH(x, origin.dy + artHeight, rollerWidth - 1, 12);
      canvas.drawRect(rect, (x ~/ rollerWidth) % 2 == 0 ? rollerPaintLight : rollerPaintDark);
      canvas.drawRect(rect, rollerSeparatorPaint);
    }

    // Left Edge Rollers
    for (double y = origin.dy; y < origin.dy + artHeight; y += rollerWidth) {
      final rect = Rect.fromLTWH(origin.dx - 12, y, 12, rollerWidth - 1);
      canvas.drawRect(rect, (y ~/ rollerWidth) % 2 == 0 ? rollerPaintLight : rollerPaintDark);
      canvas.drawRect(rect, rollerSeparatorPaint);
    }

    // Right Edge Rollers
    for (double y = origin.dy; y < origin.dy + artHeight; y += rollerWidth) {
      final rect = Rect.fromLTWH(origin.dx + artWidth, y, 12, rollerWidth - 1);
      canvas.drawRect(rect, (y ~/ rollerWidth) % 2 == 0 ? rollerPaintLight : rollerPaintDark);
      canvas.drawRect(rect, rollerSeparatorPaint);
    }

    // Draw dark frames around the rollers
    canvas.drawRect(
      Rect.fromLTRB(origin.dx - 12, origin.dy - 12, origin.dx + artWidth + 12, origin.dy + artHeight + 12),
      Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = const Color(0xFF1A1D24),
    );
    canvas.drawRect(
      Rect.fromLTRB(origin.dx, origin.dy, origin.dx + artWidth, origin.dy + artHeight),
      Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = const Color(0xFF1A1D24),
    );

    // 5. Draw dark grid canvas background
    canvas.drawRRect(
      RRect.fromRectAndRadius(artRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFF2E3440),
    );

    // 6. Draw grid target cells (clean color blocks)
    for (final cell in cells) {
      if (!cell.isTarget || cell.isPainted) {
        continue;
      }

      final baseColor =
          colorValues[cell.targetColorId] ?? const Color(0xFF25264F);
      final rect = Rect.fromLTWH(
          origin.dx + cell.col * cellSize + gap / 2,
          origin.dy + cell.row * cellSize + gap / 2,
          cellSize - gap,
          cellSize - gap,
      );
      final radius = Radius.circular(cellSize * 0.2);
      final cellRRect = RRect.fromRectAndRadius(rect, radius);

      // Draw base pixel color
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(baseColor, Colors.white, 0.25)!,
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.15)!,
        ],
      ).createShader(rect);
      canvas.drawRRect(cellRRect, paint);
      
      canvas.drawRRect(
        cellRRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = const Color(0xFF0D1017),
      );
    }

    // 7. Draw static orbit slots counter text (e.g. 5/5) at bottom-left corner of track
    final availableSlots = (5 - activeMotorsCount).clamp(0, 5);
    final pullText = '$availableSlots/5';
    
    final pullTextPainterOutline = TextPainter(
      text: TextSpan(
        text: pullText,
        style: TextStyle(
          fontSize: frameSize * 0.054,
          fontWeight: FontWeight.w900,
          fontFamily: 'Outfit',
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..color = Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pullTextPainterFill = TextPainter(
      text: TextSpan(
        text: pullText,
        style: TextStyle(
          fontSize: frameSize * 0.054,
          fontWeight: FontWeight.w900,
          fontFamily: 'Outfit',
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pullTextOffset = Offset(
      laneRect.left - frameSize * 0.03,
      laneRect.bottom + frameSize * 0.045,
    );

    pullTextPainterOutline.paint(canvas, pullTextOffset);
    pullTextPainterFill.paint(canvas, pullTextOffset);
  }

  @override
  bool shouldRepaint(covariant _PixelGridPainter oldDelegate) {
    return oldDelegate.cells != cells ||
        oldDelegate.colorValues != colorValues ||
        oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        oldDelegate.artScale != artScale ||
        oldDelegate.activeMotorsCount != activeMotorsCount;
  }
}
