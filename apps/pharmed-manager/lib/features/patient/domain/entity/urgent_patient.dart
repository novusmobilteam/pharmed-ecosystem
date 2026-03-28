import '../../../../core/core.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import 'patient.dart';

class UrgentPatient extends TableData {
  final int? id;
  final int? code;
  final int? patientId;
  final Patient? patient;
  final List<PrescriptionItem>? prescriptionItems;
  final DateTime? admissionDate;

  UrgentPatient({
    this.id,
    this.code,
    this.patientId,
    this.patient,
    this.prescriptionItems,
    this.admissionDate,
  });

  @override
  List<dynamic> get content => [patient, prescriptionItems];

  @override
  List<dynamic> get rawContent => [patient, prescriptionItems];

  @override
  List<String?> get titles => ['Hasta Bilgileri', 'İlaçlar'];
}
