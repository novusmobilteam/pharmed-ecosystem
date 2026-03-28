enum StopBit {
  stop1(1),
  stop8(2),
  stop16(3);

  const StopBit(this.id);

  final int id;

  static StopBit? fromId(int? id) {
    return StopBit.values.firstWhere(
      (e) => e.id == id,
      orElse: () => StopBit.stop1,
    );
  }
}
