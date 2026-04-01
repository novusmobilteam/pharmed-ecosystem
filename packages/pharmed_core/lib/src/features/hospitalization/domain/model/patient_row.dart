import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Patient ve (opsiyonel) PatientHospitalization birleşmiş satır modeli
/// TableData için kullanılır
class PatientHospitalizationRow extends Selectable implements TableData {
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

  @override
  List<String> get titles => const ['Servis', 'Hasta T.C', 'Ad Soyad', 'Yatış Tarihi', 'Çıkış Tarihi'];

  @override
  List<String?> get content {
    final h = hospitalization;
    final p = patient;
    final identity = p.tcNo;
    final service = inpatientService?.name;
    final admissionDate = h?.admissionDate != null ? Formatter.dateFormatter.format(h!.admissionDate!) : '-';
    final exitDate = h?.exitDate != null ? Formatter.dateFormatter.format(h!.exitDate!) : '-';

    return [service, identity, patient.fullName, admissionDate, exitDate];
  }

  @override
  List get rawContent => [
    inpatientService?.name,
    patient.tcNo,
    patient.fullName,
    hospitalization?.admissionDate,
    hospitalization?.exitDate,
  ];

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
