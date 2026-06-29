import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../engine/motor_path_engine.dart';
import '../models/active_motor.dart';
import '../models/level_data.dart';
import '../models/paint_cartridge.dart';
import '../models/pixel_cell.dart';
import '../models/shot_event.dart';
import '../models/waiting_slot.dart';
import '../widgets/cartridge_bar.dart';
import '../widgets/game_board_panel.dart';
import '../widgets/progress_header.dart';
import '../widgets/waiting_slot_bar.dart';

int level34Seed = 1801;

class CartridgeBatchPlanner {
  static const List<int> allowedAmounts = [10, 15, 20];
  static const List<int> _preferredAmounts = [20, 15, 10];
  static const List<int> _largePreferredAmounts = [40, 30, 20, 15, 10];

  static List<int> plan({
    required int deficit,
    required int fortyBudget,
    bool allowLarge = false,
    bool forceFirstThreeAsTen = false,
    bool onlyThirtyAndForty = false,
  }) {
    if (deficit <= 0) {
      return const [];
    }

    int target = deficit;
    if (target < 10) target = 10;
    if (target % 5 != 0) {
      target = ((target + 2) ~/ 5) * 5;
    }

    if (onlyThirtyAndForty) {
      final result = _findExactPartitionForBackground(target);
      if (result != null) return result;
      return [30];
    }

    final result = _findExactPartition(target, allowLarge);
    if (result != null) {
      return result;
    }

    return [10];
  }

  static List<int>? _findExactPartition(int amount, bool allowLarge) {
    if (amount == 0) return [];
    if (amount < 10) return null;
    
    final allowed = allowLarge 
        ? const [40, 30, 20, 15, 10] 
        : const [20, 15, 10];
        
    for (int size in allowed) {
      if (amount >= size) {
        final sub = _findExactPartition(amount - size, allowLarge);
        if (sub != null) {
          return [size, ...sub];
        }
      }
    }
    return null;
  }

  static List<int>? _findExactPartitionForBackground(int amount) {
    if (amount == 0) return [];
    if (amount < 30) return null;
    
    const allowed = [40, 30];
    for (int size in allowed) {
      if (amount >= size) {
        final sub = _findExactPartitionForBackground(amount - size);
        if (sub != null) {
          return [size, ...sub];
        }
      }
    }
    return null;
  }

  static int _representableTarget(int deficit) {
    if (deficit <= 10) {
      return 10;
    }
    return ((deficit + 4) ~/ 5) * 5;
  }

  static bool _isRepresentable(int amount) {
    return amount == 0 || amount >= 10 && amount % 5 == 0;
  }

