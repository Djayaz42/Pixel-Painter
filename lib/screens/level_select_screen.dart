import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/level_data.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  static const _categories = [
    _LevelCategory(
      title: 'Ulkeler',
      icon: Icons.public_rounded,
      startIndex: 0,
      color: Color(0xFF42A5FF),
    ),
    _LevelCategory(
      title: 'Baskentler',
      icon: Icons.location_city_rounded,
      startIndex: 25,
      color: Color(0xFFFFD447),
    ),
    _LevelCategory(
      title: 'Hayvanlar',
      icon: Icons.pets_rounded,
      startIndex: 50,
      color: Color(0xFF42E88A),
    ),
    _LevelCategory(
      title: 'Spor',
      icon: Icons.sports_soccer_rounded,
      startIndex: 75,
      color: Color(0xFFFF7AC8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        body: CustomPaint(
          painter: const _LevelSelectAtmospherePainter(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF242C3F),
                  Color(0xFF161B29),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE29B3C), Color(0xFFC86446)],
                            ),
                            boxShadow: const [
                              BoxShadow(color: Color(0x22C86446), blurRadius: 12, offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Pixel Painter',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFFBE49E),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C1908).withAlpha(180),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCE9E4F), width: 1.8),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: const Color(0xFFCE9E4F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF53381B), width: 1.5),
                        ),
                        labelColor: const Color(0xFF2C1908),
                        unselectedLabelColor: const Color(0xFFE5B869),
                        tabs: [
                          for (final category in _categories)
                            Tab(icon: Icon(category.icon, size: 20)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        for (final category in _categories)
                          _LevelGrid(category: category),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WindingPathPainter extends CustomPainter {
  const _WindingPathPainter({
    required this.itemCount,
    required this.rowHeight,
    required this.currentLevelIndex,
  });

  final int itemCount;
  final double rowHeight;
  final int currentLevelIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount <= 0) return;

    final path = Path();
    final width = size.width;

    Offset getOffset(int i) {
      final xOffset = math.sin(i * 0.9) * 90.0;
      final x = width / 2 + xOffset;
      final y = i * rowHeight + rowHeight / 2;
      return Offset(x, y);
    }

    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFCE9E4F); // Gold border road

    final pathPaintInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF53381B); // Dark bronze inner road

    final completedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF42E88A); // Completed progress (green overlay)

    final startPoint = getOffset(0);
    path.moveTo(startPoint.dx, startPoint.dy);

    for (var i = 1; i < itemCount; i++) {
      final prev = getOffset(i - 1);
      final curr = getOffset(i);
      final control1 = Offset(prev.dx, prev.dy + rowHeight / 2);
      final control2 = Offset(curr.dx, curr.dy - rowHeight / 2);
      path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(path, pathPaint);
    canvas.drawPath(path, pathPaintInner);

    // Draw completed path line decorative segment
    final completedPath = Path();
    completedPath.moveTo(startPoint.dx, startPoint.dy);
    for (var i = 1; i <= currentLevelIndex && i < itemCount; i++) {
      final prev = getOffset(i - 1);
      final curr = getOffset(i);
      final control1 = Offset(prev.dx, prev.dy + rowHeight / 2);
      final control2 = Offset(curr.dx, curr.dy - rowHeight / 2);
      completedPath.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(completedPath, completedPaint);
  }

  @override
  bool shouldRepaint(covariant _WindingPathPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.currentLevelIndex != currentLevelIndex;
  }
}

class _LevelGrid extends StatelessWidget {
  const _LevelGrid({required this.category});

  final _LevelCategory category;

  @override
  Widget build(BuildContext context) {
    final levels = [
      for (var offset = 0; offset < 25; offset++)
        if (category.startIndex + offset < LevelData.levels.length)
          (
            index: category.startIndex + offset,
            level: LevelData.levels[category.startIndex + offset],
          ),
    ];

    const rowHeight = 135.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            height: levels.length * rowHeight,
            width: constraints.maxWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WindingPathPainter(
                      itemCount: levels.length,
                      rowHeight: rowHeight,
                      currentLevelIndex: category.startIndex == 0 ? 3 : 0, // Mark first few levels as completed decoratively
                    ),
                  ),
                ),
                for (var itemIndex = 0; itemIndex < levels.length; itemIndex++) ...[
                  (() {
                    final item = levels[itemIndex];
                    final double xOffset = math.sin(itemIndex * 0.9) * 90.0;
                    // Center of node circle should be at: itemIndex * rowHeight + rowHeight / 2
                    // Column has circle height 74, so center of circle is 37 pixels from column top.
                    // To place the center of the circle exactly at itemIndex * rowHeight + rowHeight / 2,
                    // the top of the column should be at: itemIndex * rowHeight + rowHeight / 2 - 37.0
                    final double topPosition = itemIndex * rowHeight + rowHeight / 2 - 37.0;
                    return Positioned(
                      left: 0,
                      right: 0,
                      top: topPosition,
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(xOffset, 0),
                          child: _LevelPathNode(
                            category: category,
                            levelIndex: item.index,
                            localNumber: itemIndex + 1,
                            title: _cleanTitle(item.level.name),
                          ),
                        ),
                      ),
                    );
                  }()),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _cleanTitle(String name) {
    final parts = name.split(' ');
    if (parts.length <= 2) {
      return name;
    }
    if (parts.first == 'Easy' ||
        parts.first == 'Hard' ||
        parts.first == 'Very') {
      return parts.skip(parts.first == 'Very' ? 3 : 2).join(' ');
    }
    return parts.skip(2).join(' ');
  }
}

class _LevelPathNode extends StatelessWidget {
  const _LevelPathNode({
    required this.category,
    required this.levelIndex,
    required this.localNumber,
    required this.title,
  });

