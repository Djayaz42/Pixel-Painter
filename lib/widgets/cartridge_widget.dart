import 'package:flutter/material.dart';

import '../models/paint_cartridge.dart';

class CartridgeWidget extends StatelessWidget {
  const CartridgeWidget({
    super.key,
    required this.cartridge,
    this.isSelected = false,
    this.isCompact = false,
    this.isHidden = false,
    this.onTap,
  });

  final PaintCartridge cartridge;
  final bool isSelected;
  final bool isCompact;
  final bool isHidden;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!isCompact && cartridge.amount <= 0) {
      return const SizedBox.shrink();
    }

    final isDisabled = cartridge.amount <= 0 || isHidden;
    const hiddenColor = Color(0xFF5F6988);
    final bodyColor = isDisabled ? hiddenColor : cartridge.color;
    final accentColor = isHidden ? hiddenColor : cartridge.color;
    final height = isCompact ? 50.0 : 96.0;
    final width = isCompact ? 58.0 : 90.0;
    final body = AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: isSelected ? 1.08 : 1,
      child: SizedBox(
        height: height,
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isCompact ? 13 : 18),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: accentColor.withAlpha(80),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              const BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _PaintBlasterPainter(
              color: bodyColor,
              accentColor: accentColor,
              isSelected: isSelected,
              isDisabled: isDisabled,
              isCompact: isCompact,
            ),
            child: Stack(
              children: [
                if (!isHidden)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: isCompact ? 4 : 7,
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: isCompact ? 25 : 34,
                          minHeight: isCompact ? 18 : 23,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 6 : 8,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isDisabled ? const Color(0xFFF3EFE9) : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isDisabled ? const Color(0xFFC8C2B7) : Colors.black,
                            width: isDisabled ? 1.2 : 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${cartridge.amount}',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDisabled ? const Color(0xFF8A7E72) : const Color(0xFF2C2A29),
                            fontSize: isCompact ? 11 : 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (onTap == null) {
      return body;
    }

    return GestureDetector(onTap: isDisabled ? null : onTap, child: body);
  }
}

class _PaintBlasterPainter extends CustomPainter {
  const _PaintBlasterPainter({
    required this.color,
    required this.accentColor,
    required this.isSelected,
    required this.isDisabled,
    required this.isCompact,
  });

  final Color color;
  final Color accentColor;
  final bool isSelected;
  final bool isDisabled;
  final bool isCompact;

  @override
  void paint(Canvas canvas, Size size) {
    final candyColor = Color.lerp(accentColor, Colors.white, 0.35)!;
    final brightColor = Color.lerp(accentColor, Colors.white, 0.22)!;
    final deepColor = Color.lerp(color, Colors.black, 0.14)!;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.8 : (isDisabled ? 1.4 : 1.8)
      ..color = isDisabled
          ? const Color(0xFFC8C2B7)
          : Colors.black;
    final stickPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          brightColor.withAlpha(isDisabled ? 120 : 240),
          accentColor.withAlpha(isDisabled ? 120 : 235),
          color.withAlpha(isDisabled ? 135 : 235),
        ],
      ).createShader(Offset.zero & size);
    final shinePaint = Paint()..color = Colors.white.withAlpha(155);
    final shadowPaint = Paint()
      ..color = const Color(0x66000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final weaponPaint = _WeaponPaints(
      color: color,
      accentColor: accentColor,
      candyColor: candyColor,
      brightColor: brightColor,
      deepColor: deepColor,
      stickPaint: stickPaint,
      borderPaint: borderPaint,
      shadowPaint: shadowPaint,
      isDisabled: isDisabled,
    );

    _drawCapsuleBuddy(canvas, size, weaponPaint);


  }

  @override
  bool shouldRepaint(covariant _PaintBlasterPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isDisabled != isDisabled;
  }

  void _drawCapsuleBuddy(Canvas canvas, Size size, _WeaponPaints paints) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Left & Right Ears
    final leftEarPath = Path()
      ..moveTo(w * 0.28, h * 0.22)
      ..cubicTo(w * 0.18, h * 0.04, w * 0.38, h * 0.04, w * 0.38, h * 0.22)
      ..close();
    canvas.drawPath(leftEarPath, Paint()..color = paints.deepColor);
    canvas.drawPath(leftEarPath, paints.borderPaint);

    final leftInnerEarPath = Path()
      ..moveTo(w * 0.30, h * 0.20)
      ..cubicTo(w * 0.22, h * 0.08, w * 0.36, h * 0.08, w * 0.36, h * 0.20)
      ..close();
    canvas.drawPath(leftInnerEarPath, Paint()..color = paints.brightColor);

    final rightEarPath = Path()
      ..moveTo(w * 0.62, h * 0.22)
      ..cubicTo(w * 0.62, h * 0.04, w * 0.82, h * 0.04, w * 0.72, h * 0.22)
      ..close();
    canvas.drawPath(rightEarPath, Paint()..color = paints.deepColor);
    canvas.drawPath(rightEarPath, paints.borderPaint);

    final rightInnerEarPath = Path()
      ..moveTo(w * 0.64, h * 0.20)
      ..cubicTo(w * 0.64, h * 0.08, w * 0.78, h * 0.08, w * 0.70, h * 0.20)
      ..close();
    canvas.drawPath(rightInnerEarPath, Paint()..color = paints.brightColor);

    // 2. Draw Feet
    final leftFoot = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.80, w * 0.16, h * 0.12),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(leftFoot, Paint()..color = paints.deepColor);
    canvas.drawRRect(leftFoot, paints.borderPaint);

    final rightFoot = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.56, h * 0.80, w * 0.16, h * 0.12),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(rightFoot, Paint()..color = paints.deepColor);
    canvas.drawRRect(rightFoot, paints.borderPaint);

    // 3. Draw Curly Tail
    final tailPaint = Paint()
      ..color = paints.deepColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final tailPath = Path()
      ..moveTo(w * 0.5, h * 0.80)
      ..quadraticBezierTo(w * 0.54, h * 0.87, w * 0.5, h * 0.90)
      ..quadraticBezierTo(w * 0.46, h * 0.87, w * 0.48, h * 0.84);
    canvas.drawPath(tailPath, tailPaint);

    // 4. Draw Main Body Capsule
    final bodyRect = Rect.fromLTWH(w * 0.18, h * 0.16, w * 0.64, h * 0.66);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.28));
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          paints.brightColor,
          paints.color,
          paints.deepColor,
        ],
      ).createShader(bodyRect);
    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.drawRRect(bodyRRect, paints.borderPaint);
  }
}

class _WeaponPaints {
  const _WeaponPaints({
    required this.color,
    required this.accentColor,
    required this.candyColor,
    required this.brightColor,
    required this.deepColor,
    required this.stickPaint,
    required this.borderPaint,
    required this.shadowPaint,
    required this.isDisabled,
  });

  final Color color;
  final Color accentColor;
  final Color candyColor;
  final Color brightColor;
  final Color deepColor;
  final Paint stickPaint;
  final Paint borderPaint;
  final Paint shadowPaint;
  final bool isDisabled;
}
