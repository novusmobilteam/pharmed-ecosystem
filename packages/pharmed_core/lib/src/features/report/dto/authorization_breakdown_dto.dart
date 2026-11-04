import 'package:pharmed_core/pharmed_core.dart';

/// GET /Report/authorizationBreakdownList → liste elemanı.
class AuthorizationBreakdownDto {
  final int? id;
  final int? prescriptionDetailId;
  final String? patientFullName;
  final int? materialId;
  final MedicineDto? material;
  final String? materialName;
  final double? quantity;
  final DateTime? applicationDate;
  final int? userId;
  final String? userFullName;
  final int? stationId;
  final String? stationName;
  final bool? isOrderlessCollect;
  final bool? isFreeAccessCollect;

  const AuthorizationBreakdownDto({
    this.id,
    this.prescriptionDetailId,
    this.patientFullName,
    this.materialId,
    this.material,
    this.materialName,
    this.quantity,
    this.applicationDate,
    this.userId,
    this.userFullName,
    this.stationId,
    this.stationName,
    this.isOrderlessCollect,
    this.isFreeAccessCollect,
  });

  factory AuthorizationBreakdownDto.fromJson(Map<String, dynamic> json) {
    return AuthorizationBreakdownDto(
      id: json['id'] as int?,
      prescriptionDetailId: json['prescriptionDetailId'] as int?,
      patientFullName: json['patientFullName'] as String?,
      materialId: json['materialId'] as int?,
      material: json['material'] is Map<String, dynamic>
          ? MedicineDto.fromJson(json['material'] as Map<String, dynamic>)
          : null,
      materialName: json['materialName'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      applicationDate: json['applicationDate'] != null ? DateTime.tryParse(json['applicationDate'] as String) : null,
      userId: json['userId'] as int?,
      userFullName: json['userFullName'] as String?,
      stationId: json['stationId'] as int?,
      stationName: json['stationName'] as String?,
      isOrderlessCollect: json['isOrderlessCollect'] as bool?,
      isFreeAccessCollect: json['isFreeAccessCollect'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (prescriptionDetailId != null) 'prescriptionDetailId': prescriptionDetailId,
      if (patientFullName != null) 'patientFullName': patientFullName,
      if (materialId != null) 'materialId': materialId,
      if (material != null) 'material': material!.toJson(),
      if (materialName != null) 'materialName': materialName,
      if (quantity != null) 'quantity': quantity,
      if (applicationDate != null) 'applicationDate': applicationDate!.toIso8601String(),
      if (userId != null) 'userId': userId,
      if (userFullName != null) 'userFullName': userFullName,
      if (stationId != null) 'stationId': stationId,
      if (stationName != null) 'stationName': stationName,
      if (isOrderlessCollect != null) 'isOrderlessCollect': isOrderlessCollect,
      if (isFreeAccessCollect != null) 'isFreeAccessCollect': isFreeAccessCollect,
    };
  }
}
