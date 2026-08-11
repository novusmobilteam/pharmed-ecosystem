// packages/pharmed_data/lib/src/unload/dto/return_drawer_medicine_dto.dart

import 'package:pharmed_core/pharmed_core.dart';

class ReturnDrawerMedicineDTO {
  const ReturnDrawerMedicineDTO({
    this.id,
    this.prescriptionItemId,
    this.prescriptionItem,
    this.materialId,
    this.material,
    this.quantity,
    this.returnUserId,
    this.returnUser,
    this.returnDate,
  });

  final int? id;
  final int? prescriptionItemId;
  final PrescriptionItemDto? prescriptionItem;
  final int? materialId;
  final MedicineDto? material;
  final double? quantity;
  final int? returnUserId;
  final UserDto? returnUser;
  final String? returnDate;

  factory ReturnDrawerMedicineDTO.fromJson(Map<String, dynamic> json) {
    return ReturnDrawerMedicineDTO(
      id: json['id'] as int?,
      prescriptionItemId: json['prescriptionDetailId'] as int?,
      prescriptionItem: json['prescriptionDetail'] == null
          ? null
          : PrescriptionItemDto.fromJson(json['prescriptionDetail'] as Map<String, dynamic>),
      materialId: json['materialId'] as int?,
      material: json['material'] == null ? null : MedicineDto.fromJson(json['material'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toDouble(),
      returnUserId: json['returnUserId'] as int?,
      returnUser: json['returnUser'] == null ? null : UserDto.fromJson(json['returnUser'] as Map<String, dynamic>),
      returnDate: json['returnDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'prescriptionDetailId': prescriptionItemId,
    'prescriptionDetail': prescriptionItem?.toJson(),
    'materialId': materialId,
    'material': material?.toJson(),
    'quantity': quantity,
    'returnUserId': returnUserId,
    'returnUser': returnUser?.toJson(),
    'returnDate': returnDate,
  };
}
