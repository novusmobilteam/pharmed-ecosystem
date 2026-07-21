import 'package:pharmed_core/pharmed_core.dart';

/// Patient ve (opsiyonel) PatientHospitalization birleşmiş satır modeli
/// TableData için kullanılır
class PatientHospitalizationRow extends Selectable {
  final Patient patient;
  final Hospitalization? hospitalization;
  final HospitalService? physicalService;
  final HospitalService? inpatientService;
  final User? doctor;

  PatientHospitalizationRow({
    super.id,
    required this.patient,
    required this.hospitalization,
    this.physicalService,
    this.inpatientService,
    this.doctor,
  }) : super(title: patient.fullName, subtitle: physicalService?.name);

  PatientHospitalizationRow copyWith({
    Patient? patient,
    Hospitalization? hospitalization,
    HospitalService? physicalService,
    HospitalService? inpatientService,
    User? doctor,
  }) {
    return PatientHospitalizationRow(
      patient: patient ?? this.patient,
      hospitalization: hospitalization ?? this.hospitalization,
      physicalService: physicalService ?? this.physicalService,
      inpatientService: inpatientService ?? this.inpatientService,
      doctor: doctor ?? this.doctor,
    );
  }

  Patient toPatient() => patient;
}
