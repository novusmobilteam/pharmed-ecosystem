import 'package:pharmed_core/pharmed_core.dart';

class PrescriptionItemMovementDto {
  final int? id;
  final int? prescriptionItemId;
  final int? movementId;
  final int? cabinDrawerDetailId;
  final DateTime? createdAt;
  final UserDto? user;
  final double? quantity;
  final int? stationId;
  final PrescriptionItemDto? prescriptionItem;

  PrescriptionItemMovementDto({
    this.id,
    this.prescriptionItemId,
    this.movementId,
    this.cabinDrawerDetailId,
    this.createdAt,
    this.user,
    this.quantity,
    this.stationId,
    this.prescriptionItem,
  });

  factory PrescriptionItemMovementDto.fromJson(Map<String, dynamic> json) {
    return PrescriptionItemMovementDto(
      id: json['id'] as int?,
      prescriptionItemId: json['prescriptionDetailId'] as int?,
      movementId: json['detailStatusId'] as int?,
      cabinDrawerDetailId: json['CabinDrawrDetailId'] as int?,
      createdAt: json['createdDate'] != null ? DateTime.tryParse(json['createdDate']) : null,
      user: json['user'] != null ? UserDto.fromJson(json['user']) : null,
      quantity: json['quantity'] as double?,
      stationId: json['stationId'] as int?,
      prescriptionItem: json['prescriptionDetail'] != null
          ? PrescriptionItemDto.fromJson(json['prescriptionDetail'])
          : null,
    );
  }
}
