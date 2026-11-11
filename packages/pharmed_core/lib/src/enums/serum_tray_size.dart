// [SWREQ-CORE-CABIN-SERUM-001] [IEC 62304 §5.5]
// Serum kabini avadanlık boyutu.
// Sınıf: Class B

/// Serum kabini rafına yerleştirilebilen avadanlık boyutu.
///
/// API'de `cabinDrawrDetails[].toolSize` alanına karşılık gelir ([id]).
/// [areaSize] avadanlığın raftaki 8 alandan kaç tanesini kapladığıdır;
/// API değeriyle aynı DEĞİLDİR (büyük = id 3, alan 4).
///
/// [openShelf] gerçek bir avadanlık değildir: rafın avadanlıksız "Açık Raf"
/// olarak tanımlandığını belirtir (API `ToolSizes.OpenShelf = 4`). Açık rafta
/// tüm rafı kaplayan TEK kayıt bulunur; ilaç atamaları bu kayda yapılır ve
/// birden fazla farklı ilaç atanabilir.
enum SerumTraySize {
  small(1, 1),
  medium(2, 2),
  large(3, 4),
  openShelf(4, 8);

  const SerumTraySize(this.id, this.areaSize);

  final int id;
  final int areaSize;

  bool get isOpenShelf => this == SerumTraySize.openShelf;

  /// Kullanıcının rafa ekleyebileceği gerçek avadanlık boyutları.
  static const trayValues = [small, medium, large];

  static SerumTraySize? fromId(int? id) => SerumTraySize.values.where((e) => e.id == id).firstOrNull;
}
