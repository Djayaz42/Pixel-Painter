import 'package:flutter/material.dart';

import '../models/active_motor.dart';
import '../models/pixel_cell.dart';
import '../models/shot_event.dart';
import 'motor_overlay.dart';
import 'pixel_grid_view.dart';
import 'shot_overlay.dart';

class GameBoardPanel extends StatelessWidget {
  const GameBoardPanel({
    super.key,
    required this.cells,
    required this.colorValues,
    required this.rows,
    required this.cols,
    this.activeMotors = const [],
    this.shotEvents = const [],
    this.maxSide,
    this.isCompact = false,
    this.backgroundColors = const <int>{},
    this.onCellTap,
    this.hasChainDecoration = false,
    this.brokenLinks = const [],
    this.chainLinkHits = const [],
    this.levelIndex = 0,
  });

  final List<PixelCell> cells;
  final Map<int, Color> colorValues;
  final int rows;
  final int cols;
  final List<ActiveMotor> activeMotors;
  final List<ShotEvent> shotEvents;
  final double? maxSide;
  final bool isCompact;
  final Set<int> backgroundColors;
  final Function(int row, int col)? onCellTap;
  final bool hasChainDecoration;
  final List<int> brokenLinks;
  final List<int> chainLinkHits;
  final int levelIndex;

  @override
  Widget build(BuildContext context) {
    final outerPadding = isCompact ? 7.0 : 10.0;
    final innerPadding = isCompact ? 8.0 : 12.0;
    const gridScale = 0.64;
    const motorTrackScale = 0.84;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxSide ?? double.infinity),
      child: Container(
        padding: EdgeInsets.all(outerPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isCompact ? 24 : 30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5E697F), // Slate highlight
              Color(0xFF4C566A), // Slate gray
              Color(0xFF2E3440), // Polar night dark
            ],
          ),
          border: Border.all(color: const Color(0xFF1A1D24), width: 2.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF15181E),
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(innerPadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF434C5E),
                Color(0xFF3B4252),
                Color(0xFF2E3440),
              ],
            ),
            borderRadius: BorderRadius.circular(isCompact ? 18 : 22),
            border: Border.all(color: const Color(0xFF1A1D24), width: 1.8),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return GestureDetector(
                  onTapUp: (details) {
                    if (onCellTap == null) return;
                    final frameSize = size.shortestSide;
                    final frameOrigin = Offset(
                      (size.width - frameSize) / 2,
                      (size.height - frameSize) / 2,
                    );
                    final cellSize = frameSize * gridScale / rows;
                    final artWidth = cellSize * cols;
                    final artHeight = cellSize * rows;
                    final origin =
                        frameOrigin +
                        Offset((frameSize - artWidth) / 2, (frameSize - artHeight) / 2);

                    final pos = details.localPosition;
                    final dx = pos.dx - origin.dx;
                    final dy = pos.dy - origin.dy;

                    if (dx >= 0 && dx < artWidth && dy >= 0 && dy < artHeight) {
                      final col = (dx / cellSize).floor();
                      final row = (dy / cellSize).floor();
                      onCellTap!(row, col);
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: PixelGridView(
                          cells: cells,
                          colorValues: colorValues,
                          rows: rows,
                          cols: cols,
                          artScale: gridScale,
                          backgroundColors: backgroundColors,
                          activeMotorsCount: activeMotors.where((m) => !m.isGhost).length,
                          hasChainDecoration: hasChainDecoration,
                          brokenLinks: brokenLinks,
                          chainLinkHits: chainLinkHits,
                          levelIndex: levelIndex,
                        ),
                      ),
                      for (final shotEvent in shotEvents)
                        Positioned.fill(
                          child: ShotOverlay(
                            shot: shotEvent,
                            artScale: gridScale,
                            trackScale: motorTrackScale,
                          ),
                        ),
                      for (final activeMotor in activeMotors)
                        Positioned.fill(
                          child: MotorOverlay(
                            motor: activeMotor,
                            trackScale: motorTrackScale,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