  final _LevelCategory category;
  final int levelIndex;
  final int localNumber;
  final String title;

  @override
  Widget build(BuildContext context) {
    final baseColor = category.color;
    final displayLevelNumber = levelIndex + 1;

    return GestureDetector(
      onTap: () => _openLevel(context, levelIndex: levelIndex),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCE9E4F), width: 3.5),
              gradient: RadialGradient(
                center: const Alignment(-0.25, -0.25),
                radius: 0.85,
                colors: [
                  Color.lerp(baseColor, Colors.white, 0.45)!,
                  baseColor,
                  Color.lerp(baseColor, Colors.black, 0.35)!,
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF160D06),
                  blurRadius: 8,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 10,
                  child: Container(
                    width: 18,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(160),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    category.icon,
                    color: Colors.white.withAlpha(200),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$displayLevelNumber',
            style: const TextStyle(
              color: Color(0xFFCE9E4F),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFBEFD3),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

void _openLevel(BuildContext context, {required int levelIndex}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => GameScreen(
        initialLevelIndex: levelIndex,
        onOpenMenu: () => Navigator.of(context).pop(),
      ),
    ),
  );
}

class _LevelCategory {
  const _LevelCategory({
    required this.title,
    required this.icon,
    required this.startIndex,
    required this.color,
  });

  final String title;
  final IconData icon;
  final int startIndex;
  final Color color;
}

class _LevelSelectAtmospherePainter extends CustomPainter {
  const _LevelSelectAtmospherePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw slate-marble base gradient glows
    final topGlow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF1E355A).withAlpha(150), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.25, size.height * 0.12),
          radius: size.width * 0.75,
        ),
      );
    final midGlow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF132035).withAlpha(110), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.88, size.height * 0.36),
          radius: size.width * 0.82,
        ),
      );
    canvas.drawRect(Offset.zero & size, topGlow);
    canvas.drawRect(Offset.zero & size, midGlow);

    // 2. Draw subtle organic slate/marble veins
    final veinPaint = Paint()
      ..color = const Color(0xFFE5D5C5).withAlpha(12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

    // Vein 1
    final path1 = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.18, size.width * 0.4, size.height * 0.3)
      ..cubicTo(size.width * 0.55, size.height * 0.42, size.width * 0.45, size.height * 0.6, size.width * 0.7, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.82, size.width, size.height * 0.9);
    canvas.drawPath(path1, veinPaint);

    // Vein 2
    final path2 = Path()
      ..moveTo(size.width, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.25, size.width * 0.6, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.55, size.width * 0.2, size.height * 0.65)
      ..lineTo(0, size.height * 0.8);
    canvas.drawPath(path2, veinPaint);

    // Vein 3
    final path3 = Path()
      ..moveTo(size.width * 0.4, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.4, size.width * 0.1, size.height * 0.35)
      ..quadraticBezierTo(0, size.height * 0.38, 0, size.height * 0.4);
    canvas.drawPath(path3, veinPaint);

    // 3. Draw elegant Art-Deco gold geometric lines and frames (gold foil)
    final goldRect = Offset.zero & size;
    final goldGlowShader = const LinearGradient(
      colors: [Color(0xFFE29B3C), Color(0xFFFBE49E), Color(0xFFC86446), Color(0xFFFBE49E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(goldRect);

    final goldPaintThin = Paint()
      ..shader = goldGlowShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final goldPaintThick = Paint()
      ..shader = goldGlowShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Draw top art-deco header framing
    final topFrame = Path()
      ..moveTo(0, size.height * 0.08)
      ..lineTo(size.width * 0.15, size.height * 0.08)
      ..lineTo(size.width * 0.22, size.height * 0.04)
      ..lineTo(size.width * 0.78, size.height * 0.04)
      ..lineTo(size.width * 0.85, size.height * 0.08)
      ..lineTo(size.width, size.height * 0.08);
    canvas.drawPath(topFrame, goldPaintThin);

    // Draw bottom corner art-deco triangles and diamonds
    // Bottom-left decoration
    final blCorner = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width * 0.25, size.height * 0.96)
      ..lineTo(size.width * 0.25, size.height)
      ..moveTo(0, size.height * 0.72)
      ..lineTo(size.width * 0.28, size.height * 0.96)
      ..lineTo(size.width * 0.28, size.height);
    canvas.drawPath(blCorner, goldPaintThin);

    final blTriangle = Path()
      ..moveTo(0, size.height * 0.80)
      ..lineTo(size.width * 0.20, size.height * 0.96)
      ..lineTo(0, size.height * 0.96)
      ..close();
    canvas.drawPath(blTriangle, goldPaintThin);

    // Bottom-right decoration
    final brCorner = Path()
      ..moveTo(size.width, size.height * 0.75)
      ..lineTo(size.width * 0.75, size.height * 0.96)
      ..lineTo(size.width * 0.75, size.height)
      ..moveTo(size.width, size.height * 0.72)
      ..lineTo(size.width * 0.72, size.height * 0.96)
      ..lineTo(size.width * 0.72, size.height);
    canvas.drawPath(brCorner, goldPaintThin);

    final brTriangle = Path()
      ..moveTo(size.width, size.height * 0.80)
      ..lineTo(size.width * 0.80, size.height * 0.96)
      ..lineTo(size.width, size.height * 0.96)
      ..close();
    canvas.drawPath(brTriangle, goldPaintThin);

    // Intersecting horizontal bar at bottom
    canvas.drawLine(
      Offset(0, size.height * 0.96),
      Offset(size.width, size.height * 0.96),
      goldPaintThick,
    );
  }

  @override
  bool shouldRepaint(covariant _LevelSelectAtmospherePainter oldDelegate) => false;
}
