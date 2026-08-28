import 'package:pharmed_core/pharmed_core.dart';

class UpcomingTreatmentDto {
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
  final List<TreatmentDetailDto>? details;

  UpcomingTreatmentDto({
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

  factory UpcomingTreatmentDto.fromJson(Map<String, dynamic> json) {
    return UpcomingTreatmentDto(
      patientHospitalizationId: json['patientHospitalizationId'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      patientSurname: json['patientSurname'],
      patientFullName: json['patientFullName'],
      patientCode: json['patientCode'],
      hospitalizationCode: json['hospitalizationCode'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      roomName: json['roomName'],
      bedName: json['bedName'],
      treatmentCount: json['treatmentCount'],
      prescriptionCount: json['prescriptionCount'],
      firstTreatmentTime: json['firstTreatmentTime'] != null ? DateTime.tryParse(json['firstTreatmentTime']) : null,

      lastTreatmentTime: json['lastTreatmentTime'] != null ? DateTime.tryParse(json['lastTreatmentTime']) : null,

      details: json['prescriptions'] != null
          ? (json['prescriptions'] as List).map((e) => TreatmentDetailDto.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }
}

class TreatmentDetailDto {
  final int? prescriptionDetailId;
  final int? prescriptionId;
  final int? materialId;
  final String? materialName;
  final double? dosePiece;
  final DateTime? time;
  final MedicineDto? medicine;

  TreatmentDetailDto({
    this.prescriptionDetailId,
    this.prescriptionId,
    this.materialId,
    this.materialName,
    this.dosePiece,
    this.time,
    this.medicine,
  });

  factory TreatmentDetailDto.fromJson(Map<String, dynamic> json) {
    return TreatmentDetailDto(
      prescriptionDetailId: json['prescriptionDetailId'],
      prescriptionId: json['prescriptionId'],
      materialId: json['materialId'],
      materialName: json['materialName'],
      dosePiece: json['dosePiece'],
      time: json['time'] != null ? DateTime.tryParse(json['time']) : null,
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material']) : null,
    );
  }
}
