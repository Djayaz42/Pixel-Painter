import 'package:flutter/material.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.progress,
    required this.paintedCount,
    required this.targetCount,
    required this.levelNumber,
    required this.levelName,
    required this.onReset,
    this.onMenu,
  });

  final double progress;
  final int paintedCount;
  final int targetCount;
  final int levelNumber;
  final String levelName;
  final VoidCallback onReset;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFBEFD3), // Warm light parchment
            Color(0xFFEEDBB3), // Warm darker parchment
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF53381B), width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF2C1908),
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB32828), Color(0xFF801A1A)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF53381B), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Text(
                  'LEVEL $levelNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  levelName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4C2F0C),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (onMenu != null) ...[
                _HeaderIconButton(
                  onPressed: onMenu!,
                  tooltip: 'Menu',
                  icon: Icons.grid_view_rounded,
                ),
                const SizedBox(width: 8),
              ],
              _HeaderIconButton(
                onPressed: onReset,
                tooltip: 'Reset',
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 17,
                      decoration: BoxDecoration(
                        color: const Color(0xFF53381B),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        height: 17,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF42E88A),
                              Color(0xFF2E8540),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFF53381B), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 76,
                child: Text(
                  '$paintedCount/$targetCount',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF4C2F0C),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$percent% pixels',
              style: const TextStyle(
                color: Color(0xFF8C642D),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.onPressed,
    required this.tooltip,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF801A1A), Color(0xFF530F0F)],
        ),
        border: Border.all(color: const Color(0xFF53381B), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF2C1908),
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: const Color(0xFFFBE49E), size: 21),
      ),
    );
  }
}
