// [SWREQ-CORE-CABIN-ITEM-001-DTO] [IEC 62304 §5.5]
//
// PrescriptionDetail servis kaydının, CabinTargetedPrescriptionItem'ın
// ihtiyaç duyduğu alt kümesi — servis JSON'unu (alım/iade endpoint'leri)
// birebir yansıtır. Tüm alanlar nullable: servis eksik/null dönebilir,
// null-safety kararı mapper'da (entity'ye çevrilirken) verilir.
//
// JSON kaynağı: prescriptionDetail satırı. `cabinAssignment` alanı JSON'daki
// `cabinDrawrQuantity`'den, `cabinDrawerStock` alanı `cabinDrawrStock`'tan
// gelir — isimler kasıtlı olarak JSON'daki ham adlardan farklı, servis
// tarafının "quantity" ile kastettiği şey aslında çekmece/göz ADRESİ.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CabinTargetedPrescriptionItemDto {
  const CabinTargetedPrescriptionItemDto({
    this.id,
    this.prescriptionId,
    this.dosePiece,
    this.firstDoseEmergency,
    this.askDoctor,
    this.inCaseOfNecessity,
    this.time,
    this.hospitalization,
    this.medicine,
    this.cabinAssignment,
    this.cabinDrawerStock,
    this.lastMovement,
  });

  final int? id;
  final int? prescriptionId;
  final num? dosePiece;
  final bool? firstDoseEmergency;
  final bool? askDoctor;
  final bool? inCaseOfNecessity;

  /// Ham ISO8601 string — DateTime parse'ı mapper'da yapılır.
  final String? time;

  final HospitalizationDto? hospitalization;
  final MedicineDto? medicine;

  /// JSON: `cabinDrawrQuantity`.
  final MedicineAssignmentDto? cabinAssignment;

  /// JSON: `cabinDrawrStock`.
  final CabinStockDTO? cabinDrawerStock;

  final PrescriptionItemMovementDto? lastMovement;

  factory CabinTargetedPrescriptionItemDto.fromJson(Map<String, dynamic> json) {
    return CabinTargetedPrescriptionItemDto(
      id: json['id'] as int?,
      prescriptionId: json['prescriptionId'] as int?,
      dosePiece: json['dosePiece'] as num?,
      firstDoseEmergency: json['firstDoseEmergency'] as bool?,
      askDoctor: json['askDoctor'] as bool?,
      inCaseOfNecessity: json['inCaseOfNecessity'] as bool?,
      time: json['time'] as String?,
      hospitalization: json['patientHospitalization'] != null
          ? HospitalizationDto.fromJson(json['patientHospitalization'] as Map<String, dynamic>)
          : null,
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material'] as Map<String, dynamic>) : null,
      cabinAssignment: json['cabinDrawrQuantity'] != null
          ? MedicineAssignmentDto.fromJson(json['cabinDrawrQuantity'] as Map<String, dynamic>)
          : null,
      cabinDrawerStock: json['cabinDrawrStock'] != null
          ? CabinStockDTO.fromJson(json['cabinDrawrStock'] as Map<String, dynamic>)
          : null,
      lastMovement: json['lastMovement'] != null
          ? PrescriptionItemMovementDto.fromJson(json['lastMovement'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescriptionId': prescriptionId,
      'dosePiece': dosePiece,
      'firstDoseEmergency': firstDoseEmergency,
      'askDoctor': askDoctor,
      'inCaseOfNecessity': inCaseOfNecessity,
      'time': time,
      'patientHospitalization': hospitalization?.toJson(),
      'material': medicine?.toJson(),
      'cabinDrawrQuantity': cabinAssignment?.toJson(),
      'cabinDrawrStock': cabinDrawerStock?.toJson(),
    };
  }
}
