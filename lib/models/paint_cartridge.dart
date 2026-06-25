import 'package:flutter/material.dart';

class PaintCartridge {
  const PaintCartridge({
    required this.id,
    required this.colorId,
    required this.name,
    required this.color,
    required this.amount,
    int? packageAmount,
    this.isUsed = false,
    this.isSelected = false,
  }) : packageAmount = packageAmount ?? amount;

  final int id;
  final int colorId;
  final String name;
  final Color color;
  final int amount;
  final int packageAmount;
  final bool isUsed;
  final bool isSelected;

  PaintCartridge copyWith({
    int? amount,
    int? packageAmount,
    bool? isUsed,
    bool? isSelected,
  }) {
    return PaintCartridge(
      id: id,
      colorId: colorId,
      name: name,
      color: color,
      amount: amount ?? this.amount,
      packageAmount: packageAmount ?? this.packageAmount,
      isUsed: isUsed ?? this.isUsed,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
