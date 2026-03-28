import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/storage/auth/auth.dart';
import '../../../../core/utils/device_info.dart';
import '../../../user/user.dart';

class LoginNotifier extends ChangeNotifier with ApiRequestMixin {
  final LoginUseCase _loginUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthStorageNotifier _authStorage;

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
    required AuthStorageNotifier authStorageNotifier,
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
            await _authStorage.clearAuth();

            return Result.error(error);
          },
          ok: (tokenData) async {
            // 2. Login başarılıysa Kullanıcı Bilgilerini Getir
            final userResult = await _getCurrentUserUseCase();

            return userResult.when(
              ok: (userData) => const Result.ok(null),
              error: (error) {
                _authStorage.clearAuth();
                return Result.error(error);
              },
            );
          },
        );
      },
    );
  }
}
