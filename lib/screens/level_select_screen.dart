import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/level_data.dart';
import '../models/game_stats.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
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
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedLevelIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: LevelSelectScreen._categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedLevelIndex = LevelSelectScreen._categories[_tabController.index].startIndex;
        });
      }
    });
    _selectedLevelIndex = LevelSelectScreen._categories[0].startIndex;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onLevelSelected(int index) {
    setState(() {
      _selectedLevelIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    GameStats.restoreLives();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E2630), // Deep Charcoal Slate
              Color(0xFF0D1017), // Rich Midnight Black
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background Grid and decorative floating shapes
              const Positioned.fill(
                child: CustomPaint(
                  painter: _LevelSelectAtmospherePainter(),
                ),
              ),

              // Main HUD Layout
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Stats Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar (Yellow cute snout/pig face shape)
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD447),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white, width: 2.2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 4),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.pets_rounded, color: Color(0xFF2C1908), size: 24),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Lives Pill
                        Expanded(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B29).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFFF6A7C), width: 2.0),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.favorite_rounded, color: Color(0xFFFF6A7C), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  GameStats.lives >= GameStats.maxLives ? 'MAKS' : '${GameStats.lives}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Coins Pill
                        Expanded(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B29).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFFFD447), width: 2.0),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const _GoldCoinIcon(size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${GameStats.gold}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.add_circle_rounded, color: Color(0xFF42E88A), size: 14),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Settings Icon
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF161B29).withOpacity(0.85),
                            border: Border.all(color: Colors.white54, width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Selector (TabBar)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B29).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white38, width: 1.5),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: const Color(0xFFFFD447),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF53381B), width: 1.5),
                        ),
                        labelColor: const Color(0xFF2C1908),
                        unselectedLabelColor: Colors.white70,
                        tabs: [
                          for (final category in LevelSelectScreen._categories)
                            Tab(icon: Icon(category.icon, size: 20)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Main List View containing level path
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        for (final category in LevelSelectScreen._categories)
                          _LevelGrid(
                            category: category,
                            selectedLevelIndex: _selectedLevelIndex,
                            onLevelSelected: _onLevelSelected,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // HUD Side Buttons - Left Side
              Positioned(
                left: 12,
                top: 130,
                bottom: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _HUDIconButton(
                      icon: Icons.shield_rounded,
                      label: '17s 47d',
                      color: Color(0xFFFFD447),
                    ),
                    _HUDIconButton(
                      icon: Icons.card_giftcard_rounded,
                      label: 'BAŞLA',
                      badgeText: '!',
                      color: Color(0xFFFF4264),
                    ),
                    _HUDIconButton(
                      icon: Icons.sports_motorsports_rounded,
                      label: 'BAŞLA',
                      badgeText: '!',
                      color: Color(0xFF42A5FF),
                    ),
                  ],
                ),
              ),

              // HUD Side Buttons - Right Side
              Positioned(
                right: 12,
                top: 130,
                bottom: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _HUDIconButton(
                      icon: Icons.key_rounded,
                      label: '1g 17s',
                      color: Color(0xFF42A5FF),
                    ),
                    _HUDIconButton(
                      icon: Icons.star_rounded,
                      label: 'BONUS',
                      badgeText: '!',
                      color: Color(0xFFFFD447),
                    ),
                    _HUDIconButton(
                      icon: Icons.block_rounded,
                      label: 'REKLAMSIZ',
                      color: Color(0xFFFF4242),
                    ),
                  ],
                ),
              ),

              // Floating Oyna Button at the bottom center
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _openLevel(context, levelIndex: _selectedLevelIndex).then((_) {
                        // Refresh state when returning to level select
                        setState(() {});
                      });
                    },
                    child: Container(
                      height: 56,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF2C1908), width: 3),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD447), Color(0xFFFFB300)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            offset: Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Oyna',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(color: Color(0xFF2C1908), offset: Offset(0, 2), blurRadius: 3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HUDIconButton extends StatelessWidget {
  const _HUDIconButton({
    required this.icon,
    required this.label,
    this.badgeText,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String? badgeText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF161B29).withOpacity(0.9),
                border: Border.all(color: color, width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
            if (badgeText != null)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _GoldCoinIcon extends StatelessWidget {
  const _GoldCoinIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 1),
            blurRadius: 1.5,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.star_rounded,
          color: const Color(0xFFFFFFFF),
          size: size * 0.7,
        ),
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _HexagonNode extends StatelessWidget {
  const _HexagonNode({
    required this.levelNumber,
    required this.title,
    required this.color,
    required this.isLocked,
    required this.isSelected,
    required this.onTap,
  });

  final int levelNumber;
  final String title;
  final Color color;
  final bool isLocked;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayColor = isLocked ? Colors.grey : color;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              children: [
                // Glowing background ring if selected
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD447).withOpacity(0.7),
                            blurRadius: 20,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),

                // 3D Shadow Layer (moved down)
                Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  bottom: -5,
                  child: ClipPath(
                    clipper: HexagonClipper(),
                    child: Container(
                      color: isLocked ? Colors.black45 : Color.lerp(displayColor, Colors.black, 0.45),
                    ),
                  ),
                ),

                // Main Hexagon with Gold/Silver Rim
                ClipPath(
                  clipper: HexagonClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [const Color(0xFFFFD447), const Color(0xFFE29B3C)]
                            : (isLocked
                                ? [const Color(0xFF9E9E9E), const Color(0xFF757575)]
                                : [
                                    Color.lerp(displayColor, Colors.white, 0.35)!,
                                    Color.lerp(displayColor, Colors.black, 0.25)!,
                                  ]),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.5), // Hexagon border thickness
                      child: ClipPath(
                        clipper: HexagonClipper(),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLocked
                                  ? [const Color(0xFF666666), const Color(0xFF444444)]
                                  : [
                                      Color.lerp(displayColor, Colors.black, 0.15)!,
                                      Color.lerp(displayColor, Colors.black, 0.35)!,
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$levelNumber',
                              style: TextStyle(
                                color: isLocked ? Colors.white54 : Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 1.5),
                                    blurRadius: 2.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Glossy reflection top overlay
                Positioned(
                  top: 2,
                  left: 10,
                  right: 10,
                  height: 18,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.elliptical(30, 10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Level title label badge (Turkish: Bölüm İsimleri)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey.shade800 : Color.lerp(displayColor, Colors.black, 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFD447)
                    : (isLocked ? Colors.grey : Color.lerp(displayColor, Colors.white, 0.25)!),
                width: 1.5,
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
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
      // Straight road path centered down the middle
      final x = width / 2;
      final y = i * rowHeight + rowHeight / 2;
      return Offset(x, y);
    }

    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFD447); // Gold border road

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
      final curr = getOffset(i);
      path.lineTo(curr.dx, curr.dy);
    }

    canvas.drawPath(path, pathPaint);
    canvas.drawPath(path, pathPaintInner);

    // Draw completed path line decorative segment (from bottom up)
    final completedPath = Path();
    final compStart = getOffset(itemCount - 1);
    completedPath.moveTo(compStart.dx, compStart.dy);
    for (var i = 1; i <= currentLevelIndex && i < itemCount; i++) {
      final currIndex = itemCount - 1 - i;
      final curr = getOffset(currIndex);
      completedPath.lineTo(curr.dx, curr.dy);
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

class _LevelGrid extends StatefulWidget {
  const _LevelGrid({
    required this.category,
    required this.selectedLevelIndex,
    required this.onLevelSelected,
  });

  final _LevelCategory category;
  final int selectedLevelIndex;
  final ValueChanged<int> onLevelSelected;

  @override
  State<_LevelGrid> createState() => _LevelGridState();
}

class _LevelGridState extends State<_LevelGrid> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levels = [
      for (var offset = 24; offset >= 0; offset--)
        if (widget.category.startIndex + offset < LevelData.levels.length)
          (
            index: widget.category.startIndex + offset,
            level: LevelData.levels[widget.category.startIndex + offset],
          ),
    ];

    const rowHeight = 135.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 24, bottom: 90), // Bottom padding to prevent cover by Oyna button
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
                      currentLevelIndex: widget.category.startIndex == 0 ? 3 : 0, // Mark first few levels as completed decoratively
                    ),
                  ),
                ),
                for (var itemIndex = 0; itemIndex < levels.length; itemIndex++) ...[
                  (() {
                    final item = levels[itemIndex];
                    final double topPosition = itemIndex * rowHeight + rowHeight / 2 - 37.0;
                    final isSelected = widget.selectedLevelIndex == item.index;

                    return Positioned(
                      left: 0,
                      right: 0,
                      top: topPosition,
                      child: Center(
                        child: _HexagonNode(
                          levelNumber: item.index + 1,
                          title: _cleanTitle(item.level.name),
                          color: widget.category.color,
                          isLocked: false, // In prototype select screen, levels are unlocked
                          isSelected: isSelected,
                          onTap: () => widget.onLevelSelected(item.index),
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

Future<void> _openLevel(BuildContext context, {required int levelIndex}) {
  return Navigator.of(context).push(
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
    // Elegant Art-Deco grid details or shapes
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LevelSelectAtmospherePainter oldDelegate) => false;
}
