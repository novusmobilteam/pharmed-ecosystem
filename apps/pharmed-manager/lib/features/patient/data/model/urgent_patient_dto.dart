import '../../../prescription/data/model/prescription_item_dto.dart';
import '../../domain/entity/urgent_patient.dart';
import 'patient_dto.dart';

class UrgentPatientDTO {
  final int? id;
  final int? code;
  final int? patientId;
  final PatientDTO? patient;
  final List<PrescriptionItemDTO>? prescriptionItems;
  final DateTime? admissionDate;

  UrgentPatientDTO({
    this.id,
    this.code,
    this.patientId,
    this.patient,
    this.prescriptionItems,
    this.admissionDate,
  });

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

  UrgentPatient toEntity() {
    return UrgentPatient(
      id: id,
      code: code,
      patientId: patientId,
      patient: patient?.toEntity(),
      prescriptionItems: prescriptionItems?.map((p) => p.toEntity()).toList(),
      admissionDate: admissionDate,
    );
  }
}
