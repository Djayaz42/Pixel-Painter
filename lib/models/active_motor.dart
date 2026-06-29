import 'package:flutter/material.dart';

import 'paint_cartridge.dart';

enum MotorSide { top, right, bottom, left }

class ActiveMotor {
  const ActiveMotor({
    required this.cartridge,
    required this.progress,
    required this.position,
    required this.side,
    required this.lineIndex,
    this.isGhost = false,
  });

  final PaintCartridge cartridge;
  final double progress;
  final Offset position;
  final MotorSide side;
  final int lineIndex;
  final bool isGhost;
}
