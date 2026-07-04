class PixelCell {
  const PixelCell({
    required this.row,
    required this.col,
    required this.targetColorId,
    this.isPainted = false,
    this.isObstacle = false,
  });

  final int row;
  final int col;
  final int targetColorId;
  final bool isPainted;
  final bool isObstacle;

  String get key => '$row:$col';

  bool get isTarget => targetColorId > 0 && !isObstacle;

  PixelCell copyWith({bool? isPainted, bool? isObstacle}) {
    return PixelCell(
      row: row,
      col: col,
      targetColorId: targetColorId,
      isPainted: isPainted ?? this.isPainted,
      isObstacle: isObstacle ?? this.isObstacle,
    );
  }
}
