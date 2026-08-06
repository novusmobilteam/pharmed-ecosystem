import 'package:pharmed_core/pharmed_core.dart';

class UrgentPatientDTO {
  final int? id;
  final int? code;
  final int? patientId;
  final PatientDto? patient;
  final List<PrescriptionItemDto>? prescriptionItems;
  final DateTime? admissionDate;
  final ServiceDto? physicalService;
  final ServiceDto? inpatientService;

  UrgentPatientDTO({
    this.id,
    this.code,
    this.patientId,
    this.patient,
    this.prescriptionItems,
    this.admissionDate,
    this.physicalService,
    this.inpatientService,
  });

  factory UrgentPatientDTO.fromJson(Map<String, dynamic> json) {
    return UrgentPatientDTO(
      id: json['id'] as int?,
      code: json['code'] as int?,
      patientId: json['patientId'] as int?,
      patient: json['patient'] != null ? PatientDto.fromJson(json['patient']) : null,
      prescriptionItems: json['prescriptionDetailList'] != null
          ? (json['prescriptionDetailList'] as List)
                .map((e) => PrescriptionItemDto.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      admissionDate: json['admissionDate'] != null ? DateTime.tryParse(json['admissionDate']) : null,
      physicalService: json['physicalService'] != null ? ServiceDto.fromJson(json['physicalService']) : null,
      inpatientService: json['inpatientService'] != null ? ServiceDto.fromJson(json['inpatientService']) : null,
    );
  }
}
