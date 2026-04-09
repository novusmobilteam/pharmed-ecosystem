import 'package:flutter/material.dart';

import '../../../core/core.dart';

class FirmFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateFirmUseCase _createFirmUseCase;
  final UpdateFirmUseCase _updateFirmUseCase;
  Firm _firm;

  FirmFormNotifier({
    required CreateFirmUseCase createFirmUseCase,
    required UpdateFirmUseCase updateFirmUseCase,
    Firm? firm,
  }) : _createFirmUseCase = createFirmUseCase,
       _updateFirmUseCase = updateFirmUseCase,
       _firm = firm ?? Firm();

  OperationKey submitOp = OperationKey.create();

  Firm get firm => _firm;
  bool get isCreate => _firm.id == null;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  void updateName(String? value) {
    _firm = _firm.copyWith(name: value);
    notifyListeners();
  }

  void updateTaxOffice(String? value) {
    _firm = _firm.copyWith(taxOffice: value);
    notifyListeners();
  }

  void updateTaxNo(String? value) {
    // Entity'de taxNo int ise int.tryParse, String ise doğrudan atama
    final taxNo = int.tryParse(value ?? '');
    _firm = _firm.copyWith(taxNo: taxNo);
    notifyListeners();
  }

  void updateFirmType(FirmType? value) {
    _firm = _firm.copyWith(type: value);
    notifyListeners();
  }

  Future<void> submit() async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createFirmUseCase.call(_firm) : _updateFirmUseCase.call(_firm),
      onSuccess: () {
        if (isCreate) resetForm();
      },
      successMessage: 'Firma başarıyla ${isCreate ? 'oluşturuldu' : 'güncellendi'}',
    );
  }

  void resetForm() {
    _firm = Firm();
    notifyListeners();
  }
}
