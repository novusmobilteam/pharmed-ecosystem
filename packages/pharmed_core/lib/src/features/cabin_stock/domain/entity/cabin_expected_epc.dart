import 'package:pharmed_core/pharmed_core.dart';

class CabinExpectedEpc {
  CabinExpectedEpc({
    this.id,
    this.cabinId,
    this.cabinStockId,
    this.rfidTag,
    this.isActive,
    this.prescriptionItemId,
    this.cabinStock,
    this.prescriptionItem,
  });

  final int? id;
  final int? cabinId;
  final int? cabinStockId;
  final String? rfidTag;
  final bool? isActive;
  final int? prescriptionItemId;
  final CabinStock? cabinStock;
  final PrescriptionItem? prescriptionItem;

  CabinExpectedEpc copyWith({
    int? id,
    int? cabinId,
    int? cabinStockId,
    String? rfidTag,
    bool? isActive,
    int? prescriptionItemId,
    CabinStock? cabinStock,
    PrescriptionItem? prescriptionItem,
  }) {
    return CabinExpectedEpc(
      id: id ?? this.id,
      cabinId: cabinId ?? this.cabinId,
      cabinStockId: cabinStockId ?? this.cabinStockId,
      rfidTag: rfidTag ?? this.rfidTag,
      isActive: isActive ?? this.isActive,
      prescriptionItemId: prescriptionItemId ?? this.prescriptionItemId,
      cabinStock: cabinStock ?? this.cabinStock,
      prescriptionItem: prescriptionItem ?? this.prescriptionItem,
    );
  }
}
