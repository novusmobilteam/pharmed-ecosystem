enum DataBit {
  data1(1),
  data8(2),
  data16(3);

  const DataBit(this.id);

  final int id;

  static DataBit? fromId(int? id) {
    return DataBit.values.firstWhere(
      (e) => e.id == id,
      orElse: () => DataBit.data1,
    );
  }
}
