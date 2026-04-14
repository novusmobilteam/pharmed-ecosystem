import 'dart:ui';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class Hospitalization extends Selectable implements TableData {
  final int? code;
  final Patient? patient;
  final HospitalService? physicalService;
  final HospitalService? inpatientService;
  final User? doctor;
  final int? roomId;
  final int? bedId;
  final String? description;
  final DateTime? admissionDate;
  final DateTime? exitDate;
  final int? waitingQuantity;
  final DateTime? lastApproveDate;
  final bool? isBaby;
  final int? colorId;
  final bool isUrgent;

  Hospitalization({
    super.id,
    this.code,
    this.patient,
    this.physicalService,
    this.inpatientService,
    this.doctor,
    this.roomId,
    this.bedId,
    this.description,
    this.admissionDate,
    this.exitDate,
    this.waitingQuantity,
    this.lastApproveDate,
    this.isBaby,
    this.colorId,
    this.isUrgent = false,
  }) : super(title: patient?.fullName ?? '', subtitle: patient?.tcNo ?? '');

  Hospitalization copyWith({
    int? id,
    int? code,
    Patient? patient,
    HospitalService? physicalService,
    HospitalService? inpatientService,
    User? doctor,
    int? roomId,
    int? bedId,
    String? description,
    DateTime? admissionDate,
    DateTime? exitDate,
    bool? isBaby,
  }) {
    return Hospitalization(
      id: id ?? this.id,
      code: code ?? this.code,
      patient: patient ?? this.patient,
      physicalService: physicalService ?? this.physicalService,
      inpatientService: inpatientService ?? this.inpatientService,
      doctor: doctor ?? this.doctor,
      roomId: roomId ?? this.roomId,
      bedId: bedId ?? this.bedId,
      description: description ?? this.description,
      admissionDate: admissionDate ?? this.admissionDate,
      exitDate: exitDate ?? this.exitDate,
      isBaby: isBaby ?? this.isBaby,
    );
  }

  @override
  List get content => [
    physicalService?.name,
    patient?.protocolNo,
    patient?.tcNo,
    patient?.fullName,
    admissionDate?.formattedDate,
    waitingQuantity,
    lastApproveDate?.formattedDate,
  ];

  @override
  List get rawContent => [
    physicalService?.name,
    patient?.protocolNo,
    patient?.tcNo,
    patient?.fullName,
    admissionDate?.formattedDate,
    waitingQuantity,
    lastApproveDate?.formattedDate,
  ];

  @override
  List<String?> get titles => [
    'Servis',
    'Protokol No',
    'T.C No',
    'Hasta',
    'Yatış Tarihi',
    'Bekleyen Adet',
    'Son Onay Tarihi',
  ];

  // TODO : Düzelt
  Color get statusColor {
    switch (colorId) {
      // Lüzum Halinde
      case 1:
        return Color(0xFFF2A65A);
      // Lüzum Halinde + Normal
      case 2:
        return Color(0xFFE6501B);
      // Normal
      case 3:
        return Color(0xFF249E94);
      // Yönlendirilmiş Order
      case 4:
        return Color(0xFF2D3C59);
      default:
        return Color(0xFF2D3C59);
    }
  }
}
