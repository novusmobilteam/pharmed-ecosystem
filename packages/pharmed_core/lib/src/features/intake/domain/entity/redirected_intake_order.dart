import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';

class RedirectedIntakeOrder extends Equatable {
  const RedirectedIntakeOrder({
    required this.id,
    this.prescriptionDetailId,
    this.dosePiece,
    this.time,
    this.firstDoseEmergency = false,
    this.askDoctor = false,
    this.inCaseOfNecessity = false,
    this.medicine,
    this.hospitalization,
    this.sendStationName,
    this.sendServiceName,
    this.sendUserName,
    this.receiveDate,
    this.isCancel = false,
    this.stocks = const [],
    this.prescriptionItem,
    this.isEquivalent = false,
  });

  final int id; // check/complete'e giden id
  final int? prescriptionDetailId;
  final double? dosePiece;
  final DateTime? time;
  final bool firstDoseEmergency;
  final bool askDoctor;
  final bool inCaseOfNecessity;
  final Medicine? medicine;
  final Hospitalization? hospitalization;
  final String? sendStationName;
  final String? sendServiceName;
  final String? sendUserName;
  final DateTime? receiveDate;
  final bool isCancel;
  final List<CabinStock> stocks;
  final PrescriptionItem? prescriptionItem;
  final bool isEquivalent;

  bool get isPending => receiveDate == null && !isCancel;

  /// Mevcut intake pipeline'ına (check/complete-Redirected hariç) sokabilmek
  /// için IntakeItem'a çevirir — assignment burada VERİLMEZ (stocks'tan
  /// _buildRedirectedTarget çözer), doz/hasta/prescriptionItem bağlamı taşınır.
  IntakeItem toIntakeItem() => IntakeItem(
    id: id,
    type: IntakeType.ordered,
    medicine: medicine,
    dosePiece: dosePiece,
    prescriptionDose: dosePiece,
    firstDoseEmergency: firstDoseEmergency,
    askDoctor: askDoctor,
    inCaseOfNecessity: inCaseOfNecessity,
    redirectedOrder: this,
  );

  @override
  List<Object?> get props => [
    id,
    prescriptionDetailId,
    dosePiece,
    time,
    medicine,
    hospitalization,
    sendStationName,
    sendServiceName,
    sendUserName,
    receiveDate,
    isCancel,
    stocks,
  ];
}
