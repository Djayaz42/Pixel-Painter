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
              Color(0xFFD85D2A), // Rust / Copper Orange
              Color(0xFF6B1D2F), // Deep Wine Red / Burgundy
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background mechanical gear wheels and astronomy grids
              const Positioned.fill(
                child: CustomPaint(
                  painter: _LevelSelectAtmospherePainter(),
                ),
              ),

              // Main HUD Layout
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Stats Bar (Wooden / Steampunk style capsules)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Capsule: Bronze Nut (Coins)
                        Expanded(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8A5A36), Color(0xFF633D20)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFD4C29D), width: 1.8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 4),
                              ],
                            ),
                            child: Row(
                              children: [
                                const _BronzeNutIcon(size: 20),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${GameStats.gold}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.add_circle_rounded, color: Color(0xFFFBE49E), size: 14),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Middle Capsule: Blue Gem (Gems/Points)
                        Expanded(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8A5A36), Color(0xFF633D20)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFD4C29D), width: 1.8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 4),
                              ],
                            ),
                            child: Row(
                              children: [
                                const _BlueGemIcon(size: 20),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    '65', // Decorative Gem Count
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.add_circle_rounded, color: Color(0xFFFBE49E), size: 14),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Right Capsule: Flame (Lives Timer)
                        Expanded(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8A5A36), Color(0xFF633D20)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFD4C29D), width: 1.8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 4),
                              ],
                            ),
                            child: Row(
                              children: [
                                const _BlueFlameIcon(size: 20),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    GameStats.lives >= GameStats.maxLives ? '00:00' : '04:59', // Decorative Timer
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.add_circle_rounded, color: Color(0xFFFBE49E), size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Selector (Steampunk TabBar)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF53381B).withAlpha(200),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4C29D), width: 1.8),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: const Color(0xFFD4C29D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF53381B), width: 1.5),
                        ),
                        labelColor: const Color(0xFF2C1908),
                        unselectedLabelColor: const Color(0xFFFBE49E),
                        tabs: [
                          for (final category in LevelSelectScreen._categories)
                            Tab(icon: Icon(category.icon, size: 20)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Main List View containing level path (metallic chains)
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

              // HUD Side Buttons - Left Side (Decorative stars and chest)
              Positioned(
                left: 12,
                top: 130,
                bottom: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _HUDIconButton(
                      icon: Icons.star_rounded,
                      label: '30/50',
                      color: Color(0xFFFFD447),
                    ),
                    SizedBox(height: 24),
                    _HUDIconButton(
                      icon: Icons.card_giftcard_rounded,
                      label: 'GO',
                      color: Color(0xFF9B51E0),
                    ),
                  ],
                ),
              ),

              // Floating Enter Button at the bottom center (Carved wooden plaque style)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _openLevel(context, levelIndex: _selectedLevelIndex).then((_) {
                        setState(() {});
                      });
                    },
                    child: Container(
                      height: 58,
                      width: 190,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF53381B), width: 3),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFAB7B56), Color(0xFF6B3B1D)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            offset: Offset(0, 4),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Enter',
                          style: TextStyle(
                            color: Color(0xFFFBE49E),
                            fontSize: 24,
                            fontFamily: 'Serif',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(color: Colors.black87, offset: Offset(0, 1.5), blurRadius: 3.0),
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
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8A5A36), Color(0xFF633D20)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: const Color(0xFFD4C29D), width: 2.2),
            boxShadow: const [
              BoxShadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 4),
            ],
          ),
          child: Center(
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF53381B).withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD4C29D), width: 1.0),
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

class _BronzeNutIcon extends StatelessWidget {
  const _BronzeNutIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFCD7F32),
        border: Border.all(color: const Color(0xFFE5C158), width: 1.8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 1),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.4,
          height: size * 0.4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF633D20),
          ),
        ),
      ),
    );
  }
}

class _BlueGemIcon extends StatelessWidget {
  const _BlueGemIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2FA5F8), Color(0xFF0F5AA6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.diamond_rounded,
          color: Colors.white.withOpacity(0.9),
          size: size * 0.7,
        ),
      ),
    );
  }
}

