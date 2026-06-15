import 'package:pharmed_core/pharmed_core.dart';

class MedicineIntakeItemDto {
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

  final HospitalizationDto? hospitalization;
  final MedicineDto? medicine;
  final PrescriptionDto? prescription;
  final MedicineAssignmentDto? cabinAssignment;
  final CabinStockDTO? cabinDrawerStock;
  final PrescriptionItemMovementDto? lastMovement;

  MedicineIntakeItemDto({
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
    this.prescription,
    this.cabinAssignment,
    this.cabinDrawerStock,
    this.firstDoseEmergency,
    this.askDoctor,
    this.inCaseOfNecessity,
    this.lastMovement,
  });

  factory MedicineIntakeItemDto.fromJson(Map<String, dynamic> json) {
    return MedicineIntakeItemDto(
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
      hospitalization: json['patientHospitalization'] != null
          ? HospitalizationDto.fromJson(json['patientHospitalization'])
          : null,
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material']) : null,
      prescription: json['prescription'] != null ? PrescriptionDto.fromJson(json['prescription']) : null,
      cabinAssignment: json['cabinDrawrQuantity'] != null
          ? MedicineAssignmentDto.fromJson(json['cabinDrawrQuantity'])
          : null,
      cabinDrawerStock: json['cabinDrawrStock'] != null ? CabinStockDTO.fromJson(json['cabinDrawrStock']) : null,
      lastMovement: json['lastMovement'] != null ? PrescriptionItemMovementDto.fromJson(json['lastMovement']) : null,
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

  MedicineIntakeItemDto copyWith({int? id}) {
    return MedicineIntakeItemDto(id: id ?? this.id);
  }
}
