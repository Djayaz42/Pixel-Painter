class PixelCell {
  const PixelCell({
    required this.row,
    required this.col,
    required this.targetColorId,
    this.isPainted = false,
  });

  final int row;
  final int col;
  final int targetColorId;
  final bool isPainted;

  String get key => '$row:$col';

  bool get isTarget => targetColorId > 0;

  PixelCell copyWith({bool? isPainted}) {
    return PixelCell(
      row: row,
      col: col,
      targetColorId: targetColorId,
      isPainted: isPainted ?? this.isPainted,
    );
  }
}
