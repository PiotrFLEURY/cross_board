class CrossBoardItem {
  final CrossBoardItemType type;
  final dynamic item;

  CrossBoardItem({
    this.type = CrossBoardItemType.unknown,
    required this.item,
  });
}

/// Item type (TEXT, IMG, VIDEO, AUDIO, ...)
enum CrossBoardItemType {
  text,
  img,
  video,
  audio,
  unknown,
}
