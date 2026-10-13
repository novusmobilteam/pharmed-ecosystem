// [SWREQ-CORE-CABIN-SERUM-001] [IEC 62304 §5.5]
// Serum kabini avadanlık boyutu.
// Sınıf: Class B

/// Serum kabini rafına yerleştirilebilen avadanlık boyutu.
///
/// API'de `cabinDrawrDetails[].toolSize` alanına karşılık gelir ([id]).
/// [areaSize] avadanlığın raftaki 8 alandan kaç tanesini kapladığıdır;
/// API değeriyle aynı DEĞİLDİR (büyük = id 3, alan 4).
enum SerumTraySize {
  small(1, 1),
  medium(2, 2),
  large(3, 4);

  const SerumTraySize(this.id, this.areaSize);

  final int id;
  final int areaSize;

  static SerumTraySize? fromId(int? id) => SerumTraySize.values.where((e) => e.id == id).firstOrNull;
}
