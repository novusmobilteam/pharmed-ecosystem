import 'package:pharmed_core/pharmed_core.dart';

class UrgentPatientDTO {
  final int? id;
  final int? code;
  final int? patientId;
  final PatientDTO? patient;
  final List<PrescriptionItemDTO>? prescriptionItems;
  final DateTime? admissionDate;

  UrgentPatientDTO({this.id, this.code, this.patientId, this.patient, this.prescriptionItems, this.admissionDate});

  factory UrgentPatientDTO.fromJson(Map<String, dynamic> json) {
    return UrgentPatientDTO(
      id: json['id'] as int?,
      code: json['code'] as int?,
      patientId: json['patientId'] as int?,
      patient: json['patient'] != null ? PatientDTO.fromJson(json['patient']) : null,
      prescriptionItems: json['prescriptionDetailList'] != null
          ? (json['prescriptionDetailList'] as List)
                .map((e) => PrescriptionItemDTO.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      admissionDate: json['admissionDate'] != null ? DateTime.tryParse(json['admissionDate']) : null,
    );
  }
}
