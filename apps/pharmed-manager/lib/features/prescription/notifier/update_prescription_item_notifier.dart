import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class UpdatePrescriptionItemNotifier extends ChangeNotifier with ApiRequestMixin {
  final UpdatePrescriptionItemUseCase _updatePrescriptionItemUseCase;
  PrescriptionItem _prescriptionItem;

  UpdatePrescriptionItemNotifier({
    required UpdatePrescriptionItemUseCase updatePrescriptionItemUseCase,
    required PrescriptionItem initial,
  }) : _updatePrescriptionItemUseCase = updatePrescriptionItemUseCase,
       _prescriptionItem = initial;

  PrescriptionItem get prescriptionItem => _prescriptionItem;

  OperationKey submitOp = OperationKey.submit();

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  Future<void> submit() async {
    await executeVoid(submitOp, operation: () => _updatePrescriptionItemUseCase.call(_prescriptionItem));
  }

  /// [Doz]
  void updateDose(String? value) {
    _prescriptionItem = _prescriptionItem.copyWith(dosePiece: double.tryParse(value ?? ''));
    notifyListeners();
  }

  /// [İlk Doz Acil]
  void toggleEmergency() {
    _prescriptionItem = _prescriptionItem.copyWith(
      firstDoseEmergency: !(_prescriptionItem.firstDoseEmergency ?? false),
    );
    notifyListeners();
  }

  /// [Doktora Sor]
  void toggleAskDoctor() {
    _prescriptionItem = _prescriptionItem.copyWith(askDoctor: !(_prescriptionItem.askDoctor ?? false));
    notifyListeners();
  }

  /// [Lüzumu Halinde]
  void toggleNecessity() {
    _prescriptionItem = _prescriptionItem.copyWith(inCaseOfNecessity: !(_prescriptionItem.inCaseOfNecessity ?? false));
    notifyListeners();
  }

  /// [Saat]
  void updateTime(TimeOfDay? value) {
    if (value == null) return;
    final now = DateTime.now();
    final time = DateTime(now.year, now.month, now.day, value.hour, value.minute);

    _prescriptionItem = _prescriptionItem.copyWith(time: time);

    notifyListeners();
  }

  /// [Uygulama Tarihi]
  void updateDate(DateTime value) {
    _prescriptionItem = _prescriptionItem.copyWith(applicationDate: value);

    notifyListeners();
  }

  /// [Uygulama Saati]
  void updateApplicationTime(TimeOfDay? value) {
    if (value == null) return;

    final DateTime date = _prescriptionItem.applicationDate ?? DateTime.now();
    final time = DateTime(date.year, date.month, date.day, value.hour, value.minute);

    _prescriptionItem = _prescriptionItem.copyWith(applicationDate: time);

    notifyListeners();
  }

  /// [Açıklama]
  void updateDescription(String? value) {
    _prescriptionItem = _prescriptionItem.copyWith(description: value);
    notifyListeners();
  }
}
