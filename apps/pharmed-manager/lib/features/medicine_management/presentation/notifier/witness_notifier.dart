import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/features/auth/presentation/notifier/auth_notifier.dart';

import '../../domain/entity/cabin_operation_item.dart';

/// Şahit doğrulama işlemlerini yöneten notifier.
/// Alım ve fire/imha işlemlerinde ortak kullanılır.
/// medicine_management/presentation/notifier/ altında yaşar.
class WitnessNotifier extends ChangeNotifier with ApiRequestMixin {
  final CabinOperationItem item;
  final WitnessUserLoginUseCase _loginUseCase;
  final AuthNotifier _authPersistence;

  WitnessNotifier({
    required this.item,
    required WitnessUserLoginUseCase loginUseCase,
    required AuthNotifier authPersistence,
  }) : _loginUseCase = loginUseCase,
       _authPersistence = authPersistence;

  OperationKey loginOp = OperationKey.custom('witness_login');

  /// Şahit girişi yapar ve doğrulama kontrollerini uygular.
  ///
  /// 1. Kendi kendine şahitlik kontrolü
  /// 2. İlaca özel şahit listesi kontrolü
  ///    - Liste boşsa herkes şahit olabilir
  ///    - Liste doluysa kullanıcı listede olmalı
  Future<void> loginWitness({
    required String username,
    required String password,
    Function(User user)? onSuccess,
    Function(String? error)? onFailed,
  }) async {
    await execute(
      loginOp,
      operation: () => _loginUseCase.call(WitnessUserLoginParams(email: username, password: password, macAddress: '')),
      onData: (user) {
        if (user == null) {
          onFailed?.call('Kullanıcı bilgilerine ulaşılamıyor. Lütfen tekrar deneyiniz.');
          return;
        }

        // Kendi kendine şahitlik kontrolü
        if (user.id == _authPersistence.currentUser?.id) {
          onFailed?.call('İşlemi yapan personel kendisi şahit olamaz.');
          return;
        }

        // İlaca özel şahit listesi kontrolü
        final allowed = item.witnesses;
        if (allowed.isNotEmpty && !allowed.any((a) => a.id == user.id)) {
          onFailed?.call('Bu kullanıcı bu ilaç için yetkili şahitler arasında yer almıyor.');
          return;
        }

        onSuccess?.call(user);
      },
      onFailed: (e) => onFailed?.call(e.message),
    );
  }
}
