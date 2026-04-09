import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class WarningFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateWarningUseCase _createWarningUseCase;
  final UpdateWarningUseCase _updateWarningUseCase;

  WarningFormNotifier({
    required CreateWarningUseCase createWarningUseCase,
    required UpdateWarningUseCase updateWarningUseCase,
    Warning? warning,
  }) : _createWarningUseCase = createWarningUseCase,
       _updateWarningUseCase = updateWarningUseCase,
       _warning = warning ?? Warning(isActive: true, subject: WarningSubject.untimelyIntake);

  Warning _warning;
  Warning get warning => _warning;

  OperationKey submitOp = OperationKey.submit();

  bool get isCreate => _warning.id == null;
  bool get isValid => _warning.isValid;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    if (!isValid) return;

    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createWarningUseCase.call(_warning) : _updateWarningUseCase.call(_warning),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void updateSubject(WarningSubject? value) {
    _warning = _warning.updateSubject(value);
    notifyListeners();
  }

  void updateText(String? value) {
    _warning = _warning.updateText(value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _warning = _warning.updateStatus(value);
    notifyListeners();
  }
}