  static int _scoreAmount(
    int amount, {
    required int? previousAmount,
    required int usedCount,
    required bool allowLarge,
  }) {
    final baseScore = switch (amount) {
      40 => allowLarge ? 0 : 20,
      30 => allowLarge ? 1 : 7,
      20 => allowLarge ? 2 : 0,
      15 => allowLarge ? 3 : 2,
      10 => allowLarge ? 4 : 4,
      _ => 100,
    };
    final repeatPenalty = previousAmount == amount ? 5 : 0;
    return baseScore + repeatPenalty + usedCount * 2;
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.initialLevelIndex = 0, this.onOpenMenu});

  final int initialLevelIndex;
  final VoidCallback? onOpenMenu;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _lapDuration = Duration(milliseconds: 6500);
  static const Duration _lifeRestoreDuration = Duration(minutes: 30);
  static const int _maxLives = 5;
  static const int _orbitPullCount = 5;

  late final Ticker _ticker;
  late List<PixelCell> _cells;
  late List<PaintCartridge> _cartridges;
  late List<WaitingSlot> _slots;
  final List<_MovingMotor> _movingMotors = [];
  final List<_FiringMotor> _firingMotors = [];
  final List<ShotEvent> _shotEvents = [];
  final Set<int> _burnedColorIds = {};
  bool _isGameOver = false;
  bool _isMagnetModeActive = false;
  bool _showCompletionOverlay = false;
  DateTime? _completedAt;
  DateTime? _nextLifeAt;
  Timer? _lifeTimer;
  int _lives = _maxLives;
  int _nextRunId = 1;
  int _generatedFortyCount = 0;
  late int _levelIndex;

  @override
  void initState() {
    super.initState();
    _levelIndex = widget.initialLevelIndex.clamp(
      0,
      LevelData.levels.length - 1,
    );
    _ticker = createTicker(_handleTick);
    _resetPrototype();
    _lifeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _restoreLives();
    });
  }

  @override
  void dispose() {
    _lifeTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  int get _targetCount => _cells.where((cell) => cell.isTarget).length;

  LevelDefinition get _level => LevelData.levelAt(_levelIndex);

  int get _gridRows => _level.gridRows;

  int get _gridCols => _level.gridCols;

  int get _paintedCount =>
      _cells.where((cell) => cell.isTarget && cell.isPainted).length;

  double get _progress => _targetCount == 0 ? 0 : _paintedCount / _targetCount;

  bool get _isLevelComplete =>
      _targetCount > 0 && _paintedCount == _targetCount;

  List<ActiveMotor> get _activeMotors {
    final now = DateTime.now();

    return [
      for (final motor in _movingMotors)
        MotorPathEngine.activeMotorAt(
          cartridge: motor.cartridge,
          progress: _progressFor(motor.startedAt, now),
          rows: _gridRows,
          cols: _gridCols,
        ),
      for (final motor in _firingMotors)
        MotorPathEngine.activeMotorAt(
          cartridge: motor.cartridge,
          progress: _progressFor(motor.startedAt, now),
          rows: _gridRows,
          cols: _gridCols,
        ),
    ];
  }

  int get _activeOrbitCount => _movingMotors.length + _firingMotors.length;

  String get _lifeStatusText {
    if (_lives >= _maxLives || _nextLifeAt == null) {
      return 'Can $_lives/$_maxLives';
    }
    final remaining = _nextLifeAt!.difference(DateTime.now());
    if (remaining.isNegative) {
      return 'Can $_lives/$_maxLives';
    }
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return 'Can $_lives/$_maxLives  +1 $minutes:$seconds';
  }

  void _selectCartridge(PaintCartridge cartridge) {
    final currentCartridge = _cartridges.firstWhere(
      (item) => item.id == cartridge.id,
      orElse: () => cartridge,
    );
    if (_isGameOver ||
        currentCartridge.amount <= 0 ||
        _activeOrbitCount >= _orbitPullCount) {
      return;
    }

    setState(() {
      _movingMotors.add(
        _MovingMotor(
          runId: _nextRunId++,
          cartridge: currentCartridge.copyWith(isSelected: false),
          startedAt: DateTime.now(),
          processedLineKeys: <String>{},
        ),
      );
      _cartridges = [
        for (final item in _cartridges)
          if (item.id == currentCartridge.id)
            item.copyWith(amount: 0, isSelected: false)
          else
            item.copyWith(isSelected: false),
      ];
    });
    _ensureTicker();
  }

  void _useMagnetBooster() {
    if (_isGameOver) return;
    setState(() {
      _isMagnetModeActive = !_isMagnetModeActive;
    });
    if (_isMagnetModeActive) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mıknatıs Aktif! Silmek istediğiniz renge ait bir piksele dokunun.',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 4),
          backgroundColor: Color(0xFF1E4C80),
        ),
      );
    }
  }

  void _onBoardCellTapped(int row, int col) {
    if (!_isMagnetModeActive) return;

    final tappedCell = _cells.firstWhere(
      (cell) => cell.row == row && cell.col == col,
      orElse: () => const PixelCell(row: -1, col: -1, targetColorId: -1),
    );

    if (tappedCell.row != -1 && tappedCell.isTarget) {
      final selectedColorId = tappedCell.targetColorId;
      
      setState(() {
        _isMagnetModeActive = false;
        
        _cells = [
          for (final cell in _cells)
            if (cell.isTarget && cell.targetColorId == selectedColorId)
              cell.copyWith(isPainted: true)
            else
              cell
        ];

        _cartridges.removeWhere((c) => c.colorId == selectedColorId);
        _slots = [
          for (final slot in _slots)
            if (slot.cartridge?.colorId == selectedColorId)
              WaitingSlot(index: slot.index)
            else
              slot
        ];
        _movingMotors.removeWhere((m) => m.cartridge.colorId == selectedColorId);
        _firingMotors.removeWhere((m) => m.cartridge.colorId == selectedColorId);

        final cartridge = LevelData.cartridges.firstWhere(
          (c) => c.colorId == selectedColorId,
          orElse: () => PaintCartridge(id: -1, colorId: selectedColorId, name: 'Bilinmeyen', color: Colors.transparent, amount: 0),
        );
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${cartridge.name} rengi mıknatısla çekildi ve temizlendi!',
              style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF42E88A),
          ),
        );

        final win = _cells.where((cell) => cell.isTarget).every((cell) => cell.isPainted);
        if (win) {
          _handleLevelComplete(DateTime.now());
        }
      });
      _ensureTicker();
    }
  }

  void _handleSlotTap(int slotIndex) {
    final slot = _slots[slotIndex];
    final cartridge = slot.cartridge;
    if (_isGameOver ||
        cartridge == null ||
        cartridge.amount <= 0 ||
        slot.isRunning ||
        _activeOrbitCount >= _orbitPullCount) {
      return;
    }

    setState(() {
      _removeSlotCartridgeAndCompact(slotIndex);
      _firingMotors.add(
        _FiringMotor(
          runId: _nextRunId++,
          slotIndex: slotIndex,
          cartridge: cartridge,
          startedAt: DateTime.now(),
          processedLineKeys: <String>{},
        ),
      );
    });
    _ensureTicker();
  }

  void _handleTick(Duration elapsed) {
    if (!mounted) {
      return;
    }
    if (_isGameOver) {
      if (_ticker.isActive) {
        _ticker.stop();
      }
      return;
    }

    final now = DateTime.now();
    var changed = false;

    _shotEvents.removeWhere(
      (shot) =>
          now.difference(shot.createdAt) > const Duration(milliseconds: 260),
    );

    for (final motor in List<_MovingMotor>.from(_movingMotors)) {
      final index = _movingMotors.indexWhere(
        (item) => item.runId == motor.runId,
      );
      if (index == -1) {
        continue;
      }

      final liveMotor = _movingMotors[index];
      if (now.difference(liveMotor.startedAt) >= _currentLapDuration) {
        if (liveMotor.cartridge.amount > 0 && _shouldKeepLastWeaponMoving()) {
          _movingMotors[index] = liveMotor.copyWith(
            startedAt: now,
            processedLineKeys: <String>{},
          );
        } else {
          final slotIndex = _firstEmptySlotIndex();
          _movingMotors.removeAt(index);
          if (slotIndex != -1 && liveMotor.cartridge.amount > 0) {
            _slots = [
              for (final slot in _slots)
                if (slot.index == slotIndex)
                  slot.fill(liveMotor.cartridge)
                else
                  slot,
            ];
            _burnedColorIds.remove(liveMotor.cartridge.colorId);
          } else if (slotIndex == -1 && liveMotor.cartridge.amount > 0) {
            _triggerGameOver();
          }
        }
        changed = true;
        continue;
      }

      if (liveMotor.cartridge.amount <= 0) {
        _movingMotors.removeAt(index);
        changed = true;
        continue;
      }

      if (!_hasTargetsForColor(liveMotor.cartridge.colorId)) {
        _movingMotors.removeAt(index);
        _clearShotsForColor(liveMotor.cartridge.color);
        changed = true;
        continue;
      }

      final activeMotor = MotorPathEngine.activeMotorAt(
        cartridge: liveMotor.cartridge,
        progress: _progressFor(liveMotor.startedAt, now),
        rows: _gridRows,
        cols: _gridCols,
      );
      changed =
          _processMovingMotorLines(
            liveMotor: liveMotor,
            activeMotor: activeMotor,
          ) ||
          changed;
    }

    for (final motor in List<_FiringMotor>.from(_firingMotors)) {
      final index = _firingMotors.indexWhere(
        (item) => item.runId == motor.runId,
      );
      if (index == -1) {
        continue;
      }

      final liveMotor = _firingMotors[index];
      if (now.difference(liveMotor.startedAt) >= _currentLapDuration) {
        _finishFiringMotor(liveMotor);
        _clearShotsForColor(liveMotor.cartridge.color);
        changed = true;
        continue;
      }

      if (liveMotor.cartridge.amount <= 0) {
        _finishFiringMotor(liveMotor);
        _clearShotsForColor(liveMotor.cartridge.color);
        changed = true;
        continue;
      }

      if (!_hasTargetsForColor(liveMotor.cartridge.colorId)) {
        _finishFiringMotor(
          liveMotor.copyWith(
            cartridge: liveMotor.cartridge.copyWith(amount: 0),
          ),
        );
        _clearShotsForColor(liveMotor.cartridge.color);
        changed = true;
        continue;
      }

      final activeMotor = MotorPathEngine.activeMotorAt(
        cartridge: liveMotor.cartridge,
        progress: _progressFor(liveMotor.startedAt, now),
        rows: _gridRows,
        cols: _gridCols,
      );
      changed =
          _processFiringMotorLines(
            liveMotor: liveMotor,
            activeMotor: activeMotor,
          ) ||
          changed;
    }

    if (_isLevelComplete) {
      _handleLevelComplete(now);
      changed = true;
    }

    if (!_isLevelComplete && !_isGameOver) {
      changed = _syncCartridgeQueueWithTargets() || changed;
    }

    if (_movingMotors.isEmpty &&
        _firingMotors.isEmpty &&
        _completedAt == null &&
        _ticker.isActive) {
      _shotEvents.clear();
      _ticker.stop();
    }

    if (changed ||
        _movingMotors.isNotEmpty ||
        _firingMotors.isNotEmpty ||
        (_completedAt != null && !_showCompletionOverlay)) {
      setState(() {});
    }
  }

  double _progressFor(DateTime startedAt, DateTime now) {
    final elapsed = now.difference(startedAt).inMilliseconds;
    final lap = _currentLapDuration.inMilliseconds;
    return (elapsed % lap) / lap;
  }

  bool _processMovingMotorLines({
    required _MovingMotor liveMotor,
    required ActiveMotor activeMotor,
  }) {
    var changed = false;
    for (final motor in _unprocessedMotorsUpTo(
      cartridge: liveMotor.cartridge,
      activeMotor: activeMotor,
      processedLineKeys: liveMotor.processedLineKeys,
    )) {
      final currentIndex = _movingMotors.indexWhere(
        (item) => item.runId == liveMotor.runId,
      );
      if (currentIndex == -1 ||
          _movingMotors[currentIndex].cartridge.amount <= 0) {
        break;
      }

      final target = MotorPathEngine.findShotTarget(
        motor: motor,
        cells: _cells,
        rows: _gridRows,
        cols: _gridCols,
      );
      if (target == null) {
        changed = true;
        continue;
      }

      _paintCell(target);
      _shotEvents.clear();
      _shotEvents.add(
        MotorPathEngine.createShot(
          motor: motor,
          target: target,
          rows: _gridRows,
          cols: _gridCols,
        ),
      );
      _decreaseMovingMotorAmount(_movingMotors[currentIndex]);
      changed = true;
    }
    return changed;
  }

  bool _processFiringMotorLines({
    required _FiringMotor liveMotor,
    required ActiveMotor activeMotor,
  }) {
    var changed = false;
    for (final motor in _unprocessedMotorsUpTo(
      cartridge: liveMotor.cartridge,
      activeMotor: activeMotor,
      processedLineKeys: liveMotor.processedLineKeys,
    )) {
      final currentIndex = _firingMotors.indexWhere(
        (item) => item.runId == liveMotor.runId,
      );
      if (currentIndex == -1 ||
          _firingMotors[currentIndex].cartridge.amount <= 0) {
        break;
      }

      final target = MotorPathEngine.findShotTarget(
        motor: motor,
        cells: _cells,
        rows: _gridRows,
        cols: _gridCols,
      );
      if (target == null) {
        changed = true;
        continue;
      }

      _paintCell(target);
      _shotEvents.clear();
      _shotEvents.add(
        MotorPathEngine.createShot(
          motor: motor,
          target: target,
          rows: _gridRows,
          cols: _gridCols,
        ),
      );
      _decreaseFiringMotorAmount(_firingMotors[currentIndex]);
      changed = true;
    }
    return changed;
  }

  List<ActiveMotor> _unprocessedMotorsUpTo({
    required PaintCartridge cartridge,
    required ActiveMotor activeMotor,
    required Set<String> processedLineKeys,
  }) {
    final motors = <ActiveMotor>[];
    for (var ordinal = 0; ordinal <= _motorOrdinal(activeMotor); ordinal++) {
      final motor = _motorAtOrdinal(cartridge, ordinal);
      final key = _lineKey(motor);
      if (processedLineKeys.add(key)) {
        motors.add(motor);
      }
    }
    return motors;
  }

  int _motorOrdinal(ActiveMotor motor) {
    return switch (motor.side) {
      MotorSide.bottom => motor.lineIndex,
      MotorSide.right => _gridCols + (_gridRows - 1 - motor.lineIndex),
      MotorSide.top =>
        _gridCols + _gridRows + (_gridCols - 1 - motor.lineIndex),
      MotorSide.left => _gridCols + _gridRows + _gridCols + motor.lineIndex,
    };
  }

  ActiveMotor _motorAtOrdinal(PaintCartridge cartridge, int ordinal) {
    final totalLines = (_gridRows + _gridCols) * 2;
    return MotorPathEngine.activeMotorAt(
      cartridge: cartridge,
      progress: (ordinal + 0.5) / totalLines,
      rows: _gridRows,
      cols: _gridCols,
    );
  }

  Duration get _currentLapDuration =>
      _isLastWeaponPhase ? _lapDuration ~/ 3 : _lapDuration;

  bool _hasEmptySlot() => _slots.any((slot) => !slot.isFilled);

  int _firstEmptySlotIndex() => _slots.indexWhere((slot) => !slot.isFilled);

  int get _remainingWeaponCount {
    var count = 0;
    count += _cartridges.where((cartridge) => cartridge.amount > 0).length;
    count += _slots.where((slot) => (slot.cartridge?.amount ?? 0) > 0).length;
    count += _movingMotors.where((motor) => motor.cartridge.amount > 0).length;
    count += _firingMotors.where((motor) => motor.cartridge.amount > 0).length;
    return count;
  }

  bool get _isLastWeaponPhase => _remainingWeaponCount <= _orbitPullCount;

  bool _shouldKeepLastWeaponMoving() => _isLastWeaponPhase;

  bool _hasTargetsForColor(int colorId) {
    return _cells.any(
      (cell) =>
          cell.targetColorId == colorId && cell.isTarget && !cell.isPainted,
    );
  }

  bool _isCartridgeUseful(int colorId) {
    final targets = _remainingTargetsForColor(colorId);
    if (targets == 0) return false;
    
    final targetColor = LevelData.colorValues[colorId];
    if (targetColor == null) return true;
    
    final shotsInAir = _shotEvents.where((s) => s.color == targetColor).length;
    return targets > shotsInAir;
  }

  int _remainingTargetsForColor(int colorId) {
    return _cells
        .where(
          (cell) =>
              cell.targetColorId == colorId && cell.isTarget && !cell.isPainted,
        )
        .length;
  }

  Set<int> get _backgroundColors {
    final ids = <int>{};
    for (final baseCartridge in LevelData.cartridgesForLevel(_levelIndex)) {
      if (_isBgColor(baseCartridge.colorId)) {
        ids.add(baseCartridge.colorId);
      }
    }
    return ids;
  }

  bool _isBgColor(int colorId) {
    if (_levelIndex == 13) {
      return colorId == 3 || colorId == 5 || colorId == 76;
    }
    if (_levelIndex == 14) {
      return colorId == 101 || colorId == 102;
    }
    if (_levelIndex == 15) {
      return colorId == 103 || colorId == 104;
    }
    if (_levelIndex == 21) {
      return colorId == 21 || colorId == 22 || colorId == 23;
    }
    if (_levelIndex == 23) {
      return colorId == 144 || colorId == 145 || colorId == 146;
    }
    if (_levelIndex == 27) {
      return colorId == 32;
    }
    if (_levelIndex == 33) {
      // Level 34 Yengec backgrounds
      return colorId == 25 || colorId == 20 || colorId == 16;
    }
    if (_levelIndex == 34) {
      // Level 35 Yunus backgrounds
      return colorId == 10 || colorId == 31 || colorId == 30 || colorId == 25 || colorId == 2 || colorId == 22;
    }
    return false;
  }

  List<PaintCartridge> _buildCartridgeQueue() {
    var nextId = 1;

    if (_levelIndex == 15) {
      final levelCartridges = LevelData.cartridgesForLevel(_levelIndex).toList();
      final pools = <int, List<int>>{};
      final baseCartridges = <int, PaintCartridge>{};
      var remainingFortyBudget = _fortyLimitForLevel;
      
      for (final baseCartridge in levelCartridges) {
        final cId = baseCartridge.colorId;
        baseCartridges[cId] = baseCartridge;
        
        final isBg = cId == 103 || cId == 104;
        final deficit = _remainingTargetsForColor(cId);
        
        final batches = _balancedBatchAmountsForDeficit(
          deficit,
          fortyBudget: remainingFortyBudget,
          colorId: cId,
          isBackground: isBg,
        );
        pools[cId] = List<int>.from(batches);
        remainingFortyBudget -= batches.where((amount) => amount == 40).length;
      }
      
      final queue = <PaintCartridge>[];
      int row = 0;
      int col = 0;
      
      bool hasRemaining() {
        return pools.values.any((list) => list.isNotEmpty);
      }
      
      int getExpectedColorId(int r, int c) {
        final cycle = r % 6;
        if (cycle == 0) {
          if (c == 0) return 103;
          if (c == 1) return 104;
          return 11;
        } else if (cycle == 1) {
          if (c == 0) return 93;
          if (c == 1) return 103;
          return 97;
        } else if (cycle == 2) {
          if (c == 0) return 103;
          if (c == 1) return 42;
          return 97;
        } else if (cycle == 3) {
          if (c == 0) return 93;
          if (c == 1) return 103;
          if (r == 3) return 100; // Siyah only in row 4
          return 11;
        } else if (cycle == 4) {
          if (c == 0) return 103;
          if (c == 1) return 104;
          return 47;
        } else { // cycle == 5
          if (c == 0) return 42;
          if (c == 1) return 103;
          return 97;
        }
      }
      
      while (hasRemaining()) {
        final targetColorId = getExpectedColorId(row, col);
        final pool = pools[targetColorId];
        if (pool != null && pool.isNotEmpty) {
          final amount = pool.removeAt(0);
          final base = baseCartridges[targetColorId]!;
          queue.add(PaintCartridge(
            id: nextId++,
            colorId: targetColorId,
            name: base.name,
            color: base.color,
            amount: amount,
          ));
        }
        
        col++;
        if (col == 3) {
          col = 0;
          row++;
        }
      }
      
      _generatedFortyCount = queue
          .where((cartridge) => cartridge.amount == 40)
          .length;
      return queue;
    }

    final batchesByColor = <PaintCartridge, List<int>>{};
    
    final levelCartridges = LevelData.cartridgesForLevel(_levelIndex).toList();
    
    int backgroundId = -1;
    int maxTargets = -1;
    final sumRowByColor = <int, int>{};
    final countByColor = <int, int>{};

    for (final baseCartridge in levelCartridges) {
      final t = _remainingTargetsForColor(baseCartridge.colorId);
      if (t > maxTargets) {
        maxTargets = t;
        backgroundId = baseCartridge.colorId;
      }
    }

    for (final cell in _cells) {
      if (cell.isTarget) {
        sumRowByColor[cell.targetColorId] = (sumRowByColor[cell.targetColorId] ?? 0) + cell.row;
        countByColor[cell.targetColorId] = (countByColor[cell.targetColorId] ?? 0) + 1;
      }
    }

    final initialPizzaCartridges = <PaintCartridge>[];
    if (_levelIndex == 15) {
      final initialColorIds = [
        103, 104, 11,  // Group 1
        93, 103, 104,  // Group 2
        103, 104, 97,  // Group 3
      ];
      for (int colorId in initialColorIds) {
        final baseCartridge = levelCartridges.firstWhere(
          (c) => c.colorId == colorId,
          orElse: () => levelCartridges.first,
        );
        initialPizzaCartridges.add(PaintCartridge(
          id: nextId++,
          colorId: colorId,
          name: baseCartridge.name,
          color: baseCartridge.color,
          amount: 40,
        ));
      }
    }

    levelCartridges.sort((a, b) {
      final countA = countByColor[a.colorId] ?? 1;
      final avgA = (sumRowByColor[a.colorId] ?? 0) / countA;
      
      final countB = countByColor[b.colorId] ?? 1;
      final avgB = (sumRowByColor[b.colorId] ?? 0) / countB;
      
      return avgB.compareTo(avgA);
    });
    
    var remainingFortyBudget = _fortyLimitForLevel;

    for (final baseCartridge in levelCartridges) {
      final isBg = _isBgColor(baseCartridge.colorId);
      
      int deficit = _remainingTargetsForColor(baseCartridge.colorId);
      if (_levelIndex == 15) {
        final initialPizzaCounts = const <int, int>{
          103: 120, // 3 * 40
          104: 120, // 3 * 40
          11: 40,   // 1 * 40
          93: 40,   // 1 * 40
          97: 40,   // 1 * 40
        };
        deficit -= initialPizzaCounts[baseCartridge.colorId] ?? 0;
      }

      final batches = _balancedBatchAmountsForDeficit(
          deficit,
          fortyBudget: remainingFortyBudget,
          colorId: baseCartridge.colorId,
          isBackground: isBg,
        );
      batchesByColor[baseCartridge] = batches;
      remainingFortyBudget -= batches.where((amount) => amount == 40).length;
    }

    final averageRowByColor = <int, double>{};
    for (final colorId in sumRowByColor.keys) {
      averageRowByColor[colorId] = sumRowByColor[colorId]! / countByColor[colorId]!;
    }

    final averageDistByColor = <int, double>{};
    if (_levelIndex == 29 || _levelIndex == 30) {
      final S = LevelData.levelAt(_levelIndex).gridRows;
      final sumDistByColor = <int, double>{};
      final countByColorDist = <int, int>{};
      for (final cell in _cells) {
        if (cell.isTarget) {
          final dist = math.min(math.min(cell.row, S - 1 - cell.row), math.min(cell.col, S - 1 - cell.col)).toDouble();
          sumDistByColor[cell.targetColorId] = (sumDistByColor[cell.targetColorId] ?? 0.0) + dist;
          countByColorDist[cell.targetColorId] = (countByColorDist[cell.targetColorId] ?? 0) + 1;
        }
      }
      for (final colorId in sumDistByColor.keys) {
        averageDistByColor[colorId] = sumDistByColor[colorId]! / countByColorDist[colorId]!;
      }
    }

    final queue = <PaintCartridge>[];

    final cartridgeProgress = <PaintCartridge, double>{};
    for (final baseCartridge in levelCartridges) {
      final batches = batchesByColor[baseCartridge] ?? const <int>[];
      final n = batches.length;
      if (n == 0) continue;
      final cId = baseCartridge.colorId;
      final isBg = _isBgColor(cId);
      final isEarly = cId == 11 || cId == 4 || cId == 32 || cId == 12;
      final isLate = (cId == 8 || cId == 24 || cId == 22 || cId == 43 || cId == 44 || cId == 14 || cId == 47 || cId == 3 || cId == 9) && !(_levelIndex == 13 && isBg);
      final isNormal = cId == 37 || cId == 46;
      
      for (int i = 0; i < n; i++) {
        double progress = (i + 0.5) / n;
        
        if (_levelIndex == 31 && cId == 1) {
          progress = 0.85 + (progress * 0.15);
        } else if (_levelIndex == 31 && cId == 12) {
          progress = progress * 0.65;
        } else if (_levelIndex == 29 || _levelIndex == 30) {
          final avgDist = averageDistByColor[cId] ?? 0.0;
          final normDist = math.min(1.0, math.max(0.0, avgDist / 24.0));
          progress = (normDist * 0.5) + ((i + 0.5) / n) * 0.5;
        } else if (_levelIndex == 26) {
          final isLateColor = cId == 14 || cId == 34 || cId == 4 || cId == 13 || cId == 6 || cId == 1 || cId == 36 || cId == 28;
          final isMiddleColor = cId == 25 || cId == 21 || cId == 15;
          if (isLateColor) {
            progress = 0.75 + (progress * 0.25);
          } else if (isMiddleColor) {
            progress = 0.4 + (progress * 0.3);
          } else if (cId == 16) {
            // Let the edge blue (color 16) be spread out across the entire level timeline (0.0 to 1.0)
            progress = progress;
          } else {
            progress = progress * 0.4;
          }
        } else if (_levelIndex == 27) {
          // Keep progress exactly as is (0.0 to 1.0) so colors interleave/mix naturally
          progress = progress;
        } else if ((_levelIndex == 13 || _levelIndex == 14 || _levelIndex == 15) && isBg) {
          progress = progress * 0.8;
        } else if (_levelIndex == 21 && isBg) {
          progress = progress * 0.6;
        } else if (_levelIndex == 23 && isBg) {
          progress = progress * 0.2;
        } else if ((_levelIndex == 14 || _levelIndex == 15) && !isBg) {
          progress = 0.15 + (progress * 0.85);
        } else if (_levelIndex == 21 && !isBg) {
          progress = 0.08 + (progress * 0.92);
        } else if (_levelIndex == 23 && !isBg) {
          progress = 0.35 + (progress * 0.65);
        } else if (_levelIndex == 13 && cId != 11) {
          progress = 0.15 + (progress * 0.85);
        } else if (isEarly) {
          progress = progress * 0.45; // 0.0 to 0.45
        } else if (isLate) {
          progress = 0.45 + (progress * 0.55); // 0.45 to 1.0
        } else if (isNormal) {
          progress = 0.1 + (progress * 0.8); // 0.1 to 0.9
        }
        
        // Small tie-breaker based on vertical position
        final avgRow = averageRowByColor[baseCartridge.colorId] ?? 0.0;
        progress -= (avgRow / 50.0) * 0.05; 
        
        progress += (baseCartridge.colorId * 0.000001);
        
        final c = PaintCartridge(
          id: nextId++,
          colorId: baseCartridge.colorId,
          name: baseCartridge.name,
          color: baseCartridge.color,
          amount: batches[i],
        );
        queue.add(c);
        cartridgeProgress[c] = progress;
      }
    }
    queue.sort((a, b) => cartridgeProgress[a]!.compareTo(cartridgeProgress[b]!));

    if (_levelIndex == 26) {
      final List<PaintCartridge> selectedMavis = [];
      final List<PaintCartridge> selectedKrems = [];
      final List<PaintCartridge> selectedPembes = [];
      final List<PaintCartridge> selectedKahves = [];
      final List<PaintCartridge> selectedGris = [];
      final List<PaintCartridge> selectedSiyahs = [];

      for (final cartridge in queue) {
        if (cartridge.colorId == 16 && selectedMavis.length < 6) {
          selectedMavis.add(cartridge);
        } else if (cartridge.colorId == 31 && selectedKrems.length < 2) {
          selectedKrems.add(cartridge);
        } else if (cartridge.colorId == 34 && selectedPembes.length < 3) {
          selectedPembes.add(cartridge);
        } else if (cartridge.colorId == 14 && selectedKahves.length < 2) {
          selectedKahves.add(cartridge);
        } else if (cartridge.colorId == 15 && selectedGris.length < 1) {
          selectedGris.add(cartridge);
        } else if ((cartridge.colorId == 12 || cartridge.colorId == 36 || cartridge.colorId == 28) && selectedSiyahs.length < 1) {
          selectedSiyahs.add(cartridge);
        }
      }

      if (selectedMavis.length == 6 &&
          selectedKrems.length == 2 &&
          selectedPembes.length == 3 &&
          selectedKahves.length == 2 &&
          selectedGris.length == 1 &&
          selectedSiyahs.length == 1) {
        
        final selectedSet = <PaintCartridge>{
          ...selectedMavis,
          ...selectedKrems,
          ...selectedPembes,
          ...selectedKahves,
          ...selectedGris,
          ...selectedSiyahs,
        };
        queue.removeWhere((c) => selectedSet.contains(c));

        final prefix = <PaintCartridge>[
          // Row 1: mavi, krem, mavi
          selectedMavis[0],
          selectedKrems[0],
          selectedMavis[1],
          // Row 2: pembe, kahverengi, gri
          selectedPembes[0],
          selectedKahves[0],
          selectedGris[0],
          // Row 3: mavi, kahverengi, mavi
          selectedMavis[2],
          selectedKahves[1],
          selectedMavis[3],
          // Row 4: pembe, siyah, pembe
          selectedPembes[1],
          selectedSiyahs[0],
          selectedPembes[2],
          // Row 5: mavi, krem, mavi
          selectedMavis[4],
          selectedKrems[1],
          selectedMavis[5],
        ];

        queue.insertAll(0, prefix);
      }
    }

    if (_levelIndex == 23) {
      final purples = queue.where((c) => c.colorId == 144 || c.colorId == 145 || c.colorId == 146).toList();
      final others = queue.where((c) => !(c.colorId == 144 || c.colorId == 145 || c.colorId == 146)).toList();

      final interleaved = <PaintCartridge>[];
      int pIdx = 0;
      int oIdx = 0;
      int groupIndex = 0;

      while (pIdx < purples.length || oIdx < others.length) {
        int purplesLeft = purples.length - pIdx;
        int othersLeft = others.length - oIdx;
        int purplesToAdd = 0;
        int othersToAdd = 0;

        if (purplesLeft >= 2 && othersLeft >= 1) {
          purplesToAdd = 2;
          othersToAdd = 1;
        } else if (purplesLeft == 1 && othersLeft >= 2) {
          purplesToAdd = 1;
          othersToAdd = 2;
        } else {
          purplesToAdd = purplesLeft;
          othersToAdd = othersLeft;
        }

        if (purplesToAdd == 2 && othersToAdd == 1) {
          final p1 = purples[pIdx++];
          final p2 = purples[pIdx++];
          final o1 = others[oIdx++];
          
          final pos = groupIndex % 3;
          if (pos == 0) {
            interleaved.addAll([p1, o1, p2]);
          } else if (pos == 1) {
            interleaved.addAll([p1, p2, o1]);
          } else {
            interleaved.addAll([o1, p1, p2]);
          }
          groupIndex++;
        } else if (purplesToAdd == 1 && othersToAdd == 2) {
          final p1 = purples[pIdx++];
          final o1 = others[oIdx++];
          final o2 = others[oIdx++];
          
          final pos = groupIndex % 3;
          if (pos == 0) {
            interleaved.addAll([p1, o1, o2]);
          } else if (pos == 1) {
            interleaved.addAll([o1, p1, o2]);
          } else {
            interleaved.addAll([o1, o2, p1]);
          }
          groupIndex++;
        } else {
          for (int i = 0; i < purplesToAdd; i++) {
            if (pIdx < purples.length) interleaved.add(purples[pIdx++]);
          }
          for (int i = 0; i < othersToAdd; i++) {
            if (oIdx < others.length) interleaved.add(others[oIdx++]);
          }
        }
      }
      queue.clear();
      queue.addAll(interleaved);
    }

    if (_levelIndex >= 32) {
      final colorGroups = <int, List<PaintCartridge>>{};
      for (final c in queue) {
        colorGroups.putIfAbsent(c.colorId, () => []).add(c);
      }
      
      final rand = _levelIndex == 33 ? math.Random(level34Seed) : math.Random();
      for (final group in colorGroups.values) {
        group.shuffle(rand);
      }
      
      final interleaved = <PaintCartridge>[];
      int? lastColorId;
      int? secondLastColorId;
      int? thirdLastColorId;
      int? lastAmount;
      
      while (colorGroups.values.any((list) => list.isNotEmpty)) {
        int bestColorId = -1;
        double bestScore = -double.infinity;
        
        for (final entry in colorGroups.entries) {
          final colorId = entry.key;
          final list = entry.value;
          if (list.isEmpty) continue;
          
          final nextCartridge = list.first;
          double score = list.length.toDouble();
          
          if (colorId == lastColorId) {
            score -= 100.0;
          } else if (colorId == secondLastColorId) {
            score -= 50.0;
          } else if (colorId == thirdLastColorId) {
            score -= 30.0;
          }
          
          if (nextCartridge.amount == lastAmount) {
            score -= 5.0;
          }
          
          score += rand.nextDouble() * 2.0;
          
          if (score > bestScore) {
            bestScore = score;
            bestColorId = colorId;
          }
        }
        
        if (bestColorId == -1) {
          bestColorId = colorGroups.entries.firstWhere((e) => e.value.isNotEmpty).key;
        }
        
        final selectedCartridge = colorGroups[bestColorId]!.removeAt(0);
        interleaved.add(selectedCartridge);
        
        thirdLastColorId = secondLastColorId;
        secondLastColorId = lastColorId;
        lastColorId = selectedCartridge.colorId;
        lastAmount = selectedCartridge.amount;
      }
      
      queue.clear();
      queue.addAll(interleaved);
    }

    if (_levelIndex == 33) {
      final selectedPembes = queue.where((c) => c.colorId == 30).toList();
      final selectedKrems = queue.where((c) => c.colorId == 42).toList();
      final others = queue.where((c) => c.colorId != 30 && c.colorId != 42).toList();

      if (selectedPembes.isNotEmpty && selectedKrems.isNotEmpty && others.length >= 7) {
        final prefixPink = selectedPembes.first;
        final prefixCream = selectedKrems.first;

        // Remove these prefix elements from the main queue
        queue.remove(prefixCream);
        queue.remove(prefixPink);

        // Get the first 7 other cartridges from the remaining queue
        // We prioritize blue, teal, white, indigo: {25, 20, 23, 11, 16}
        final prefixOthers = <PaintCartridge>[];
        final tempOthers = queue.where((c) => c.colorId != 30 && c.colorId != 42).toList();
        
        final priorityColors = {25, 20, 23, 11, 16};
        tempOthers.sort((a, b) {
          final aVal = priorityColors.contains(a.colorId) ? 0 : 1;
          final bVal = priorityColors.contains(b.colorId) ? 0 : 1;
          return aVal.compareTo(bVal);
        });

        int lastColorId = -1;
        for (int i = 0; i < 7; i++) {
          if (tempOthers.isEmpty) break;
          final choice = tempOthers.firstWhere(
            (c) => c.colorId != lastColorId,
            orElse: () => tempOthers.first,
          );
          prefixOthers.add(choice);
          lastColorId = choice.colorId;
          tempOthers.remove(choice);
          queue.remove(choice);
        }

        // Apply 40-round enforcement for background colors in prefixOthers
        for (int i = 0; i < prefixOthers.length; i++) {
          final c = prefixOthers[i];
          final isBgColor = c.colorId == 25 || c.colorId == 20 || c.colorId == 16;
          if (isBgColor && c.amount != 40) {
            final fortyCart = queue.firstWhere(
              (x) => x.colorId == c.colorId && x.amount == 40,
              orElse: () => c,
            );
            if (fortyCart != c) {
              prefixOthers[i] = fortyCart;
              queue.remove(fortyCart);
              queue.add(c);
            }
          }
        }

        // Place them in slots 0 to 8:
        final prefix = <PaintCartridge>[
          prefixOthers[0],
          prefixOthers[1],
          prefixCream,
          prefixOthers[2],
          prefixOthers[3],
          prefixPink,
          prefixOthers[4],
          prefixOthers[5],
          prefixOthers[6],
        ];

        queue.insertAll(0, prefix);

        // Fix any consecutive same-color cartridges in the queue (from index 8 onwards)
        for (int i = 8; i < queue.length - 1; i++) {
          if (queue[i].colorId == queue[i + 1].colorId) {
            int swapIndex = -1;
            for (int j = i + 2; j < queue.length; j++) {
              final differentFromCurrent = queue[j].colorId != queue[i].colorId;
              final differentFromNext = (i + 2 < queue.length)
                  ? queue[j].colorId != queue[i + 2].colorId
                  : true;
              if (differentFromCurrent && differentFromNext) {
                swapIndex = j;
                break;
              }
            }
            if (swapIndex != -1) {
              final temp = queue[i + 1];
              queue[i + 1] = queue[swapIndex];
              queue[swapIndex] = temp;
            }
          }
        }
      }
    }

    if (_levelIndex == 15) {
      queue.insertAll(0, initialPizzaCartridges);
    }

    // Ensure we have at least 6 cartridges by splitting larger ones
    while (queue.length < 6) {
      int splitIndex = queue.indexWhere((c) => c.amount > 10 && c.amount != 15);
      if (splitIndex == -1) break;
      
      final target = queue[splitIndex];
      List<int> parts = [];
      if (target.amount == 40) {
        parts = [20, 20];
      } else if (target.amount == 30) {
        parts = [15, 15];
      } else if (target.amount == 20) {
        parts = [10, 10];
      }
      
      queue.removeAt(splitIndex);
      for (int part in parts) {
        queue.insert(
          splitIndex,
          PaintCartridge(
            id: nextId++,
            colorId: target.colorId,
            name: target.name,
            color: target.color,
            amount: part,
          ),
        );
      }
    }

    if (_levelIndex < 32) {
      for (int i = (_levelIndex == 15 ? 9 : (_levelIndex == 26 ? 15 : 0)); i < queue.length - 3; i++) {
        if (queue[i].colorId == queue[i + 3].colorId) {
          if (i + 4 < queue.length && queue[i].colorId != queue[i + 4].colorId && queue[i + 3].colorId != queue[i + 4].colorId) {
            final temp = queue[i + 3];
            queue[i + 3] = queue[i + 4];
            queue[i + 4] = temp;
          } else if (queue[i].colorId != queue[i + 2].colorId && queue[i + 3].colorId != queue[i + 2].colorId) {
            final temp = queue[i + 3];
            queue[i + 3] = queue[i + 2];
            queue[i + 2] = temp;
          }
        }
      }
    }

    if (_levelIndex == 33) {
      print('=== DEBUG LEVEL 34 QUEUE GENERATION ===');
      print('Before swaps:');
      print('3. (index 2): ${queue[2].colorId} (${queue[2].amount})');
      print('35. (index 34): ${queue[34].colorId} (${queue[34].amount})');
      print('13. (index 12): ${queue[12].colorId} (${queue[12].amount})');
      print('15. (index 14): ${queue[14].colorId} (${queue[14].amount})');
      print('18. (index 17): ${queue[17].colorId} (${queue[17].amount})');
      print('19. (index 18): ${queue[18].colorId} (${queue[18].amount})');
      print('23. (index 22): ${queue[22].colorId} (${queue[22].amount})');
      print('56. (index 55): ${queue[55].colorId} (${queue[55].amount})');
      print('58. (index 57): ${queue[57].colorId} (${queue[57].amount})');
      print('61. (index 60): ${queue[60].colorId} (${queue[60].amount})');
      print('68. (index 67): ${queue[67].colorId} (${queue[67].amount})');
      print('72. (index 71): ${queue[71].colorId} (${queue[71].amount})');

      void swap(int idxA, int idxB) {
        if (idxA >= 0 && idxA < queue.length && idxB >= 0 && idxB < queue.length) {
          final temp = queue[idxA];
          queue[idxA] = queue[idxB];
          queue[idxB] = temp;
        }
      }
      
      // User requested swaps (1-indexed converted to 0-indexed):
      // 1. 35. sıradaki maviyi 3. sırayla yer değiştir.
      swap(34, 2);
      // 2. 58. sıradaki maviyle 15. sıradaki rengi yer değiştir.
      swap(57, 14);
      // 3. 56. sıradaki rengi 13. sıradaki renkle yer değiştir.
      swap(55, 12);
      // 4. 68. sıradaki rengi 18. sıra ile yer değiştir.
      swap(67, 17);
      // 5. 23. sıra ile 72 sıra yer değiştir.
      swap(22, 71);
      // 6. 19. sıra ile 61. sıra yer değiştir.
      swap(18, 60);

      print('After swaps (before duplicate resolver):');
      print('3. (index 2): ${queue[2].colorId} (${queue[2].amount})');
      print('35. (index 34): ${queue[34].colorId} (${queue[34].amount})');
      print('13. (index 12): ${queue[12].colorId} (${queue[12].amount})');
      print('15. (index 14): ${queue[14].colorId} (${queue[14].amount})');
      print('18. (index 17): ${queue[17].colorId} (${queue[17].amount})');
      print('19. (index 18): ${queue[18].colorId} (${queue[18].amount})');
      print('23. (index 22): ${queue[22].colorId} (${queue[22].amount})');
      print('56. (index 55): ${queue[55].colorId} (${queue[55].amount})');
      print('58. (index 57): ${queue[57].colorId} (${queue[57].amount})');
      print('61. (index 60): ${queue[60].colorId} (${queue[60].amount})');
      print('68. (index 67): ${queue[67].colorId} (${queue[67].amount})');
      print('72. (index 71): ${queue[71].colorId} (${queue[71].amount})');


      // Resolve any consecutive same-color duplicates in the queue caused by swaps:
      final targetIndices = {2, 12, 14, 17, 18, 22, 34, 55, 57, 60, 67, 71};
      for (int i = 0; i < queue.length - 1; i++) {
        if (queue[i].colorId == queue[i + 1].colorId) {
          int idxToSwap = i + 1;
          if (targetIndices.contains(i + 1) && !targetIndices.contains(i)) {
            idxToSwap = i;
          }

          int swapIdx = -1;
          for (int j = 0; j < queue.length; j++) {
            if (targetIndices.contains(j)) continue;
            if (j == i || j == i + 1) continue;

            final proposedColorId = queue[j].colorId;
            final otherIdx = (idxToSwap == i) ? i + 1 : i;
            if (proposedColorId == queue[otherIdx].colorId) continue;

            if (j > 0 && queue[j - 1].colorId == queue[idxToSwap].colorId) continue;
            if (j < queue.length - 1 && queue[j + 1].colorId == queue[idxToSwap].colorId) continue;

            if (idxToSwap > 0 && idxToSwap - 1 != j && queue[idxToSwap - 1].colorId == proposedColorId) continue;
            if (idxToSwap < queue.length - 1 && idxToSwap + 1 != j && queue[idxToSwap + 1].colorId == proposedColorId) continue;

            swapIdx = j;
            break;
          }

          if (swapIdx != -1) {
            final temp = queue[idxToSwap];
            queue[idxToSwap] = queue[swapIdx];
            queue[swapIdx] = temp;
          }
        }
      }

      print('After duplicate resolver (final):');
      print('3. (index 2): ${queue[2].colorId} (${queue[2].amount})');
      print('35. (index 34): ${queue[34].colorId} (${queue[34].amount})');
      print('13. (index 12): ${queue[12].colorId} (${queue[12].amount})');
      print('15. (index 14): ${queue[14].colorId} (${queue[14].amount})');
      print('18. (index 17): ${queue[17].colorId} (${queue[17].amount})');
      print('19. (index 18): ${queue[18].colorId} (${queue[18].amount})');
      print('23. (index 22): ${queue[22].colorId} (${queue[22].amount})');
      print('56. (index 55): ${queue[55].colorId} (${queue[55].amount})');
      print('58. (index 57): ${queue[57].colorId} (${queue[57].amount})');
      print('61. (index 60): ${queue[60].colorId} (${queue[60].amount})');
      print('68. (index 67): ${queue[67].colorId} (${queue[67].amount})');
      print('72. (index 71): ${queue[71].colorId} (${queue[71].amount})');
    }


    _generatedFortyCount = queue
        .where((cartridge) => cartridge.amount == 40)
        .length;

    return queue;
  }

  bool _syncCartridgeQueueWithTargets() {
    final targetsByColor = _remainingTargetsByColor();
    final inventoryByColor = _bulletInventoryByColor();
    var changed = false;
    final additions = <_CartridgeRequest>[];
    var remainingFortyBudget = math.max(
      0,
      _fortyLimitForLevel - _generatedFortyCount,
    );
    for (final baseCartridge in LevelData.cartridgesForLevel(_levelIndex)) {
      final colorId = baseCartridge.colorId;
      var deficit =
          (targetsByColor[colorId] ?? 0) - (inventoryByColor[colorId] ?? 0);
      final batches = _balancedBatchAmountsForDeficit(
          deficit,
          fortyBudget: remainingFortyBudget,
          colorId: colorId,
          isBackground: _isBgColor(colorId),
        );
      remainingFortyBudget -= batches.where((amount) => amount == 40).length;
      for (final amount in batches) {
        additions.add(
          _CartridgeRequest(baseCartridge: baseCartridge, amount: amount),
        );
      }
    }

    if (additions.isNotEmpty) {
      var nextId = _nextCartridgeId();
      _cartridges = [
        ..._cartridges,
        for (final addition in additions)
          PaintCartridge(
            id: nextId++,
            colorId: addition.baseCartridge.colorId,
            name: addition.baseCartridge.name,
            color: addition.baseCartridge.color,
            amount: addition.amount,
          ),
      ];
      _generatedFortyCount += additions
          .where((addition) => addition.amount == 40)
          .length;
      changed = true;
    }

    return changed;
  }

  Map<int, int> _remainingTargetsByColor() {
    final counts = <int, int>{};
    for (final cell in _cells) {
      if (!cell.isTarget || cell.isPainted) {
        continue;
      }
      counts.update(
        cell.targetColorId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    return counts;
  }

  Map<int, int> _bulletInventoryByColor() {
    final counts = <int, int>{};

    void add(PaintCartridge? cartridge) {
      if (cartridge == null || cartridge.amount <= 0) {
        return;
      }
      counts.update(
        cartridge.colorId,
        (count) => count + cartridge.amount,
        ifAbsent: () => cartridge.amount,
      );
    }

    for (final cartridge in _cartridges) {
      add(cartridge);
    }
    for (final slot in _slots) {
      add(slot.cartridge);
    }
    for (final motor in _movingMotors) {
      add(motor.cartridge);
    }
    for (final motor in _firingMotors) {
      add(motor.cartridge);
    }

    return counts;
  }

  int get _fortyLimitForLevel {
    if (_levelIndex < 5) {
      return 5;
    }
    if (_levelIndex < 10) {
      return 7;
    }
    if (_levelIndex < 15) {
      return 8;
    }
    if (_levelIndex < 25) {
      return math.max(1, _targetCount ~/ 80);
    }
    final categoryPosition = _levelIndex % 25;
    if (categoryPosition < 5) {
      return 5;
    }
    if (categoryPosition < 10) {
      return 7;
    }
    if (categoryPosition < 15) {
      return 8;
    }
    return math.max(8, _targetCount ~/ 100);
  }

  List<int> _balancedBatchAmountsForDeficit(
    int deficit, {
    required int fortyBudget,
    required int colorId,
    bool isBackground = false,
  }) {
    if (_levelIndex == 24) {
      if (deficit <= 0) return const [];
      final List<int> list;
      switch (colorId) {
        case 12:
          list = [20, 20, 15, 15, 10, 10, 10, 10];
          break;
        case 131:
          list = [20, 20, 20, 20, 15, 15, 15, 15, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
          break;
        case 132:
          list = [20, 20, 20, 20, 15, 15, 15, 15, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
          break;
        case 133:
          list = [20, 20, 15, 15, 10, 10, 10, 10];
          break;
        case 134:
          list = [20, 20, 15, 15, 10, 10, 10, 10, 10];
          break;
        case 76:
          list = [10, 10];
          break;
        default:
          list = List.filled(deficit ~/ 10, 10);
      }
      list.shuffle();
      return list;
    }
    if (_levelIndex == 21 && !isBackground) {
      if (deficit <= 0) return const [];
      int count = (deficit + 9) ~/ 10;
      return List.filled(count, 10);
    }
    if (_levelIndex == 22) {
      if (deficit <= 0) return const [];
      if (colorId == 12) {
        // Siyah outline (colorId 12) gets only 10s to ensure at least 30 10-round cartridges
        return List.filled(deficit ~/ 10, 10);
      }
      final result = <int>[];
      int remaining = deficit;
      while (remaining >= 20) {
        result.add(20);
        remaining -= 20;
      }
      if (remaining >= 10) {
        result.add(10);
      }
      return result;
    }
    if (_levelIndex == 23) {
      if (deficit <= 0) return const [];
      if (isBackground) {
        final list = List<int>.filled(deficit ~/ 40, 40, growable: true);
        final rem = deficit % 40;
        if (rem > 0) {
          list.add(rem);
        }
        return list;
      } else {
        // Optimised globally to achieve exactly 40% 10-rounders, 30% 20-rounders, 30% 30-rounders
        switch (colorId) {
          case 12:  // deficit 530
            return [30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20];
          case 147: // deficit 80
            return [20, 20, 20, 20];
          case 150: // deficit 50
            return [20, 10, 10, 10];
          case 148: // deficit 200
            return [30, 30, 30, 30, 30, 10, 10, 10, 10, 10];
          case 149: // deficit 100
            return [30, 20, 20, 10, 10, 10];
          case 151: // deficit 150
            return [30, 30, 30, 10, 10, 10, 10, 10, 10];
          case 154: // deficit 20
            return [20];
          case 155: // deficit 20
            return [10, 10];
          case 142: // deficit 50
            return [10, 10, 10, 10, 10];
          case 139: // deficit 60
            return [30, 20, 10];
          case 153: // deficit 20
            return [10, 10];
          case 152: // deficit 20
            return [20];
          default:
            final result = <int>[];
            int remaining = deficit;
            final sizes = [30, 20, 10];
            int sizeIdx = 0;
            while (remaining > 0) {
              int size = sizes[sizeIdx % 3];
              if (remaining >= size) {
                result.add(size);
                remaining -= size;
                sizeIdx++;
              } else if (remaining < 10) {
                result.add(remaining);
                remaining = 0;
              } else {
                sizeIdx++;
              }
            }
            return result;
        }
      }
    }
    if (_levelIndex == 26) {
      if (deficit <= 0) return const [];
      if (colorId == 16) {
        return CartridgeBatchPlanner.plan(
          deficit: deficit,
          fortyBudget: fortyBudget,
          allowLarge: true,
          forceFirstThreeAsTen: false,
        );
      }
    }
    if (_levelIndex == 27) {
      if (deficit <= 0) return const [];
      if (colorId == 32) {
        // Whichever color has the most pixels (32), make it 30-round cartridges.
        return List.filled(deficit ~/ 30, 30);
      } else {
        // Make the others 10-15-20 (no 40s or 30s)
        return CartridgeBatchPlanner.plan(
          deficit: deficit,
          fortyBudget: 0,
          allowLarge: false,
          forceFirstThreeAsTen: colorId != 11,
        );
      }
    }
    if (_levelIndex == 29) {
      if (deficit <= 0) return const [];
      final rand = math.Random();
      while (true) {
        final result = <int>[];
        int remaining = deficit;
        while (remaining > 0) {
          if (remaining == 5) {
            break; // Failed to partition exactly with {10,15,20}, retry
          }
          final options = <int>[];
          if (remaining >= 10) options.add(10);
          if (remaining >= 15) options.add(15);
          if (remaining >= 20) options.add(20);
          
          if (options.isEmpty) {
            result.add(remaining);
            remaining = 0;
            break;
          }
          
          int choice = 10;
          final roll = rand.nextDouble();
          if (options.contains(15) && options.contains(20)) {
            if (roll < 0.45) {
              choice = 10;
            } else if (roll < 0.90) {
              choice = 15;
            } else {
              choice = 20;
            }
          } else if (options.contains(15)) {
            if (roll < 0.5) {
              choice = 10;
            } else {
              choice = 15;
            }
          } else {
            choice = 10;
          }
          
          result.add(choice);
          remaining -= choice;
        }
        if (remaining == 0) {
          result.shuffle(rand);
          return result;
        }
      }
    }
    if (_levelIndex == 30) {
      if (deficit <= 0) return const [];
      final rand = math.Random();
      while (true) {
        final result = <int>[];
        int remaining = deficit;
        while (remaining > 0) {
          if (remaining == 5) {
            break; // Failed to partition, retry
          }
          if (remaining == 15) {
            result.add(15);
            remaining = 0;
            break;
          }
          if (remaining == 25) {
            result.add(25);
            remaining = 0;
            break;
          }
          if (remaining == 10) {
            result.add(10);
            remaining = 0;
            break;
          }
          final options = <int>[];
          if (remaining >= 20) options.add(20);
          if (remaining >= 30) options.add(30);
          
          if (options.isEmpty) {
            result.add(remaining);
            remaining = 0;
            break;
          }
          
          int choice = 20;
          final roll = rand.nextDouble();
          if (options.contains(20) && options.contains(30)) {
            choice = roll < 0.5 ? 20 : 30;
          } else if (options.contains(20)) {
            choice = 20;
          } else {
            choice = 30;
          }
          
          result.add(choice);
          remaining -= choice;
        }
        if (remaining == 0) {
          result.shuffle(rand);
          return result;
        }
      }
    }
    if (_levelIndex == 31) {
      if (deficit <= 0) return const [];
      if (colorId == 1) {
        return const [15, 40];
      }
      if (colorId == 12) {
        final rand = math.Random();
        while (true) {
          final result = <int>[];
          int remaining = deficit;
          while (remaining > 0) {
            final options = <int>[];
            if (remaining >= 20) options.add(20);
            if (remaining >= 30) options.add(30);
            if (options.isEmpty) {
              result.add(remaining);
              remaining = 0;
              break;
            }
            final choice = rand.nextDouble() < 0.6 ? 20 : 30;
            result.add(choice);
            remaining -= choice;
          }
          if (remaining == 0) {
            result.shuffle(rand);
            return result;
          }
        }
      }
    }
    if (_levelIndex >= 32) {
      if (deficit <= 0) return const [];

      // If it is a background color, partition it safely maximizing 40s
      if (isBackground) {
        int target = deficit;
        if (target < 10) target = 10;
        if (target % 5 != 0) target = ((target + 4) ~/ 5) * 5;

        final list = <int>[];
        int k = target ~/ 40;
        int rem = target % 40;

        if (rem == 0) {
          list.addAll(List<int>.filled(k, 40));
        } else if (rem == 10 || rem == 15 || rem == 20 || rem == 30) {
          list.addAll(List<int>.filled(k, 40));
          list.add(rem);
        } else if (rem == 5) {
          if (k > 0) {
            list.addAll(List<int>.filled(k - 1, 40));
            list.add(30);
            list.add(15);
          } else {
            list.add(10); // fallback if k == 0 (should not happen since target >= 10)
          }
        } else if (rem == 25) {
          if (k > 0) {
            list.addAll(List<int>.filled(k, 40));
            list.add(15);
            list.add(10);
          } else {
            list.addAll([15, 10]);
          }
        } else if (rem == 35) {
          if (k > 0) {
            list.addAll(List<int>.filled(k, 40));
            list.add(20);
            list.add(15);
          } else {
            list.addAll([20, 15]);
          }
        }
        list.sort((a, b) => b.compareTo(a));
        return list;
      }

      if (_levelIndex == 36) {
        if (colorId == 12) {
          final list = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 15, 10];
          list.shuffle();
          return list;
        }
      }

      if (_levelIndex == 37) {
        if (colorId == 12) {
          final list = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20];
          list.shuffle();
          return list;
        }
        if (colorId == 13) {
          final list = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20];
          list.shuffle();
          return list;
        }
        if (colorId == 14) {
          final list = [20, 20, 20, 20, 20, 20, 20, 15, 10];
          list.shuffle();
          return list;
        }
        if (colorId == 31) {
          final list = [20, 20, 20, 20, 15];
          list.shuffle();
          return list;
        }
        if (colorId == 15) {
          final list = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 15, 10];
          list.shuffle();
          return list;
        }
        if (colorId == 19) {
          final list = [15, 10];
          list.shuffle();
          return list;
        }
      }

      if (_levelIndex == 33) {
        if (colorId == 30) {
          int target = deficit;
          if (target < 10) target = 10;
          if (target % 5 != 0) target = ((target + 4) ~/ 5) * 5;
          if (target == 45) {
            return [10, 10, 10, 15];
          } else if (target == 30) {
            return [10, 10, 10];
          } else {
            final list = <int>[];
            int rem = target;
            while (rem >= 40) { list.add(40); rem -= 40; }
            if (rem == 35) { list.addAll([20, 15]); rem = 0; }
            else if (rem == 30) { list.add(30); rem = 0; }
            else if (rem == 25) { list.addAll([15, 10]); rem = 0; }
            else if (rem == 20) { list.add(20); rem = 0; }
            else if (rem == 15) { list.add(15); rem = 0; }
            else if (rem == 10) { list.add(10); rem = 0; }
            else if (rem > 0) { list.add(10); } // fallback
            return list;
          }
        }
        if (colorId == 42) {
          int target = deficit;
          if (target < 10) target = 10;
          if (target % 5 != 0) target = ((target + 4) ~/ 5) * 5;
          final result = <int>[15];
          int remaining = target - 15;
          final sizes = [40, 30, 20, 15, 10];
          final rand = _levelIndex == 33 ? math.Random(level34Seed) : math.Random();
          while (remaining > 0) {
            final options = sizes.where((s) => remaining - s == 0 || remaining - s >= 10).toList();
            if (options.isEmpty) {
              result.add(remaining);
              break;
            }
            final choice = options[rand.nextInt(options.length)];
            result.add(choice);
            remaining -= choice;
          }
          return result;
        }
      }
      final rand = _levelIndex == 33 ? math.Random(level34Seed) : math.Random();
      final allowedSizes = [40, 30, 20, 15, 10];
      int target = deficit;
      if (target < 10) target = 10;
      if (target % 5 != 0) {
        target = ((target + 4) ~/ 5) * 5;
      }
      while (true) {
        final result = <int>[];
        int remaining = target;
        while (remaining > 0) {
          final options = allowedSizes.where((s) {
            final left = remaining - s;
            return left == 0 || left >= 10;
          }).toList();
          if (options.isEmpty) {
            if (remaining >= 10 && remaining % 5 == 0) {
              result.add(remaining);
            } else {
              result.add(10);
            }
            remaining = 0;
            break;
          }
          final choice = options[rand.nextInt(options.length)];
          result.add(choice);
          remaining -= choice;
        }
        if (remaining == 0) {
          result.shuffle(rand);
          return result;
        }
      }
    }
    return CartridgeBatchPlanner.plan(
      deficit: deficit,
      fortyBudget: fortyBudget,
      allowLarge: isBackground,
      forceFirstThreeAsTen: colorId != 11 && !isBackground,
      onlyThirtyAndForty: isBackground,
    );
  }

  int _nextCartridgeId() {
    var nextId = 1;
    for (final cartridge in _cartridges) {
      if (cartridge.id >= nextId) {
        nextId = cartridge.id + 1;
      }
    }
    return nextId;
  }

  void _paintCell(PixelCell target) {
    _cells = [
      for (final cell in _cells)
        if (cell.key == target.key) cell.copyWith(isPainted: true) else cell,
    ];
  }

  void _decreaseMovingMotorAmount(_MovingMotor motor) {
    int reduce(int amount) => amount > 0 ? amount - 1 : 0;
    final nextAmount = reduce(motor.cartridge.amount);

    _movingMotors
      ..removeWhere((item) => item.runId == motor.runId && nextAmount == 0)
      ..replaceWhere(
        (item) => item.runId == motor.runId,
        (item) => item.copyWith(
          cartridge: item.cartridge.copyWith(amount: nextAmount),
        ),
      );
    _cartridges = [
      for (final cartridge in _cartridges)
        if (cartridge.id == motor.cartridge.id)
          cartridge.copyWith(amount: 0)
        else
          cartridge,
    ];
  }

  void _decreaseFiringMotorAmount(_FiringMotor motor) {
    int reduce(int amount) => amount > 0 ? amount - 1 : 0;
    final nextAmount = reduce(motor.cartridge.amount);

    _firingMotors.replaceWhere(
      (item) => item.runId == motor.runId,
      (item) =>
          item.copyWith(cartridge: item.cartridge.copyWith(amount: nextAmount)),
    );
    _cartridges = [
      for (final cartridge in _cartridges)
        if (cartridge.id == motor.cartridge.id)
          cartridge.copyWith(amount: 0)
        else
          cartridge,
    ];

    if (nextAmount == 0) {
      _firingMotors.removeWhere((item) => item.runId == motor.runId);
      _clearShotsForColor(motor.cartridge.color);
    }
  }

  void _finishFiringMotor(_FiringMotor motor) {
    _firingMotors.removeWhere((item) => item.runId == motor.runId);

    if (motor.cartridge.amount <= 0) {
      return;
    }

    if (!_isCartridgeUseful(motor.cartridge.colorId)) {
      return;
    }

    final returningSlotIndex = _firstEmptySlotIndex();
    if (returningSlotIndex == -1) {
      _triggerGameOver();
      return;
    }

    _slots = [
      for (final slot in _slots)
        if (slot.index == returningSlotIndex)
          slot.fill(motor.cartridge)
        else
          slot,
    ];
  }

  void _removeSlotCartridgeAndCompact(int slotIndex) {
    final cartridges = [
      for (final slot in _slots)
        if (slot.index != slotIndex && slot.cartridge != null) slot.cartridge!,
    ];
    _slots = [
      for (var index = 0; index < _slots.length; index++)
        if (index < cartridges.length)
          WaitingSlot(index: index).fill(cartridges[index])
        else
          WaitingSlot(index: index),
    ];
  }

  void _handleLevelComplete(DateTime now) {
    _completedAt ??= now;

    if (!_showCompletionOverlay &&
        now.difference(_completedAt!) >= const Duration(milliseconds: 650)) {
      _showCompletionOverlay = true;
      _shotEvents.clear();
    }

    _movingMotors.clear();
    _firingMotors.clear();
    _isGameOver = false;
    _slots = List.generate(5, (index) => WaitingSlot(index: index));
    _cartridges = [
      for (final cartridge in _cartridges)
        cartridge.copyWith(amount: 0, isSelected: false),
    ];
    if (_showCompletionOverlay && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _ensureTicker() {
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _triggerGameOver() {
    _spendLife();
    _isGameOver = true;
    _movingMotors.clear();
    _firingMotors.clear();
    _shotEvents.clear();
    _burnedColorIds.clear();
    if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  void _spendLife() {
    if (_lives <= 0) {
      return;
    }
    _lives--;
    _nextLifeAt ??= DateTime.now().add(_lifeRestoreDuration);
  }

  void _restoreLives() {
    if (_lives >= _maxLives || _nextLifeAt == null) {
      return;
    }

    final now = DateTime.now();
    var changed = false;
    while (_nextLifeAt != null &&
        !now.isBefore(_nextLifeAt!) &&
        _lives < _maxLives) {
      _lives++;
      changed = true;
      _nextLifeAt = _lives < _maxLives
          ? _nextLifeAt!.add(_lifeRestoreDuration)
          : null;
    }

    if (changed && mounted) {
      setState(() {});
    }
  }

  void _clearShotsForColor(Color color) {
    _shotEvents.removeWhere((shot) => shot.color == color);
  }

  String _lineKey(ActiveMotor motor) => '${motor.side.name}:${motor.lineIndex}';

  void _resetPrototype() {
    if (_ticker.isActive) {
      _ticker.stop();
    }
    _cells = LevelData.createCells(levelIndex: _levelIndex);
    _generatedFortyCount = 0;
    _cartridges = _buildCartridgeQueue();
    _slots = List.generate(5, (index) => WaitingSlot(index: index));
    _movingMotors.clear();
    _firingMotors.clear();
    _shotEvents.clear();
    _burnedColorIds.clear();
    _isGameOver = false;
    _isMagnetModeActive = false;
    _showCompletionOverlay = false;
    _completedAt = null;
    _nextRunId = 1;
  }

  void _advanceLevel() {
    _levelIndex = (_levelIndex + 1) % LevelData.levels.length;
    _resetPrototype();
  }

  String get _statusText {
    if (_isGameOver) {
      return 'Slot doluyken silah geri dondu';
    }
    if (_isLevelComplete) {
      return 'Level tamamlandi';
    }
    if (_activeOrbitCount >= _orbitPullCount) {
      return 'Donen silah limiti dolu';
    }
    if (_burnedColorIds.isNotEmpty) {
      return 'Silah yandi, yeniden baslamak gerekebilir';
    }
    if (!_hasEmptySlot()) {
      return 'Slotlar dolu, bir silahi calistir';
    }
    if (_movingMotors.isNotEmpty || _firingMotors.isNotEmpty) {
      return 'Silah hareket ediyor';
    }
    return 'Silahi sec, turdan sonra slota otursun';
  }

  void _restartAfterGameOver() {
    if (_lives <= 0) {
      return;
    }
    setState(_resetPrototype);
  }

  void _continueWithPay() {
    setState(() {
      for (final slot in _slots) {
        if (slot.cartridge != null && slot.cartridge!.amount > 0) {
          final cartridgeInSlot = slot.cartridge!;
          _cartridges = [
            for (final c in _cartridges)
              if (c.id == cartridgeInSlot.id)
                c.copyWith(amount: c.amount + cartridgeInSlot.amount)
              else
                c
          ];
        }
      }
      _slots = List.generate(5, (index) => WaitingSlot(index: index));
      _isGameOver = false;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '1 \$ ödenerek oyuna devam ediliyor! Slotlar temizlendi ve kartuşlar geri yüklendi.',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFFCE9E4F),
        ),
      );
    });
    _ensureTicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E222D), // Dark blue-purple top
                  Color(0xFF151821), // Even darker blue-purple bottom
                ],
              ),
            ),
            child: CustomPaint(
              painter: const _AtmospherePainter(),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxHeight < 1200;
                    final verticalPadding = isCompact ? 8.0 : 12.0;
                    final gap = isCompact ? 8.0 : 12.0;
                    final boardSide = math
                        .min(
                          constraints.maxWidth - 28,
                          constraints.maxHeight - (isCompact ? 520 : 580),
                        )
                        .clamp(200.0, 520.0);

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 540),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            14,
                            verticalPadding,
                            14,
                            verticalPadding + 24,
                          ),
                          child: Column(
                            children: [
                                ProgressHeader(
                                  progress: _progress,
                                paintedCount: _paintedCount,
                                targetCount: _targetCount,
                                levelNumber: _levelIndex + 1,
                                onReset: () => setState(_resetPrototype),
                                onMenu: widget.onOpenMenu,
                              ),
                              SizedBox(height: isCompact ? 6 : 8),
                              _TopStatsRow(
                                lives: _lives,
                                maxLives: _maxLives,
                                isCompact: isCompact,
                              ),
                              SizedBox(height: gap),
                              GameBoardPanel(
                                cells: _cells,
                                colorValues: LevelData.colorValues,
                                rows: _gridRows,
                                cols: _gridCols,
                                activeMotors: _activeMotors,
                                shotEvents: _shotEvents,
                                maxSide: boardSide,
                                isCompact: isCompact,
                                backgroundColors: _backgroundColors,
                                onCellTap: _levelIndex == 49 && _isMagnetModeActive
                                    ? _onBoardCellTapped
                                    : null,
                              ),
                              SizedBox(height: isCompact ? 6 : 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _PullCounter(
                                  total: _orbitPullCount,
                                  used: _activeOrbitCount,
                                ),
                              ),
                              SizedBox(height: gap),
                              WaitingSlotBar(
                                slots: _slots,
                                onSlotTap: _handleSlotTap,
                                isCompact: isCompact,
                              ),
                              SizedBox(height: isCompact ? 7 : 10),
                              Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  minHeight: isCompact ? 28 : 34,
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF5C3D24),
                                      Color(0xFF352010),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFCE9E4F),
                                    width: 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF2C1908),
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _statusText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFFBE49E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              SizedBox(height: isCompact ? 8 : 12),
                              CartridgeBar(
                                cartridges: _cartridges,
                                onCartridgeTap: _selectCartridge,
                                isCompact: isCompact,
                                columnCount: _levelIndex == 29 ? 4 : 3,
                                hideSecondRow: _levelIndex >= 31,
                              ),
                              SizedBox(height: isCompact ? 4 : 6),
                              _PremiumBeveledButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => _CartridgesPreviewDialog(
                                      cartridges: _cartridges,
                                    ),
                                  );
                                },
                                label: 'TÜM KARTUŞLARI GÖSTER',
                                icon: Icons.visibility,
                                gradientColors: const [
                                  Color(0xFF5C3D24),
                                  Color(0xFF352010),
                                ],
                              ),
                              SizedBox(height: isCompact ? 8 : 12),
                              _BoosterDock(
                                isCompact: isCompact,
                                onMagnetPressed: _levelIndex == 49 ? _useMagnetBooster : null,
                                isMagnetActive: _isMagnetModeActive,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_showCompletionOverlay)
            Positioned.fill(
              child: Container(
                color: const Color(0x9911141E),
                child: Center(
                  child: _LuxuryDialogCard(
                    title: 'Level Complete',
                    gemColors: const [Color(0xFF5D9EF7), Color(0xFF1B60C6)], // Sapphire Blue
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFFBE49E),
                          size: 40,
                          shadows: [
                            Shadow(color: Color(0xFF1E1107), offset: Offset(0, 1.5), blurRadius: 4.0),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Mükemmel Çözüm!',
                          style: TextStyle(
                            color: Color(0xFFFBEFD3),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(color: Colors.black87, offset: Offset(0, 1.5), blurRadius: 2.0),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bölüm tüm detaylarıyla başarıyla boyandı.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFC4B295),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _PremiumBeveledButton(
                          onPressed: () => setState(_advanceLevel),
                          label: 'Next Level',
                          icon: Icons.arrow_forward_rounded,
                          gradientColors: const [Color(0xFFE29B3C), Color(0xFFAB7315)], // Gold gradient
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_isGameOver)
            Positioned.fill(
              child: Container(
                color: const Color(0x9911141E),
                child: Center(
                  child: _LuxuryDialogCard(
                    title: 'Game Over',
                    gemColors: const [Color(0xFFFF6A7C), Color(0xFFC62828)], // Ruby Red
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFFF6A7C),
                          size: 40,
                          shadows: [
                            Shadow(color: Color(0xFF1E1107), offset: Offset(0, 1.5), blurRadius: 4.0),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Yenilgi!',
                          style: TextStyle(
                            color: Color(0xFFFBEFD3),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(color: Colors.black87, offset: Offset(0, 1.5), blurRadius: 2.0),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Slotlar doluyken silah geri döndü.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFC4B295),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _lifeStatusText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFF6A7C),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _PremiumBeveledButton(
                          onPressed: _continueWithPay,
                          label: 'DEVAM ET (1 \$)',
                          icon: Icons.monetization_on_rounded,
                          gradientColors: const [Color(0xFFE29B3C), Color(0xFFAB7315)], // Gold gradient
                        ),
                        const SizedBox(height: 12),
                        _PremiumBeveledButton(
                          onPressed: _lives > 0 ? _restartAfterGameOver : () {},
                          label: _lives > 0 ? 'Restart' : 'Can Bekle',
                          icon: Icons.replay_rounded,
                          gradientColors: _lives > 0
                              ? const [Color(0xFFB32828), Color(0xFF801A1A)] // Ruby Red
                              : const [Color(0xFF7A828A), Color(0xFF4C5259)], // Locked Gray
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw slate-marble base gradient glows
    final topGlow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF1E355A).withAlpha(150), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.25, size.height * 0.12),
          radius: size.width * 0.75,
        ),
      );
    final midGlow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF132035).withAlpha(110), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.88, size.height * 0.36),
          radius: size.width * 0.82,
        ),
      );
    canvas.drawRect(Offset.zero & size, topGlow);
    canvas.drawRect(Offset.zero & size, midGlow);

    // 2. Draw subtle organic slate/marble veins
    final veinPaint = Paint()
      ..color = const Color(0xFFE5D5C5).withAlpha(12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

    // Vein 1
    final path1 = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.18, size.width * 0.4, size.height * 0.3)
      ..cubicTo(size.width * 0.55, size.height * 0.42, size.width * 0.45, size.height * 0.6, size.width * 0.7, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.82, size.width, size.height * 0.9);
    canvas.drawPath(path1, veinPaint);

    // Vein 2
    final path2 = Path()
      ..moveTo(size.width, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.25, size.width * 0.6, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.55, size.width * 0.2, size.height * 0.65)
      ..lineTo(0, size.height * 0.8);
    canvas.drawPath(path2, veinPaint);

    // Vein 3 (Fine branch)
    final path3 = Path()
      ..moveTo(size.width * 0.4, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.4, size.width * 0.1, size.height * 0.35)
      ..quadraticBezierTo(0, size.height * 0.38, 0, size.height * 0.4);
    canvas.drawPath(path3, veinPaint);

    // 3. Draw elegant Art-Deco gold geometric lines and frames (gold foil)
    final goldRect = Offset.zero & size;
    final goldGlowShader = const LinearGradient(
      colors: [Color(0xFFE29B3C), Color(0xFFFBE49E), Color(0xFFC86446), Color(0xFFFBE49E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(goldRect);

    final goldPaintThin = Paint()
      ..shader = goldGlowShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final goldPaintThick = Paint()
      ..shader = goldGlowShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Draw top art-deco header framing
    final topFrame = Path()
      ..moveTo(0, size.height * 0.08)
      ..lineTo(size.width * 0.15, size.height * 0.08)
      ..lineTo(size.width * 0.22, size.height * 0.04)
      ..lineTo(size.width * 0.78, size.height * 0.04)
      ..lineTo(size.width * 0.85, size.height * 0.08)
      ..lineTo(size.width, size.height * 0.08);
    canvas.drawPath(topFrame, goldPaintThin);

    // Draw central art-deco circles
    final center = Offset(size.width * 0.5, size.height * 0.45);
    canvas.drawCircle(center, size.width * 0.48, goldPaintThin);
    canvas.drawCircle(center, size.width * 0.50, goldPaintThin);

    // Draw bottom corner art-deco triangles and diamonds (like the user reference image)
    // Bottom-left decoration
    final blCorner = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width * 0.25, size.height * 0.96)
      ..lineTo(size.width * 0.25, size.height)
      ..moveTo(0, size.height * 0.72)
      ..lineTo(size.width * 0.28, size.height * 0.96)
      ..lineTo(size.width * 0.28, size.height);
    canvas.drawPath(blCorner, goldPaintThin);

    final blTriangle = Path()
      ..moveTo(0, size.height * 0.80)
      ..lineTo(size.width * 0.20, size.height * 0.96)
      ..lineTo(0, size.height * 0.96)
      ..close();
    canvas.drawPath(blTriangle, goldPaintThin);

    // Bottom-right decoration
    final brCorner = Path()
      ..moveTo(size.width, size.height * 0.75)
      ..lineTo(size.width * 0.75, size.height * 0.96)
      ..lineTo(size.width * 0.75, size.height)
      ..moveTo(size.width, size.height * 0.72)
      ..lineTo(size.width * 0.72, size.height * 0.96)
      ..lineTo(size.width * 0.72, size.height);
    canvas.drawPath(brCorner, goldPaintThin);

    final brTriangle = Path()
      ..moveTo(size.width, size.height * 0.80)
      ..lineTo(size.width * 0.80, size.height * 0.96)
      ..lineTo(size.width, size.height * 0.96)
      ..close();
    canvas.drawPath(brTriangle, goldPaintThin);

    // Intersecting horizontal bar at bottom
    canvas.drawLine(
      Offset(0, size.height * 0.96),
      Offset(size.width, size.height * 0.96),
      goldPaintThick,
    );
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) => false;
}

