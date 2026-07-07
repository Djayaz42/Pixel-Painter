import 'paint_cartridge.dart';

enum WaitingSlotStatus { empty, waiting, running, completed }

class WaitingSlot {
  const WaitingSlot({
    required this.index,
    this.cartridge,
    this.status = WaitingSlotStatus.empty,
    this.isLocked = false,
    this.lockCount,
  });

  final int index;
  final PaintCartridge? cartridge;
  final WaitingSlotStatus status;
  final bool isLocked;
  final int? lockCount;

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
      isLocked: isLocked,
      lockCount: lockCount,
    );
  }

  WaitingSlot copyWith({
    PaintCartridge? cartridge,
    WaitingSlotStatus? status,
    bool? isLocked,
    int? lockCount,
  }) {
    return WaitingSlot(
      index: index,
      cartridge: cartridge ?? this.cartridge,
      status: status ?? this.status,
      isLocked: isLocked ?? this.isLocked,
      lockCount: lockCount ?? this.lockCount,
    );
  }

  WaitingSlot markRunning() {
    return WaitingSlot(
      index: index,
      status: WaitingSlotStatus.running,
      isLocked: isLocked,
      lockCount: lockCount,
    );
  }

  WaitingSlot clearCompleted() {
    return WaitingSlot(
      index: index,
      isLocked: isLocked,
      lockCount: lockCount,
    );
  }
}
