import '../../../../../pharmed_core.dart';

class UpcomingTreatment {
  final int? patientHospitalizationId;
  final int? patientId;
  final String? patientName;
  final String? patientSurname;
  final String? patientFullName;
  final String? patientCode;
  final int? hospitalizationCode;
  final int? serviceId;
  final String? serviceName;
  final String? roomName;
  final String? bedName;
  final int? treatmentCount;
  final int? prescriptionCount;
  final DateTime? firstTreatmentTime;
  final DateTime? lastTreatmentTime;
  final List<TreatmentDetail>? details;

  bool get isDelayed => firstTreatmentTime?.isBefore(DateTime.now()) ?? false;
  int get delayTime => DateTime.now().difference(firstTreatmentTime ?? DateTime.now()).inMinutes;

  UpcomingTreatment({
    this.patientHospitalizationId,
    this.patientId,
    this.patientName,
    this.patientSurname,
    this.patientFullName,
    this.patientCode,
    this.hospitalizationCode,
    this.serviceId,
    this.serviceName,
    this.roomName,
    this.bedName,
    this.treatmentCount,
    this.prescriptionCount,
    this.firstTreatmentTime,
    this.lastTreatmentTime,
    this.details,
  });
}

class TreatmentDetail {
  final int? prescriptionDetailId;
  final int? prescriptionId;
  final int? materialId;
  final String? materialName;
  final double? dosePiece;
  final DateTime? time;
  final Medicine? medicine;

  TreatmentDetail({
    this.prescriptionDetailId,
    this.prescriptionId,
    this.materialId,
    this.materialName,
    this.dosePiece,
    this.time,
    this.medicine,
  });
}
