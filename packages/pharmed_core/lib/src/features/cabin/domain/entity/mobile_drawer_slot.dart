// pharmed_core/src/cabin/entity/mobile_drawer_slot.dart
//
// [SWREQ-UI-DASH-003]
// Mobil kabin slot entity'si.
// API'den nested olarak dönen slot + unit + cell hiyerarşisini temsil eder.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class MobileDrawerSlot {
  const MobileDrawerSlot({
    required this.id,
    required this.orderNumber,
    required this.address,
    required this.cabinId,
    required this.units,
  });

  final int id;
  final int orderNumber;
  final String address;
  final int cabinId;
  final List<MobileDrawerUnit> units; // satırlar

  MobileDrawerSlot copyWith({int? id, int? orderNumber, String? address, int? cabinId, List<MobileDrawerUnit>? units}) {
    return MobileDrawerSlot(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      address: address ?? this.address,
      cabinId: cabinId ?? this.cabinId,
      units: units ?? this.units,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is MobileDrawerSlot && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MobileDrawerSlot(id: $id, orderNumber: $orderNumber, units: ${units.length})';
}