class _BlueFlameIcon extends StatelessWidget {
  const _BlueFlameIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2FA5F8), Color(0xFF0B3B70)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_fire_department_rounded,
          color: Colors.white.withOpacity(0.95),
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

class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final int points = 5;
    final double outerRadius = w / 2;
    final double innerRadius = w / 4.5;
    
    final double angle = math.pi / points;
    path.moveTo(cx, cy - outerRadius);
    for (int i = 1; i < points * 2; i++) {
      final double r = i.isOdd ? innerRadius : outerRadius;
      final double a = i * angle - math.pi / 2;
      path.lineTo(cx + math.cos(a) * r, cy + math.sin(a) * r);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _LevelPathNode extends StatelessWidget {
  const _LevelPathNode({
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
    
    // Determine tiered design
    final int designType = levelNumber % 4; // 0: Star, 1: Golden Hexagon, 2: Green Hexagon, 3: Mystic Hexagon

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              clipBehavior: Clip.none,
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

                // Mystic Orbiting Rings (for design type 3)
                if (designType == 3)
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: _OrbitingRingsPainter(color: Color(0xFF42E88A)),
                    ),
                  ),

                // 3D Shadow Layer (moved down)
                Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  bottom: -5,
                  child: ClipPath(
                    clipper: designType == 0 ? _StarClipper() : HexagonClipper(),
                    child: Container(
                      color: isLocked ? Colors.black45 : Color.lerp(displayColor, Colors.black, 0.45),
                    ),
                  ),
                ),

                // Main Node shape
                ClipPath(
                  clipper: designType == 0 ? _StarClipper() : HexagonClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [const Color(0xFFFFD447), const Color(0xFFE29B3C)]
                            : (isLocked
                                ? [const Color(0xFF9E9E9E), const Color(0xFF757575)]
                                : _getTierColors(designType, displayColor)),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.5), // border thickness
                      child: ClipPath(
                        clipper: designType == 0 ? _StarClipper() : HexagonClipper(),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLocked
                                  ? [const Color(0xFF666666), const Color(0xFF444444)]
                                  : [
                                      Color.lerp(_getTierMainColor(designType, displayColor), Colors.black, 0.15)!,
                                      Color.lerp(_getTierMainColor(designType, displayColor), Colors.black, 0.35)!,
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
                                fontSize: designType == 0 ? 17 : 20, // slightly smaller text for star shape
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
              color: isLocked ? Colors.grey.shade800 : Color.lerp(displayColor, Colors.black, 0.35),
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

  List<Color> _getTierColors(int designType, Color baseColor) {
    if (designType == 0) {
      // Blue star legendary
      return [const Color(0xFF5D9EF7), const Color(0xFF1B60C6)];
    } else if (designType == 1) {
      // Golden Expert
      return [const Color(0xFFFBE49E), const Color(0xFFC86446)];
    } else if (designType == 3) {
      // Emerald Mystic
      return [const Color(0xFF42E88A), const Color(0xFF1E8233)];
    }
    // Default base color hexagon
    return [
      Color.lerp(baseColor, Colors.white, 0.35)!,
      Color.lerp(baseColor, Colors.black, 0.25)!,
    ];
  }

  Color _getTierMainColor(int designType, Color baseColor) {
    if (designType == 0) {
      return const Color(0xFF2673D9);
    } else if (designType == 1) {
      return const Color(0xFFAB7315);
    } else if (designType == 3) {
      return const Color(0xFF22B85E);
    }
    return baseColor;
  }
}

class _OrbitingRingsPainter extends CustomPainter {
  const _OrbitingRingsPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(math.pi / 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.width * 1.15, height: size.height * 0.4),
      paint,
    );
    canvas.rotate(-math.pi / 3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.width * 1.15, height: size.height * 0.4),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

    final centerX = size.width / 2;

    // Draw metallic chains
    final chainPaint = Paint()
      ..color = const Color(0xFF3E1F15) // Dark rust metal border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;

    final chainFill = Paint()
      ..color = const Color(0xFF8A5A36) // Copper metal inner highlight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final completedChainPaint = Paint()
      ..color = const Color(0xFF42E88A) // Active/completed green chain glow border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;

    final completedChainFill = Paint()
      ..color = const Color(0xFFB4FCE0) // Green inner highlight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final startY = rowHeight / 2;
    final endY = (itemCount - 1) * rowHeight + rowHeight / 2;

    // 1. Draw regular background chains
    for (double y = startY; y < endY; y += 12) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(centerX, y), width: 9, height: 18),
          const Radius.circular(4.5),
        ),
        chainPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(centerX, y), width: 5, height: 14),
          const Radius.circular(2.5),
        ),
        chainFill,
      );
    }

    // 2. Draw green completed chains (from bottom up)
    final greenStartY = endY;
    final greenEndY = endY - (currentLevelIndex * rowHeight);

    for (double y = greenStartY; y >= greenEndY && y >= startY; y -= 12) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(centerX, y), width: 9, height: 18),
          const Radius.circular(4.5),
        ),
        completedChainPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(centerX, y), width: 5, height: 14),
          const Radius.circular(2.5),
        ),
        completedChainFill,
      );
    }
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
          padding: const EdgeInsets.only(top: 24, bottom: 90), // prevent covered by Enter button
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
                      currentLevelIndex: widget.category.startIndex == 0 ? 3 : 0, // completed line decoration
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
                        child: _LevelPathNode(
                          levelNumber: item.index + 1,
                          title: _cleanTitle(item.level.name),
                          color: widget.category.color,
                          isLocked: false,
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
    final paint = Paint()
      ..color = const Color(0xFF53381B).withOpacity(0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // Draw mechanical gear wheels in the background
    _drawGear(canvas, Offset(size.width * 0.1, size.height * 0.2), 65, 12, paint);
    _drawGear(canvas, Offset(size.width * 0.85, size.height * 0.38), 90, 16, paint);
    _drawGear(canvas, Offset(size.width * 0.15, size.height * 0.65), 110, 20, paint);
    _drawGear(canvas, Offset(size.width * 0.8, size.height * 0.82), 75, 14, paint);

    // Draw subtle celestial stars in background
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    _drawTinyStar(canvas, Offset(size.width * 0.25, size.height * 0.1), starPaint);
    _drawTinyStar(canvas, Offset(size.width * 0.75, size.height * 0.2), starPaint);
    _drawTinyStar(canvas, Offset(size.width * 0.45, size.height * 0.45), starPaint);
    _drawTinyStar(canvas, Offset(size.width * 0.3, size.height * 0.75), starPaint);
  }

  void _drawGear(Canvas canvas, Offset center, double radius, int teethCount, Paint paint) {
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.4, paint); // inner center hole
    
    // Draw teeth trapezoids
    final double toothAngle = 2 * math.pi / teethCount;
    for (int i = 0; i < teethCount; i++) {
      final double angle = i * toothAngle;
      final toothPath = Path();
      
      final double x1 = center.dx + math.cos(angle - 0.1) * radius;
      final double y1 = center.dy + math.sin(angle - 0.1) * radius;
      final double x2 = center.dx + math.cos(angle + 0.1) * radius;
      final double y2 = center.dy + math.sin(angle + 0.1) * radius;
      
      final double x3 = center.dx + math.cos(angle + 0.07) * (radius + 8);
      final double y3 = center.dy + math.sin(angle + 0.07) * (radius + 8);
      final double x4 = center.dx + math.cos(angle - 0.07) * (radius + 8);
      final double y4 = center.dy + math.sin(angle - 0.07) * (radius + 8);
      
      toothPath.moveTo(x1, y1);
      toothPath.lineTo(x4, y4);
      toothPath.lineTo(x3, y3);
      toothPath.lineTo(x2, y2);
      toothPath.close();
      canvas.drawPath(toothPath, paint);
    }
  }

  void _drawTinyStar(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    final double cx = center.dx;
    final double cy = center.dy;
    
    path.moveTo(cx, cy - 6);
    path.lineTo(cx + 1.8, cy - 1.8);
    path.lineTo(cx + 6, cy);
    path.lineTo(cx + 1.8, cy + 1.8);
    path.lineTo(cx, cy + 6);
    path.lineTo(cx - 1.8, cy + 1.8);
    path.lineTo(cx - 6, cy);
    path.lineTo(cx - 1.8, cy - 1.8);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LevelSelectAtmospherePainter oldDelegate) => false;
}
