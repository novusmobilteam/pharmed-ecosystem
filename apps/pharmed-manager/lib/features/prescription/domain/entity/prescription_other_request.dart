import '../../data/model/prescription_other_request_dto.dart';

class PrescriptionOtherRequest {
  final int? prescriptionId;
  final String? ansKbMonitoring;
  final String? diet;
  final String? liquidElectrolyte;
  final String? other;

  // Bayraklar (nullable değil; entity tarafında default false)
  final bool openAfter24;
  final bool urineCollected24;
  final bool dietDepartmentEvaluated;
  final bool receiveTpn;

  const PrescriptionOtherRequest({
    this.prescriptionId,
    this.ansKbMonitoring,
    this.diet,
    this.liquidElectrolyte,
    this.other,
    this.openAfter24 = false,
    this.urineCollected24 = false,
    this.dietDepartmentEvaluated = false,
    this.receiveTpn = false,
  });

  PrescriptionOtherRequest copyWith({
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
    return PrescriptionOtherRequest(
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

  PrescriptionOtherRequestDTO toDTO() {
    return PrescriptionOtherRequestDTO(
      prescriptionId: prescriptionId,
      ansKbMonitoring: ansKbMonitoring,
      diet: diet,
      liquidElectrolyte: liquidElectrolyte,
      other: other,
      openAfter24: openAfter24,
      urineCollected24: urineCollected24,
      dietDepartmentEvaluated: dietDepartmentEvaluated,
      receiveTpn: receiveTpn,
    );
  }
}
