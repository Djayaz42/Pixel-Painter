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
    this.hasChainDecoration = false,
  });

  final List<PixelCell> cells;
  final Map<int, Color> colorValues;
  final int rows;
  final int cols;
  final double artScale;
  final Set<int> backgroundColors;
  final int activeMotorsCount;
  final bool hasChainDecoration;

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
        hasChainDecoration: hasChainDecoration,
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
    this.hasChainDecoration = false,
  });

  final List<PixelCell> cells;
  final Map<int, Color> colorValues;
  final int rows;
  final int cols;
  final double artScale;
  final Set<int> backgroundColors;
  final int activeMotorsCount;
  final bool hasChainDecoration;

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
    final gap = cellSize * 0.04;

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

    // 4. Draw sleek, premium metallic frame around the grid (replacing the rollers)
    final frameOuterRect = Rect.fromLTRB(
      origin.dx - 10,
      origin.dy - 10,
      origin.dx + artWidth + 10,
      origin.dy + artHeight + 10,
    );
    final frameInnerRect = Rect.fromLTRB(
      origin.dx,
      origin.dy,
      origin.dx + artWidth,
      origin.dy + artHeight,
    );

    // Draw the dark metallic frame background
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameOuterRect, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B4252), // Nord dark gray highlight
            Color(0xFF2E3440), // Polar night dark
            Color(0xFF1E222A), // Extra dark slate
          ],
        ).createShader(frameOuterRect),
    );

    // Draw a premium gold/bronze trim outline around the frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameOuterRect, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xFFCE9E4F), // Gold highlight matching UI and motors
    );

    // Draw a dark inner outline right against the grid
    canvas.drawRect(
      frameInnerRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xFF1A1D24),
    );

    // 5. Draw dark grid canvas background
    canvas.drawRRect(
      RRect.fromRectAndRadius(artRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFF2E3440),
    );

    if (hasChainDecoration) {
      final yCenter = origin.dy + 45.0 * cellSize;
      final linkWidth = 4.0 * cellSize;
      final linkHeight = 2.0 * cellSize;

      final paintStroke = Paint()
        ..color = const Color(0xFF1E222A)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.6;

      for (int i = 0; i < 12; i++) {
        final x = origin.dx + (i * 4 + 2) * cellSize;
        
        final rangeCells = cells.where((c) => c.row >= 44 && c.row <= 46 && c.col >= i * 4 && c.col <= i * 4 + 3);
        final linkTotal = rangeCells.length;
        final linkPainted = rangeCells.where((c) => c.isPainted).length;
        final linkProgress = linkTotal == 0 ? 0.0 : linkPainted / linkTotal;

        canvas.save();
        canvas.translate(x, yCenter);
        canvas.rotate(0.35); // 20 degrees tilt

        final outerRect = Rect.fromCenter(center: Offset.zero, width: linkWidth, height: linkHeight);
        final innerRect = Rect.fromCenter(center: Offset.zero, width: linkWidth * 0.6, height: linkHeight * 0.4);

        final rrectOuter = RRect.fromRectAndRadius(outerRect, Radius.circular(linkHeight * 0.45));
        final rrectInner = RRect.fromRectAndRadius(innerRect, Radius.circular(linkHeight * 0.2));

        // Draw shadow under the ring (grows stronger as it's painted)
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.08 + 0.25 * linkProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawRRect(rrectOuter.shift(const Offset(0.0, 2.0)), shadowPaint);

        // Draw ring body filled with silver gradient
        // Unpainted: low opacity dark steel. Painted: full opacity silver.
        final ringPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(const Color(0xFF374151), Colors.white, linkProgress)!,
              Color.lerp(const Color(0xFF1F2937), const Color(0xFFD1D5DB), linkProgress)!,
              Color.lerp(const Color(0xFF111827), const Color(0xFF9CA3AF), linkProgress)!,
              Color.lerp(const Color(0xFF030712), const Color(0xFF4B5563), linkProgress)!,
            ],
            stops: const [0.0, 0.3, 0.65, 1.0],
          ).createShader(outerRect)
          ..style = PaintingStyle.fill
          ..color = Colors.white.withOpacity(0.15 + 0.85 * linkProgress);

        canvas.drawRRect(rrectOuter, ringPaint);

        final holePaint = Paint()
          ..color = const Color(0xFF2E3440)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rrectInner, holePaint);

        // Draw outlines (grows clearer as it's painted)
        paintStroke.color = const Color(0xFF1E222A).withOpacity(0.2 + 0.8 * linkProgress);
        canvas.drawRRect(rrectOuter, paintStroke);
        canvas.drawRRect(rrectInner, paintStroke);

        canvas.restore();
      }
    }

    // 6. Draw grid target cells (clean color blocks)
    for (final cell in cells) {
      if (!cell.isTarget || cell.isPainted) {
        continue;
      }

      final isChainCell = hasChainDecoration && cell.row >= 44 && cell.row <= 46;
      final cellOpacity = isChainCell ? 0.65 : 1.0;

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
          Color.lerp(baseColor, Colors.white, 0.25)!.withOpacity(cellOpacity),
          baseColor.withOpacity(cellOpacity),
          Color.lerp(baseColor, Colors.black, 0.15)!.withOpacity(cellOpacity),
        ],
      ).createShader(rect);
      canvas.drawRRect(cellRRect, paint);
      
      canvas.drawRRect(
        cellRRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = const Color(0xFF0D1017).withOpacity(cellOpacity),
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
        oldDelegate.activeMotorsCount != activeMotorsCount ||
        oldDelegate.hasChainDecoration != hasChainDecoration;
  }
}