class _TopStatsRow extends StatelessWidget {
  const _TopStatsRow({
    required this.lives,
    required this.maxLives,
    required this.isCompact,
  });

  final int lives;
  final int maxLives;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: isCompact ? 40 : 46,
          height: isCompact ? 40 : 46,
          decoration: BoxDecoration(
            color: const Color(0xFF352010),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCE9E4F), width: 2.0),
            boxShadow: const [
              BoxShadow(color: Color(0xFF2C1908), offset: Offset(0, 2), blurRadius: 4),
            ],
          ),
          child: const Center(
            child: Icon(Icons.person_rounded, color: Color(0xFFFBE49E), size: 24),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: isCompact ? 34 : 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5C3D24), Color(0xFF352010)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCE9E4F), width: 2.0),
              boxShadow: const [
                BoxShadow(color: Color(0xFF2C1908), offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded, color: Color(0xFFFF6A7C), size: 18),
                const SizedBox(width: 6),
                Text(
                  '$lives / $maxLives',
                  style: const TextStyle(
                    color: Color(0xFFFBE49E),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'MAX',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: isCompact ? 34 : 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5C3D24), Color(0xFF352010)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCE9E4F), width: 2.0),
              boxShadow: const [
                BoxShadow(color: Color(0xFF2C1908), offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.monetization_on_rounded, color: Color(0xFFFBE49E), size: 18),
                SizedBox(width: 6),
                Text(
                  '1.50k',
                  style: TextStyle(
                    color: Color(0xFFFBE49E),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.add_circle_rounded, color: Color(0xFF42E88A), size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BoosterDock extends StatelessWidget {
  const _BoosterDock({
    required this.isCompact,
    this.onMagnetPressed,
    this.isMagnetActive = false,
  });

  final bool isCompact;
  final VoidCallback? onMagnetPressed;
  final bool isMagnetActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 56 : 80,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isCompact ? 5 : 12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAD8B3), Color(0xFFD4C29D)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCE9E4F), width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF160D06),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BoosterButton(
            icon: Icons.bolt_rounded,
            badgeCount: 3,
            isCompact: isCompact,
            cushionColors: const [Color(0xFFB32828), Color(0xFF801A1A)],
          ),
          _BoosterButton(
            icon: Icons.auto_fix_high_rounded,
            badgeCount: 1,
            isCompact: isCompact,
            cushionColors: const [Color(0xFFB32828), Color(0xFF801A1A)],
          ),
          _BoosterButton(
            icon: Icons.explore_rounded,
            isCompact: isCompact,
            isLocked: onMagnetPressed == null,
            cushionColors: onMagnetPressed == null
                ? const [Color(0xFF7A828A), Color(0xFF4C5259)]
                : (isMagnetActive
                    ? const [Color(0xFFCE9E4F), Color(0xFF9E7833)]
                    : const [Color(0xFF1E4C80), Color(0xFF102D59)]),
            onPressed: onMagnetPressed,
          ),
          _BoosterButton(
            icon: Icons.lock_rounded,
            isLocked: true,
            isCompact: isCompact,
            cushionColors: const [Color(0xFF7A828A), Color(0xFF4C5259)],
          ),
        ],
      ),
    );
  }
}

