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

  PrescriptionItemMovementDto({
    this.id,
    this.prescriptionItemId,
    this.movementId,
    this.cabinDrawerDetailId,
    this.createdAt,
    this.user,
    this.quantity,
    this.stationId,
  });

  factory PrescriptionItemMovementDto.fromJson(Map<String, dynamic> json) {
    return PrescriptionItemMovementDto(
      id: json['id'] as int?,
      prescriptionItemId: json['prescriptionDetailId'] as int?,
      movementId: json['transactionKind'] as int?,
      cabinDrawerDetailId: json['CabinDrawrDetailId'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdDate']) : null,
      user: json['user'] != null ? UserDto.fromJson(json['user']) : null,
      quantity: json['quantity'] as double?,
      stationId: json['stationId'] as int?,
    );
  }
}
