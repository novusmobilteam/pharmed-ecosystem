import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class RoleMcAuthNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetRoleMcAuthorizationUseCase _getAuthUseCase;
  final SaveRoleMcAuthorizationUseCase _saveAuthUseCase;
  final Role _role;

  RoleMcAuthNotifier({
    required GetRoleMcAuthorizationUseCase getAuthUseCase,
    required SaveRoleMcAuthorizationUseCase saveAuthUseCase,
    required Role role,
  }) : _getAuthUseCase = getAuthUseCase,
       _saveAuthUseCase = saveAuthUseCase,
       _role = role;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.update();

  RoleMedicalConsumableAuthorization? _roleAuth;
  RoleMedicalConsumableAuthorization? get roleAuth => _roleAuth;

  bool get isFetching => isLoading(fetchOp);
  bool get isSubmitting => isLoading(submitOp);

  Future<void> initialize() async {
    await execute(fetchOp, operation: () => _getAuthUseCase.call(_role), onData: (data) => _roleAuth = data);
  }

  Future<void> submit({Function(String? msg)? onSuccess, Function(String? msg)? onFailed}) async {
    if (_roleAuth == null) return;
    await executeVoid(
      submitOp,
      operation: () => _saveAuthUseCase.call(_roleAuth!),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        initialize();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  void toggleAuth(DrugOp op) {
    _roleAuth = _roleAuth?.toggle(op);
    notifyListeners();
  }
}
