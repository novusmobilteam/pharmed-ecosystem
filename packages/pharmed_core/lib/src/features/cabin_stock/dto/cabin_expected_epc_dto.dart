import 'package:pharmed_core/pharmed_core.dart';

class CabinExpectedEpcDto {
  CabinExpectedEpcDto({
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
  final CabinStockDTO? cabinStock;
  final PrescriptionItemDto? prescriptionItem;

  factory CabinExpectedEpcDto.fromJson(Map<String, dynamic> json) {
    return CabinExpectedEpcDto(
      id: json['id'] as int,
      cabinId: json['cabinId'] as int,
      cabinStockId: json['cabinDrawrStockId'] as int,
      rfidTag: json['rfidCardTag'] as String,
      isActive: json['isActive'] as bool? ?? false,
      prescriptionItemId: json['prescriptionDetailId'] as int,
      cabinStock: json['cabinDrawrStock'] == null
          ? null
          : CabinStockDTO.fromJson(json['cabinDrawrStock'] as Map<String, dynamic>),
      prescriptionItem: json['prescriptionDetail'] == null
          ? null
          : PrescriptionItemDto.fromJson(json['prescriptionDetail'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cabinId': cabinId,
    'cabinDrawrStockId': cabinStockId,
    'rfidCardTag': rfidTag,
    'isActive': isActive,
    'prescriptionDetailId': prescriptionItemId,
    if (cabinStock != null) 'cabinDrawrStock': cabinStock!.toJson(),
    if (prescriptionItem != null) 'prescriptionDetail': prescriptionItem!.toJson(),
  };
}
