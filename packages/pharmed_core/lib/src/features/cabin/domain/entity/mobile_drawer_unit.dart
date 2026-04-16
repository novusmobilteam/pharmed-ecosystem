// pharmed_core/src/cabin/entity/mobile_drawer_unit.dart
//
// Mobil kabindeki bir satırı temsil eder.
// cells.length → o satırdaki sütun (göz) sayısı.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class MobileDrawerUnit {
  const MobileDrawerUnit({
    required this.id,
    required this.slotId,
    required this.orderNo,
    required this.cells,
    this.workingStatus = CabinWorkingStatus.working,
  });

  final int id;
  final int slotId; // DrawerSlot.id karşılığı (cabinDesignId)
  final int orderNo; // satır sırası
  final List<MobileDrawerCell> cells;
  final CabinWorkingStatus workingStatus;

  int get columnCount => cells.length;

  MobileDrawerUnit copyWith({
    int? id,
    int? slotId,
    int? orderNo,
    List<MobileDrawerCell>? cells,
    CabinWorkingStatus? workingStatus,
  }) {
    return MobileDrawerUnit(
      id: id ?? this.id,
      slotId: slotId ?? this.slotId,
      orderNo: orderNo ?? this.orderNo,
      cells: cells ?? this.cells,
      workingStatus: workingStatus ?? this.workingStatus,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is MobileDrawerUnit && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MobileDrawerUnit(id: $id, orderNo: $orderNo, columns: $columnCount)';
}
