import 'package:flutter/material.dart';

class ShotEvent {
  const ShotEvent({
    required this.from,
    required this.to,
    required this.color,
    required this.createdAt,
  });

  final Offset from;
  final Offset to;
  final Color color;
  final DateTime createdAt;
}
