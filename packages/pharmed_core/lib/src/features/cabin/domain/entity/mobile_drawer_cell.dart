// pharmed_core/src/cabin/entity/mobile_drawer_cell.dart
//
// Mobil kabindeki en küçük depolama birimi — tek bir göz.
// Hasta atama ve stok işlemleri bu id üzerinden yapılır.
// Sınıf: Class B

class MobileDrawerCell {
  const MobileDrawerCell({required this.id, required this.unitId, required this.stepNo});

  final int id;
  final int unitId; // MobileDrawerUnit.id karşılığı (cabinDrawrId)
  final int stepNo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MobileDrawerCell && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MobileDrawerCell(id: $id, unitId: $unitId, stepNo: $stepNo)';
}
