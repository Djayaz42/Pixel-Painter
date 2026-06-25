import 'package:flutter/material.dart';

import '../models/waiting_slot.dart';
import 'waiting_slot_widget.dart';

class WaitingSlotBar extends StatelessWidget {
  const WaitingSlotBar({
    super.key,
    required this.slots,
    required this.onSlotTap,
    this.isCompact = false,
  });

  final List<WaitingSlot> slots;
  final ValueChanged<int> onSlotTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 2 : 4),
      child: Column(
        children: [
          Row(
            children: [
              for (final slot in slots)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: WaitingSlotWidget(
                      slot: slot,
                      isCompact: isCompact,
                      onTap: () => onSlotTap(slot.index),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isCompact ? 5 : 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < slots.length; index++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: slots[index].isFilled ? 18 : 10,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color:
                        slots[index].cartridge?.color.withAlpha(190) ??
                        const Color(0xFF4C566A).withAlpha(120),
                    boxShadow: [
                      if (slots[index].isFilled)
                        BoxShadow(
                          color: slots[index].cartridge!.color.withAlpha(100),
                          blurRadius: 8,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