class _BoosterButton extends StatelessWidget {
  const _BoosterButton({
    required this.icon,
    this.isLocked = false,
    this.badgeCount,
    required this.cushionColors,
    required this.isCompact,
    this.onPressed,
  });

  final IconData icon;
  final bool isLocked;
  final int? badgeCount;
  final List<Color> cushionColors;
  final bool isCompact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onPressed,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isCompact ? 42 : 54,
              height: isCompact ? 42 : 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCE9E4F), width: 2.5),
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.2),
                  radius: 0.85,
                  colors: cushionColors,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF2C1908),
                    offset: Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: const Color(0xFFFBE49E), size: isCompact ? 21 : 28),
              ),
            ),
            if (badgeCount != null)
              Positioned(
                right: isCompact ? -4 : -6,
                top: isCompact ? -4 : -6,
                child: Container(
                  width: isCompact ? 17 : 22,
                  height: isCompact ? 17 : 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFBE49E),
                    border: Border.all(color: const Color(0xFF53381B), width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: const Color(0xFF53381B),
                      fontSize: isCompact ? 9 : 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartridgeRequest {
  const _CartridgeRequest({required this.baseCartridge, required this.amount});

  final PaintCartridge baseCartridge;
  final int amount;
}

class _PullCounter extends StatelessWidget {
  const _PullCounter({required this.total, required this.used});

  final int total;
  final int used;

  @override
  Widget build(BuildContext context) {
    final available = (total - used).clamp(0, total).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5C3D24),
            Color(0xFF352010),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCE9E4F), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF2C1908),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < total; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < available
                      ? const Color(0xFF52C47C)
                      : const Color(0xFF2C1908),
                  border: Border.all(
                    color: const Color(0xFFCE9E4F),
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (index < available)
                      const BoxShadow(color: Color(0x2252C47C), blurRadius: 6),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            '$available/$total',
            style: const TextStyle(
              color: Color(0xFFFBE49E),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovingMotor {
  const _MovingMotor({
    required this.runId,
    required this.cartridge,
    required this.startedAt,
    required this.processedLineKeys,
  });

  final int runId;
  final PaintCartridge cartridge;
  final DateTime startedAt;
  final Set<String> processedLineKeys;

  _MovingMotor copyWith({
    PaintCartridge? cartridge,
    DateTime? startedAt,
    Set<String>? processedLineKeys,
  }) {
    return _MovingMotor(
      runId: runId,
      cartridge: cartridge ?? this.cartridge,
      startedAt: startedAt ?? this.startedAt,
      processedLineKeys: processedLineKeys ?? this.processedLineKeys,
    );
  }
}

class _FiringMotor {
  const _FiringMotor({
    required this.runId,
    required this.slotIndex,
    required this.cartridge,
    required this.startedAt,
    required this.processedLineKeys,
  });

  final int runId;
  final int slotIndex;
  final PaintCartridge cartridge;
  final DateTime startedAt;
  final Set<String> processedLineKeys;

  _FiringMotor copyWith({PaintCartridge? cartridge}) {
    return _FiringMotor(
      runId: runId,
      slotIndex: slotIndex,
      cartridge: cartridge ?? this.cartridge,
      startedAt: startedAt,
      processedLineKeys: processedLineKeys,
    );
  }
}

extension _FiringMotorListX on List<_FiringMotor> {
  void replaceWhere(
    bool Function(_FiringMotor motor) test,
    _FiringMotor Function(_FiringMotor motor) replace,
  ) {
    for (var i = 0; i < length; i++) {
      if (test(this[i])) {
        this[i] = replace(this[i]);
      }
    }
  }
}

extension _MovingMotorListX on List<_MovingMotor> {
  void replaceWhere(
    bool Function(_MovingMotor motor) test,
    _MovingMotor Function(_MovingMotor motor) replace,
  ) {
    for (var i = 0; i < length; i++) {
      if (test(this[i])) {
        this[i] = replace(this[i]);
      }
    }
  }
}

class _PremiumBeveledButton extends StatefulWidget {
  const _PremiumBeveledButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    this.gradientColors = const [Color(0xFFB32828), Color(0xFF801A1A)], // default ruby red
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  @override
  State<_PremiumBeveledButton> createState() => _PremiumBeveledButtonState();
}

class _PremiumBeveledButtonState extends State<_PremiumBeveledButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCE9E4F), width: 2.2), // Polished gold rim
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF1A0F08),
                offset: Offset(0, 5),
                blurRadius: 6,
              ),
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.gradientColors,
            ),
          ),
          child: CustomPaint(
            painter: const _ButtonGlossPainter(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: const Color(0xFFFBE49E), // Gold text color
                  size: 20,
                  shadows: const [
                    Shadow(color: Colors.black54, offset: Offset(0, 1.5), blurRadius: 2.0),
                  ],
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Color(0xFFFBE49E), // Gold text
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Colors.black54, offset: Offset(0, 1.5), blurRadius: 2.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonGlossPainter extends CustomPainter {
  const _ButtonGlossPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a diagonal semi-transparent gloss/sheen highlight crossing the button
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.25, size.height)
      ..lineTo(0, size.height)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withAlpha(50),
          Colors.white.withAlpha(10),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, paint);

    // Draw the 3D bevel effect lines:
    // Top inner light highlight (white)
    final lightBevel = Paint()
      ..color = Colors.white.withAlpha(70)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), lightBevel);
    canvas.drawLine(Offset.zero, Offset(0, size.height), lightBevel);

    // Bottom inner shadow line (black)
    final darkBevel = Paint()
      ..color = Colors.black.withAlpha(100)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), darkBevel);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), darkBevel);
  }

  @override
  bool shouldRepaint(covariant _ButtonGlossPainter oldDelegate) => false;
}

