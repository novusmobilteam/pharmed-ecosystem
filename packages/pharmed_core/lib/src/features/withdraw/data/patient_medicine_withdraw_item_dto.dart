import 'package:pharmed_core/pharmed_core.dart';

class PatientMedicineWithdrawItemDTO {
  final int? id;
  final int? hospitalizationId;
  final int? patientId;
  final int? cabinDrawerId;
  final DrawerUnitDTO? cabinDrawer;
  final int? compartmentNo;
  final String? medicineName;
  final String? barcode;
  final DateTime? time;
  final String? description;
  final int? dosePiece;
  final UserDTO? applicationUser;
  final DateTime? applicationDate;
  final HospitalizationDTO? hospitalization;
  final PatientDTO? patient;

  PatientMedicineWithdrawItemDTO({
    this.id,
    this.hospitalizationId,
    this.patientId,
    this.cabinDrawerId,
    this.cabinDrawer,
    this.compartmentNo,
    this.medicineName,
    this.barcode,
    this.time,
    this.description,
    this.dosePiece,
    this.applicationUser,
    this.applicationDate,
    this.hospitalization,
    this.patient,
  });

  factory PatientMedicineWithdrawItemDTO.fromJson(Map<String, dynamic> json) {
    return PatientMedicineWithdrawItemDTO(
      id: json['id'],
      hospitalizationId: json['hospitalizationId'],
      patientId: json['patientId'],
      cabinDrawerId: json['cabinDrawrId'],
      cabinDrawer: json['cabinDrawr'] != null ? DrawerUnitDTO.fromJson(json['cabinDrawr']) : null,
      compartmentNo: json['compartmentNo'],
      medicineName: json['materialName'],
      time: json['time'] != null ? DateTime.parse(json['time'] as String) : null,
      dosePiece: json['dosePiece'],
      description: json['description'],
      barcode: json['barcode'],
      applicationDate: json['applicationDate'] != null ? DateTime.parse(json['applicationDate'] as String) : null,
      applicationUser: json['applicationUser'] != null ? UserDTO.fromJson(json['applicationUser']) : null,
      // hospitalization:
      //     json['patientHospitalization'] != null ? HospitalizationDTO.fromJson(json['patientHospitalization']) : null,
      // user: json['user'] != null ? UserDTO.fromJson(json['json']) : null,
      // patient: json['patient'] != null ? PatientDTO.fromJson(json['patient']) : null,
    );
  }
}
