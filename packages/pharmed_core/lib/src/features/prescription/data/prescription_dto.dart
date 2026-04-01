import 'package:pharmed_core/pharmed_core.dart';

class PrescriptionDTO {
  final int? id;
  final int? code;
  final String? name;
  final DateTime? prescriptionDate;
  final DateTime? hospitalizationDate;
  final bool? isPrescribed;
  final int? remainingCount;
  final int? hospitalizationId;
  final HospitalizationDTO? hospitalization;

  PrescriptionDTO({
    this.id,
    this.code,
    this.name,
    this.hospitalizationId,
    this.prescriptionDate,
    this.hospitalizationDate,
    this.isPrescribed,
    this.remainingCount,
    this.hospitalization,
  });

  factory PrescriptionDTO.fromJson(Map<String, dynamic> json) {
    return PrescriptionDTO(
      id: json['id'] as int?,
      code: json['code'] as int?,
      name: json['name'] as String?,
      hospitalizationId: json['patientHospitalizationId'] as int?,
      hospitalization: json['patientHospitalization'] != null
          ? HospitalizationDTO.fromJson(json['patientHospitalization'])
          : null,
      prescriptionDate: json['prescriptionDate'] != null ? DateTime.parse(json['prescriptionDate'] as String) : null,
      hospitalizationDate: json['hospitalizationDate'] != null
          ? DateTime.parse(json['hospitalizationDate'] as String)
          : null,
      isPrescribed: json['isPrescribed'] as bool?,
      remainingCount: json['remainingCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'patientHospitalizationId': hospitalizationId,
      'name': name ?? "",
      'prescriptionDate': prescriptionDate?.toIso8601String(),
    };
  }

  PrescriptionDTO copyWith({int? id, int? code, int? hospitalizationId, String? name, DateTime? prescriptionDate}) {
    return PrescriptionDTO(
      id: id ?? this.id,
      code: code ?? this.code,
      hospitalizationId: hospitalizationId ?? this.hospitalizationId,
      name: name ?? this.name,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
    );
  }
}
