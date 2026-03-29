import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/utils/device_info.dart';

class LoginNotifier extends ChangeNotifier with ApiRequestMixin {
  final LoginUseCase _loginUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthManagerNotifier _authStorage;

  // Operation Keys
  static const loginOperation = OperationKey.custom('login');

  // State Variables
  String? _email;
  String? get email => _email;

  String? _password;
  String? get password => _password;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  LoginNotifier({
    required LoginUseCase loginUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthManagerNotifier authStorageNotifier,
  }) : _loginUseCase = loginUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _authStorage = authStorageNotifier;

  void onEmailChanged(String value) {
    _email = value;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    _password = value;
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> login() async {
    if (_email == null || _password == null) return;

    executeVoid(
      loginOperation,
      operation: () async {
        final macAddress = await DeviceInfo.getMacAddress();

        final params = LoginParams(email: _email!, password: _password!, macAddress: macAddress);

        final loginResult = await _loginUseCase(params);
        return await loginResult.when(
          error: (error) async {
            await _authStorage.logout();

            return Result.error(error);
          },
          ok: (tokenData) async {
            // 2. Login başarılıysa Kullanıcı Bilgilerini Getir
            final userResult = await _getCurrentUserUseCase();

            return userResult.when(
              ok: (userData) => const Result.ok(null),
              error: (error) {
                _authStorage.logout();
                return Result.error(error);
              },
            );
          },
        );
      },
    );
  }
}
