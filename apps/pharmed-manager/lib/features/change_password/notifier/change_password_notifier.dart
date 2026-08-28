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

  String _newPassword = '';
  String get newPassword => _newPassword;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  void changeCurrent(String value) {
    _currentPassword = value;
    notifyListeners();
  }

  void changeNew(String value) {
    _newPassword = value;
    notifyListeners();
  }

  Future<void> changePassword() async {
    if (_currentPassword.isEmpty && _newPassword.isEmpty) return;

    await executeVoid(
      submitOp,
      operation: () => _changePasswordUseCase.call(
        ChangePasswordParams(currentPassword: _currentPassword, newPassword: _newPassword),
      ),
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