class _LuxuryDialogCard extends StatelessWidget {
  const _LuxuryDialogCard({
    required this.title,
    required this.gemColors,
    required this.child,
  });

  final String title;
  final List<Color> gemColors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFCE9E4F), width: 3.5), // Brushed gold frame
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF160D06),
            offset: Offset(0, 12),
            blurRadius: 16,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF422C1A), // Luxury dark wood/bronze background
            Color(0xFF23140A),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Corner gems
          // Top-Left Gem
          Positioned(
            left: 6,
            top: 6,
            child: _CornerGem(colors: gemColors),
          ),
          // Top-Right Gem
          Positioned(
            right: 6,
            top: 6,
            child: _CornerGem(colors: gemColors),
          ),
          // Bottom-Left Gem
          Positioned(
            left: 6,
            bottom: 6,
            child: _CornerGem(colors: gemColors),
          ),
          // Bottom-Right Gem
          Positioned(
            right: 6,
            bottom: 6,
            child: _CornerGem(colors: gemColors),
          ),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
            child: child,
          ),

          // Gold Leaf Ribbon Header Banner
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCE9E4F), width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF1E1107),
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE29B3C), // Gold gradient
                      Color(0xFFC86446),
                    ],
                  ),
                ),
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(color: Color(0xFF53381B), offset: Offset(0, 1.5), blurRadius: 2.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerGem extends StatelessWidget {
  const _CornerGem({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCE9E4F), width: 1.5), // Gold bezel
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2),
        ],
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: colors,
        ),
      ),
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(200),
          ),
        ),
      ),
    );
  }
}

