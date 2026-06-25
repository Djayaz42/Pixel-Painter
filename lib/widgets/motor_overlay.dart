import 'package:flutter/material.dart';

import '../models/active_motor.dart';

class MotorOverlay extends StatelessWidget {
  const MotorOverlay({super.key, required this.motor, this.trackScale = 0.84});

  final ActiveMotor motor;
  final double trackScale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MotorOverlayPainter(motor: motor, trackScale: trackScale),
      child: const SizedBox.expand(),
    );
  }
}

class _MotorOverlayPainter extends CustomPainter {
  const _MotorOverlayPainter({required this.motor, required this.trackScale});

  final ActiveMotor motor;
  final double trackScale;

  @override
  void paint(Canvas canvas, Size size) {
    final frameSize = size.shortestSide;
    final trackSize = frameSize * trackScale;
    final trackRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: trackSize,
      height: trackSize,
    );
    final position = Offset(
      trackRect.left + motor.position.dx * trackRect.width,
      trackRect.top + motor.position.dy * trackRect.height,
    );
    final glowPaint = Paint()
      ..color = motor.cartridge.color.withAlpha(120)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    final shadowPaint = Paint()
      ..color = const Color(0x77000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final candyColor = Color.lerp(motor.cartridge.color, Colors.white, 0.18)!;
    final brightColor = Color.lerp(motor.cartridge.color, Colors.white, 0.08)!;
    final stickPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [brightColor, candyColor, motor.cartridge.color],
      ).createShader(const Rect.fromLTWH(-6, -2, 12, 34));
    final darkPaint = Paint()
      ..color = Color.lerp(
        motor.cartridge.color,
        Colors.black,
        0.15,
      )!;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = Colors.black;
    final angle = switch (motor.side) {
      MotorSide.top => 0.0,
      MotorSide.right => 1.5708,
      MotorSide.bottom => 3.1416,
      MotorSide.left => -1.5708,
    };

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    // Draw glowing muzzle charge at the tip of the nozzle
    canvas.drawCircle(const Offset(0, -36), 14, glowPaint);

    // 1. Draw Robotic Arm Base on the track (centered mechanical pivot)
    canvas.drawCircle(Offset.zero, 14, Paint()..color = const Color(0xFF353A47));
    canvas.drawCircle(Offset.zero, 14, borderPaint);
    canvas.drawCircle(Offset.zero, 11, Paint()..color = const Color(0xFFCE9E4F));
    canvas.drawCircle(Offset.zero, 11, borderPaint);
    canvas.drawCircle(Offset.zero, 6.5, Paint()..color = const Color(0xFF1E222D));
    canvas.drawCircle(Offset.zero, 6.5, borderPaint);

    // 2. Draw First Arm Segment (link 1, base to elbow)
    canvas.drawLine(
      Offset.zero,
      const Offset(-22, -12),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0
        ..strokeCap = StrokeCap.round
        ..color = Colors.black,
    );
    canvas.drawLine(
      Offset.zero,
      const Offset(-22, -12),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF4C5260),
    );
    canvas.drawLine(
      const Offset(-2, 1),
      const Offset(-24, -11),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF71788A),
    );

    // 3. Draw Second Joint (at the elbow)
    canvas.drawCircle(const Offset(-22, -12), 6.5, Paint()..color = const Color(0xFFCE9E4F));
    canvas.drawCircle(const Offset(-22, -12), 6.5, borderPaint);
    canvas.drawCircle(const Offset(-22, -12), 2.5, Paint()..color = Colors.black);

    // 4. Draw Second Arm Segment (link 2, elbow to hand/nozzle)
    canvas.drawLine(
      const Offset(-22, -12),
      const Offset(0, -28),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0
        ..strokeCap = StrokeCap.round
        ..color = Colors.black,
    );
    canvas.drawLine(
      const Offset(-22, -12),
      const Offset(0, -28),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF5C6274),
    );
    canvas.drawLine(
      const Offset(-20, -13),
      const Offset(2, -29),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF71788A),
    );

    // 5. Nozzle / Hand Clamp
    final headRect = Rect.fromLTWH(-10, -31, 20, 5);
    canvas.drawRect(headRect.inflate(1.2), Paint()..color = Colors.black);
    canvas.drawRect(headRect, Paint()..color = const Color(0xFF353A47));

    // 6. Draw Detailed Handgun/Pistol held by the clamp
    canvas.save();
    canvas.translate(0, -18); // Center of the pistol body

    // Slide (top part, horizontal)
    final slideRect = Rect.fromLTWH(-10, -14, 22, 6);
    canvas.drawRRect(RRect.fromRectAndRadius(slideRect.inflate(1.2), const Radius.circular(1.0)), Paint()..color = Colors.black);
    canvas.drawRRect(
      RRect.fromRectAndRadius(slideRect, const Radius.circular(1.0)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF71788A), // Light metal slide top
            const Color(0xFF353A47), // Dark metal slide bottom
          ],
        ).createShader(slideRect),
    );
    
    // Slide back serrations
    final serrationPaint = Paint()..color = Colors.black..strokeWidth = 1.0;
    for (double sx = -9; sx <= -5; sx += 2) {
      canvas.drawLine(Offset(sx, -13), Offset(sx, -9), serrationPaint);
    }

    // Gold barrel tip
    final muzzleTip = Rect.fromLTWH(12, -13, 2, 4);
    canvas.drawRect(muzzleTip, Paint()..color = const Color(0xFFCE9E4F));
    canvas.drawRect(muzzleTip, borderPaint);

    // Grip
    final gripPath = Path()
      ..moveTo(-8, -8)
      ..lineTo(-11, 4)
      ..lineTo(-5, 4)
      ..lineTo(-2, -8)
      ..close();
    canvas.drawPath(gripPath, Paint()..style = PaintingStyle.stroke..strokeWidth = 3.2..color = Colors.black..strokeJoin = StrokeJoin.round);
    canvas.drawPath(gripPath, Paint()..color = const Color(0xFF353A47));
    
    // Wooden grip panel overlay
    final woodPath = Path()
      ..moveTo(-7.5, -6)
      ..lineTo(-10.0, 3)
      ..lineTo(-6.0, 3)
      ..lineTo(-3.5, -6)
      ..close();
    canvas.drawPath(woodPath, Paint()..color = const Color(0xFFB0723A));
    canvas.drawPath(woodPath, borderPaint);

    // Trigger guard
    final guardPath = Path()
      ..moveTo(-2, -6)
      ..quadraticBezierTo(2, -4, 0, -2)
      ..lineTo(-3, -2);
    canvas.drawPath(guardPath, borderPaint);

    // Gold trigger
    canvas.drawLine(const Offset(-1.5, -5), const Offset(-0.5, -3), Paint()..color = const Color(0xFFCE9E4F)..strokeWidth = 1.2);

    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MotorOverlayPainter oldDelegate) {
    return oldDelegate.motor != motor || oldDelegate.trackScale != trackScale;
  }
}
