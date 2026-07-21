import 'package:pharmed_core/pharmed_core.dart';

class Hospitalization extends Selectable {
  final int? code;
  final Patient? patient;
  final int? physicalServiceId;
  final HospitalService? physicalService;
  final int? inpatientServiceId;
  final HospitalService? inpatientService;
  final User? doctor;
  final Room? room;
  final int? roomId;
  final Bed? bed;
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
    this.physicalServiceId,
    this.physicalService,
    this.inpatientServiceId,

    this.inpatientService,
    this.doctor,
    this.room,
    this.roomId,
    this.bed,
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
    Room? room,
    int? roomId,
    Bed? bed,
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
      room: room ?? this.room,
      roomId: roomId ?? this.roomId,
      bed: bed ?? this.bed,
      bedId: bedId ?? this.bedId,
      description: description ?? this.description,
      admissionDate: admissionDate ?? this.admissionDate,
      exitDate: exitDate ?? this.exitDate,
      isBaby: isBaby ?? this.isBaby,
    );
  }
}
