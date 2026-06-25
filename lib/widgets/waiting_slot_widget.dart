import 'package:flutter/material.dart';

import '../models/waiting_slot.dart';
import 'cartridge_widget.dart';

class WaitingSlotWidget extends StatelessWidget {
  const WaitingSlotWidget({
    super.key,
    required this.slot,
    required this.onTap,
    this.isCompact = false,
  });

  final WaitingSlot slot;
  final VoidCallback onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isDone = slot.isCompleted || (slot.cartridge?.amount ?? 1) <= 0;
    final borderColor = switch (slot.status) {
      WaitingSlotStatus.empty => const Color(0xFF4C566A),
      WaitingSlotStatus.waiting =>
        slot.cartridge?.color ?? const Color(0xFF4C566A),
      WaitingSlotStatus.running => const Color(0xFF88C0D0),
      WaitingSlotStatus.completed => const Color(0xFF4C566A).withAlpha(120),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: isCompact ? 52 : 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B4252), // Slate grey top
              Color(0xFF2E3440), // Polar night dark bottom
            ],
          ),
          border: Border.all(
            color: borderColor,
            width: 3.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1E222A),
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: slot.cartridge == null || slot.isRunning
              ? Container(
                  width: isCompact ? 26 : 30,
                  height: isCompact ? 26 : 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: slot.isRunning
                          ? const Color(0xFF88C0D0)
                          : const Color(0xFF4C566A),
                      width: 1.8,
                    ),
                    color: slot.isRunning
                        ? const Color(0xFF88C0D0).withAlpha(45)
                        : const Color(0xFF232830),
                    boxShadow: [
                      if (slot.isRunning)
                        const BoxShadow(
                          color: Color(0x6688C0D0),
                          blurRadius: 8,
                        ),
                    ],
                  ),
                  child: Icon(
                    slot.isRunning
                        ? Icons.radio_button_checked_rounded
                        : Icons.add_rounded,
                    size: isCompact ? 16 : 18,
                    color: slot.isRunning
                        ? const Color(0xFF88C0D0)
                        : const Color(0xFF4C566A),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Opacity(
                    opacity: isDone ? 0.48 : 1,
                    child: CartridgeWidget(
                      cartridge: slot.cartridge!,
                      isCompact: true,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
