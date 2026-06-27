import 'package:flutter/material.dart';

import '../models/paint_cartridge.dart';
import 'cartridge_widget.dart';

class CartridgeBar extends StatelessWidget {
  const CartridgeBar({
    super.key,
    required this.cartridges,
    required this.onCartridgeTap,
    this.isCompact = false,
    this.columnCount = 3,
    this.hideSecondRow = false,
  });

  final List<PaintCartridge> cartridges;
  final ValueChanged<PaintCartridge> onCartridgeTap;
  final bool isCompact;
  final int columnCount;
  final bool hideSecondRow;

  @override
  Widget build(BuildContext context) {
    final visibleRows = _visibleColumnRows(cartridges, columnCount);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isCompact ? 4 : 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < 2; row++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var column = 0; column < columnCount; column++)
                  SizedBox(
                    width: isCompact
                        ? (columnCount == 4 ? 54 : 72)
                        : (columnCount == 4 ? 84 : 112),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact
                            ? (columnCount == 4 ? 3 : 7)
                            : (columnCount == 4 ? 4 : 9),
                      ),
                      child: (visibleRows[row][column] != null && !(row == 1 && hideSecondRow))
                          ? CartridgeWidget(
                              key: ValueKey(
                                'active:${visibleRows[row][column]!.id}',
                              ),
                              cartridge: visibleRows[row][column]!,
                              isCompact: isCompact,
                              onTap: row == 0
                                  ? () => onCartridgeTap(
                                      visibleRows[row][column]!,
                                    )
                                  : null,
                            )
                          : SizedBox(height: isCompact ? 50 : 84),
                    ),
                  ),
              ],
            ),
            if (row == 0) SizedBox(height: isCompact ? 3 : 5),
          ],
        ],
      ),
    );
  }

  List<List<PaintCartridge?>> _visibleColumnRows(
    List<PaintCartridge> cartridges,
    int columnCount,
  ) {
    final rows = List.generate(2, (_) => List<PaintCartridge?>.filled(columnCount, null));

    for (var column = 0; column < columnCount; column++) {
      var row = 0;
      for (var index = column; index < cartridges.length; index += columnCount) {
        final cartridge = cartridges[index];
        if (cartridge.amount > 0) {
          rows[row][column] = cartridge;
          row++;
          if (row == rows.length) {
            break;
          }
        }
      }
    }

    return rows;
  }
}
