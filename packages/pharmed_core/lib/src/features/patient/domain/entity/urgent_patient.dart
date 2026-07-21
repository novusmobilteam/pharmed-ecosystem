import 'package:pharmed_core/pharmed_core.dart';

class UrgentPatient {
  final int? id;
  final int? code;
  final int? patientId;
  final Patient? patient;
  final List<PrescriptionItem>? prescriptionItems;
  final DateTime? admissionDate;

  UrgentPatient({this.id, this.code, this.patientId, this.patient, this.prescriptionItems, this.admissionDate});
}