class _CartridgesPreviewDialog extends StatelessWidget {
  const _CartridgesPreviewDialog({required this.cartridges});

  final List<PaintCartridge> cartridges;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      child: Container(
        width: 380,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFCE9E4F), width: 3.5), // Brushed gold frame
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF422C1A), // Luxury dark wood/bronze background
              Color(0xFF23140A),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF160D06),
              offset: Offset(0, 12),
              blurRadius: 16,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                'SLOT KUYRUKLARI',
                style: TextStyle(
                  color: Color(0xFFFBE49E),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Toplam: ${cartridges.length} kartuş',
                style: const TextStyle(
                  color: Color(0xFFCE9E4F),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Divider line
              Container(
                height: 1,
                color: const Color(0xFFCE9E4F).withAlpha(100),
              ),
              const SizedBox(height: 12),
              
              // Column Headers: SOL SLOT, ORTA SLOT, SAĞ SLOT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Row(
                  children: [
                    for (final title in ['SOL SLOT', 'ORTA SLOT', 'SAĞ SLOT'])
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            color: const Color(0x33CE9E4F),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCE9E4F), width: 1),
                          ),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFBE49E),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Scrollable Grid View
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: cartridges.length,
                  itemBuilder: (context, index) {
                    final c = cartridges[index];
                    final isUsed = c.amount <= 0;
                    final displayColor = isUsed ? const Color(0xFF5F6988).withAlpha(120) : c.color;

                    return Opacity(
                      opacity: isUsed ? 0.35 : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: displayColor.withAlpha(220),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isUsed ? const Color(0xFF8A93A6) : const Color(0xFFCE9E4F),
                            width: isUsed ? 1.0 : 1.8,
                          ),
                          boxShadow: [
                            if (!isUsed)
                              BoxShadow(
                                color: c.color.withAlpha(80),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${index + 1}. sıra',
                                  style: TextStyle(
                                    color: isUsed ? Colors.white.withAlpha(120) : Colors.white.withAlpha(200),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (isUsed)
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white70,
                                    size: 16,
                                  )
                                else
                                  Text(
                                    '${c.amount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(1, 1),
                                          blurRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Close button
              _PremiumBeveledButton(
                onPressed: () => Navigator.of(context).pop(),
                label: 'KAPAT',
                icon: Icons.close,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


