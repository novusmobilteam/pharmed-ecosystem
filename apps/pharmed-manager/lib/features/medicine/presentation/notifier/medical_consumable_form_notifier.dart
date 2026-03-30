import 'package:flutter/material.dart' hide MaterialType;

import '../../../../core/core.dart';

class MedicalConsumableFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateMedicineUseCase _createMedicineUseCase;
  final UpdateMedicineUseCase _updateMedicineUseCase;

  MedicalConsumableFormNotifier({
    required CreateMedicineUseCase createMedicineUseCase,
    required UpdateMedicineUseCase updateMedicineUseCase,
    MedicalConsumable? medicalConsumable,
  }) : _createMedicineUseCase = createMedicineUseCase,
       _updateMedicineUseCase = updateMedicineUseCase,
       _medicalConsumable = medicalConsumable ?? MedicalConsumable();

  MedicalConsumable _medicalConsumable;

  OperationKey submitOp = OperationKey.submit();

  MedicalConsumable get mc => _medicalConsumable;

  bool get isSubmitting => isLoading(submitOp);
  bool get isCreate => _medicalConsumable.id == null;

  // Functions
  Future<void> submit({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    await executeVoid(
      submitOp,
      operation: () async {
        final result = isCreate
            ? await _createMedicineUseCase.call(_medicalConsumable)
            : await _updateMedicineUseCase.call(_medicalConsumable);

        return result;
      },
      successMessage: isCreate ? 'Tıbbi sarf oluşturuldu' : 'Tıbbi sarf güncellendi',
    );
  }

  void updateName(String? value) {
    _medicalConsumable = _medicalConsumable.copyWith(name: value);
    notifyListeners();
  }

  void updateBarcode(String? value) {
    _medicalConsumable = _medicalConsumable.copyWith(barcode: value);
    notifyListeners();
  }

  void updateInstitutionCode(String? value) {
    _medicalConsumable = _medicalConsumable.copyWith(institutionCode: int.tryParse(value ?? ''));
    notifyListeners();
  }

  void updateSutCode(String? value) {
    _medicalConsumable = _medicalConsumable.copyWith(sutCode: int.tryParse(value ?? ''));
    notifyListeners();
  }

  void updateUbbCode(String? value) {
    _medicalConsumable = _medicalConsumable.copyWith(ubbCode: int.tryParse(value ?? ''));
    notifyListeners();
  }

  void updateMaterialType(MaterialType? value) {
    _medicalConsumable = _medicalConsumable.copyWith(materialType: value);
    notifyListeners();
  }

  void updateFirm(Firm? value) {
    _medicalConsumable = _medicalConsumable.copyWith(firm: value);
    notifyListeners();
  }

  void updateCountType(CountType? value) {
    _medicalConsumable = _medicalConsumable.copyWith(countType: value);
    notifyListeners();
  }

  void updateDailyUsage(String? value) {
    _medicalConsumable = _medicalConsumable.copyWith(dailyMaxUsage: int.tryParse(value ?? ''));
    notifyListeners();
  }

  void updatePurchaseType(PurchaseType? value) {
    _medicalConsumable = _medicalConsumable.copyWith(purchaseType: value);
    notifyListeners();
  }

  void updateReturnType(ReturnType? value) {
    _medicalConsumable = _medicalConsumable.copyWith(returnType: value);
    notifyListeners();
  }

  void updateCollectNote(String? value) {
    _medicalConsumable = _medicalConsumable.copyWith(collectNote: value);
    notifyListeners();
  }

  void updateReturnNote(String? value) {
    _medicalConsumable = _medicalConsumable.copyWith(returnNote: value);
    notifyListeners();
  }

  void updateDestructionNote(String? value) {
    _medicalConsumable = _medicalConsumable.copyWith(destructionNote: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _medicalConsumable = _medicalConsumable.copyWith(status: value);
    notifyListeners();
  }
}
