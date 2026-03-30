import 'package:flutter/material.dart';

import '../../../../../../core/core.dart';

class DosageFormRegistrationNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateDosageFormUseCase _createDosageFormUseCase;
  final UpdateDosageFormUseCase _updateDosageFormUseCase;

  DosageFormRegistrationNotifier({
    required CreateDosageFormUseCase createDosageFormUseCase,
    required UpdateDosageFormUseCase updateDosageFormUseCase,
    DosageForm? dosageForm,
  }) : _createDosageFormUseCase = createDosageFormUseCase,
       _updateDosageFormUseCase = updateDosageFormUseCase,
       _dosageForm = dosageForm ?? DosageForm(isActive: true);

  DosageForm _dosageForm;
  DosageForm get dosageForm => _dosageForm;

  OperationKey submitOp = OperationKey.submit();

  bool get isCreate => _dosageForm.id == null;
  bool get isSubmitting => isLoading(submitOp);
  bool get isValid => _dosageForm.isValid;

  // Functions
  Future<void> submit({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    if (!isValid) return;

    await executeVoid(
      submitOp,
      operation: () =>
          isCreate ? _createDosageFormUseCase.call(_dosageForm) : _updateDosageFormUseCase.call(_dosageForm),
      onSuccess: () => onSuccess?.call('Dozaj formu başarıyla kaydedildi.'),
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  void updateName(String? value) {
    _dosageForm = _dosageForm.updateName(value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _dosageForm = _dosageForm.updateStatus(value);
    notifyListeners();
  }
}
