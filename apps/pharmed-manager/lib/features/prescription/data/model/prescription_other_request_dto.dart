import '../../domain/entity/prescription_other_request.dart';

class PrescriptionOtherRequestDTO {
  final int? prescriptionId;
  final String? ansKbMonitoring;
  final String? diet;
  final String? liquidElectrolyte;
  final String? other;
  final bool? openAfter24;
  final bool? urineCollected24;
  final bool? dietDepartmentEvaluated;
  final bool? receiveTpn;

  const PrescriptionOtherRequestDTO({
    this.prescriptionId,
    this.ansKbMonitoring,
    this.diet,
    this.liquidElectrolyte,
    this.other,
    this.openAfter24,
    this.urineCollected24,
    this.dietDepartmentEvaluated,
    this.receiveTpn,
  });

  factory PrescriptionOtherRequestDTO.fromJson(Map<String, dynamic> json) {
    return PrescriptionOtherRequestDTO(
      prescriptionId: json['prescriptionId'] as int?,
      ansKbMonitoring: json['ansKbMonitoring'] as String?,
      diet: json['diet'] as String?,
      liquidElectrolyte: json['liquid_Electrolyte'] as String?, // API key
      other: json['other'] as String?,
      openAfter24: json['openAfter24'] as bool?,
      urineCollected24: json['urineCollected24'] as bool?,
      dietDepartmentEvaluated: json['dietDepartmentEvaluated'] as bool?,
      receiveTpn: json['receiveTpn'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescriptionId': prescriptionId,
      'ansKbMonitoring': ansKbMonitoring,
      'diet': diet,
      'liquid_Electrolyte': liquidElectrolyte, // API key
      'other': other,
      'openAfter24': openAfter24,
      'urineCollected24': urineCollected24,
      'dietDepartmentEvaluated': dietDepartmentEvaluated,
      'receiveTpn': receiveTpn,
    };
  }

  PrescriptionOtherRequestDTO copyWith({
    int? prescriptionId,
    String? ansKbMonitoring,
    String? diet,
    String? liquidElectrolyte,
    String? other,
    bool? openAfter24,
    bool? urineCollected24,
    bool? dietDepartmentEvaluated,
    bool? receiveTpn,
  }) {
    return PrescriptionOtherRequestDTO(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      ansKbMonitoring: ansKbMonitoring ?? this.ansKbMonitoring,
      diet: diet ?? this.diet,
      liquidElectrolyte: liquidElectrolyte ?? this.liquidElectrolyte,
      other: other ?? this.other,
      openAfter24: openAfter24 ?? this.openAfter24,
      urineCollected24: urineCollected24 ?? this.urineCollected24,
      dietDepartmentEvaluated: dietDepartmentEvaluated ?? this.dietDepartmentEvaluated,
      receiveTpn: receiveTpn ?? this.receiveTpn,
    );
  }

  PrescriptionOtherRequest toEntity() {
    return PrescriptionOtherRequest(
      prescriptionId: prescriptionId,
      ansKbMonitoring: ansKbMonitoring,
      diet: diet,
      liquidElectrolyte: liquidElectrolyte,
      other: other,
      openAfter24: openAfter24 ?? false,
      urineCollected24: urineCollected24 ?? false,
      dietDepartmentEvaluated: dietDepartmentEvaluated ?? false,
      receiveTpn: receiveTpn ?? false,
    );
  }

  /// Mock factory for test data generation
  static PrescriptionOtherRequestDTO mockFactory(int id) {
    return PrescriptionOtherRequestDTO(
      prescriptionId: id,
      ansKbMonitoring: 'ANS/KB Takibi $id',
      diet: 'Diyet $id',
      liquidElectrolyte: 'Sıvı Elektrolit $id',
      other: 'Diğer $id',
      openAfter24: false,
      urineCollected24: false,
      dietDepartmentEvaluated: true,
      receiveTpn: false,
    );
  }
}
