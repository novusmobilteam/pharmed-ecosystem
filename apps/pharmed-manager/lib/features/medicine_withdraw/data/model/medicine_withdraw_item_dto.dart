import 'package:pharmed_manager/core/core.dart';

import '../../../hospitalization/data/model/hospitalization_dto.dart';

import '../../../prescription/data/model/prescription_dto.dart';
import '../../domain/entity/medicine_withdraw_item.dart';

class MedicineWithdrawItemDTO {
  final int? id;
  final int? prescriptionId;
  final int? stationId;
  final int? hospitalizationId;
  final int? doctorId;
  final String? doctorName;
  final num? dosePiece;
  final String? time;
  final String? requestTypeName;
  final int? requestTypeId;
  final bool? firstDoseEmergency;
  final bool? askDoctor;
  final bool? inCaseOfNecessity;
  final DateTime? applicationDate;

  final HospitalizationDTO? hospitalization;
  final MedicineDTO? medicine;
  final UserDTO? approvalUser;
  final UserDTO? applicationUser;
  final PrescriptionDTO? prescription;
  final CabinAssignmentDTO? cabinAssignment;
  final CabinStockDTO? cabinDrawerStock;

  MedicineWithdrawItemDTO({
    this.id,
    this.prescriptionId,
    this.stationId,
    this.hospitalizationId,
    this.doctorId,
    this.doctorName,
    this.dosePiece,
    this.time,
    this.requestTypeName,
    this.requestTypeId,
    this.hospitalization,
    this.medicine,
    this.approvalUser,
    this.applicationUser,
    this.prescription,
    this.cabinAssignment,
    this.cabinDrawerStock,
    this.firstDoseEmergency,
    this.askDoctor,
    this.inCaseOfNecessity,
    this.applicationDate,
  });

  factory MedicineWithdrawItemDTO.fromJson(Map<String, dynamic> json) {
    return MedicineWithdrawItemDTO(
      id: json['id'],
      prescriptionId: json['prescriptionId'],
      stationId: json['stationId'],
      hospitalizationId: json['patientHospitalizationId'],
      doctorId: json['doctorId'],
      requestTypeId: json['requestType'],
      doctorName: json['doctor'],
      dosePiece: json['dosePiece'],
      time: json['time'],
      requestTypeName: json['requestTypeName'],
      firstDoseEmergency: json['firstDoseEmergency'],
      askDoctor: json['askDoctor'],
      inCaseOfNecessity: json['inCaseOfNecessity'],
      applicationDate: json['applicationDate'] != null ? DateTime.parse(json['applicationDate'] as String) : null,
      hospitalization: json['patientHospitalization'] != null
          ? HospitalizationDTO.fromJson(json['patientHospitalization'])
          : null,
      medicine: json['material'] != null ? MedicineDTO.fromJson(json['material']) : null,
      approvalUser: json['approvalUser'] != null ? UserDTO.fromJson(json['approvalUser']) : null,
      applicationUser: json['applicationUser'] != null ? UserDTO.fromJson(json['applicationUser']) : null,
      prescription: json['prescription'] != null ? PrescriptionDTO.fromJson(json['prescription']) : null,
      cabinAssignment: json['cabinDrawrQuantity'] != null
          ? CabinAssignmentDTO.fromJson(json['cabinDrawrQuantity'])
          : null,
      cabinDrawerStock: json['cabinDrawrStock'] != null ? CabinStockDTO.fromJson(json['cabinDrawrStock']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescriptionId': prescriptionId,
      'stationId': stationId,
      'hospitalizationId': hospitalizationId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'dosePiece': dosePiece,
      'time': time,
      'requestTypeName': requestTypeName,
      'requestTypeId': requestTypeId,
      'firstDoseEmergency': firstDoseEmergency,
      'askDoctor': askDoctor,
      'inCaseOfNecessity': inCaseOfNecessity,
    };
  }

  MedicineWithdrawItemDTO copyWith({int? id}) {
    return MedicineWithdrawItemDTO(id: id ?? this.id);
  }

  MedicineWithdrawItem toEntity() {
    final ass = cabinAssignment != null
        ? CabinAssignmentMapper().toEntity(cabinAssignment!)
        : CabinAssignment.empty(cabinId: 0, cabinDrawerId: 0);
    return MedicineWithdrawItem(
      id: id ?? 0,
      prescriptionId: prescriptionId ?? 0,
      medicineName: medicine?.toEntity().name ?? "Bilinmeyen İlaç",
      medicineBarcode: medicine?.toEntity().barcode ?? "",
      dosePiece: dosePiece ?? 0,
      medicine: medicine?.toEntity(),
      cabinAssignment: ass,
      time: DateTime.tryParse(time ?? ''),
      firstDoseEmergency: firstDoseEmergency ?? false,
      askDoctor: askDoctor ?? false,
      inCaseOfNecessity: inCaseOfNecessity ?? false,
      approvalUser: const UserMapper().toEntityOrNull(approvalUser),
      applicationUser: const UserMapper().toEntityOrNull(applicationUser),
      hospitalization: hospitalization?.toEntity(),
      applicationDate: applicationDate,
      stock: const CabinStockMapper().toEntityOrNull(cabinDrawerStock),
    );
  }
}
