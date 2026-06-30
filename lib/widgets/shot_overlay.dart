import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/shot_event.dart';

class ShotOverlay extends StatelessWidget {
  const ShotOverlay({
    super.key,
    required this.shot,
    this.artScale = 0.64,
    this.trackScale = 0.84,
  });

  final ShotEvent shot;
  final double artScale;
  final double trackScale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShotOverlayPainter(
        shot: shot,
        artScale: artScale,
        trackScale: trackScale,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ShotOverlayPainter extends CustomPainter {
  const _ShotOverlayPainter({
    required this.shot,
    required this.artScale,
    required this.trackScale,
  });

  final ShotEvent shot;
  final double artScale;
  final double trackScale;

  @override
  void paint(Canvas canvas, Size size) {
    final age = DateTime.now().difference(shot.createdAt).inMilliseconds;
    final t = (age / 700).clamp(0.0, 1.0);
    final alpha = ((1 - t) * 255).round();
    final frameSize = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final trackSize = frameSize * trackScale;
    final artSize = frameSize * artScale;
    final trackRect = Rect.fromCenter(
      center: center,
      width: trackSize,
      height: trackSize,
    );
    final artRect = Rect.fromCenter(
      center: center,
      width: artSize,
      height: artSize,
    );
    final from = Offset(
      trackRect.left + shot.from.dx * trackRect.width,
      trackRect.top + shot.from.dy * trackRect.height,
    );
    final to = Offset(
      artRect.left + shot.to.dx * artRect.width,
      artRect.top + shot.to.dy * artRect.height,
    );
    final current = Offset.lerp(from, to, Curves.easeOutCubic.transform(t))!;
    final direction = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final tail = Offset(
      current.dx - math.cos(direction) * 8,
      current.dy - math.sin(direction) * 8,
    );

    canvas.drawCircle(
      current,
      5.5,
      Paint()
        ..color = shot.color.withAlpha((80 * (1 - t)).round())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5),
    );
    canvas.drawLine(
      tail,
      current,
      Paint()
        ..color = shot.color.withAlpha((95 * (1 - t)).round())
        ..strokeWidth = 2.1
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      current,
      3.1,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withAlpha(alpha),
            Color.lerp(shot.color, Colors.white, 0.36)!.withAlpha(alpha),
            shot.color.withAlpha(alpha),
          ],
        ).createShader(Rect.fromCircle(center: current, radius: 5.2)),
    );
    canvas.drawCircle(
      current.translate(-math.cos(direction) * 1.1, -math.sin(direction) * 1.1),
      0.95,
      Paint()..color = Colors.white.withAlpha((210 * (1 - t)).round()),
    );

    final sparkPaint = Paint()
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withAlpha((190 * (1 - t)).round());
    for (var i = 0; i < 5; i++) {
      final angle = i * 1.047 + 0.25;
      final start = Offset(
        to.dx + math.cos(angle) * (4 + t * 2),
        to.dy + math.sin(angle) * (4 + t * 2),
      );
      final end = Offset(
        to.dx + math.cos(angle) * (7 + t * 8),
        to.dy + math.sin(angle) * (7 + t * 8),
      );
      canvas.drawLine(start, end, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShotOverlayPainter oldDelegate) {
    return oldDelegate.shot != shot ||
        oldDelegate.artScale != artScale ||
        oldDelegate.trackScale != trackScale;
  }
}
