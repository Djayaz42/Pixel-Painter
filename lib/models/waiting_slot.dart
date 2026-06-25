import 'paint_cartridge.dart';

enum WaitingSlotStatus { empty, waiting, running, completed }

class WaitingSlot {
  const WaitingSlot({
    required this.index,
    this.cartridge,
    this.status = WaitingSlotStatus.empty,
  });

  final int index;
  final PaintCartridge? cartridge;
  final WaitingSlotStatus status;

  bool get isFilled => cartridge != null;

  bool get isWaiting => status == WaitingSlotStatus.waiting;

  bool get isRunning => status == WaitingSlotStatus.running;

  bool get isCompleted => status == WaitingSlotStatus.completed;

  WaitingSlot fill(PaintCartridge selectedCartridge) {
    if (isFilled) {
      return this;
    }

    return WaitingSlot(
      index: index,
      cartridge: selectedCartridge,
      status: WaitingSlotStatus.waiting,
    );
  }

  WaitingSlot copyWith({PaintCartridge? cartridge, WaitingSlotStatus? status}) {
    return WaitingSlot(
      index: index,
      cartridge: cartridge ?? this.cartridge,
      status: status ?? this.status,
    );
  }

  WaitingSlot markRunning() {
    return WaitingSlot(index: index, status: WaitingSlotStatus.running);
  }

  WaitingSlot clearCompleted() {
    return WaitingSlot(index: index);
  }
}
