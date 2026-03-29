import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class ChangePasswordNotifier extends ChangeNotifier with ApiRequestMixin {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordNotifier({required ChangePasswordUseCase changePasswordUseCase})
    : _changePasswordUseCase = changePasswordUseCase;

  OperationKey submitOp = OperationKey.submit();

  bool _obscureCurrent = true;
  bool get obscureCurrent => _obscureCurrent;

  bool _obscureNew = true;
  bool get obscureNew => _obscureNew;

  String _currentPassword = '';
  String get currentPassword => _currentPassword;

  set currentPassword(String value) {
    _newPassword = value;
    notifyListeners(); // Bu çok önemli!
  }

  String _newPassword = '';
  String get newPassword => _newPassword;

  set newPassword(String value) {
    _newPassword = value;
    notifyListeners();
  }

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  Future<void> changePassword() async {
    if (currentPassword.isNotEmpty && newPassword.isNotEmpty) return;

    await executeVoid(
      submitOp,
      operation: () =>
          _changePasswordUseCase.call(ChangePasswordParams(currentPassword: currentPassword, newPassword: newPassword)),
    );
  }

  void toggleCurrent() {
    _obscureCurrent = !_obscureCurrent;
    notifyListeners();
  }

  void toggleNew() {
    _obscureNew = !_obscureNew;
    notifyListeners();
  }
}
