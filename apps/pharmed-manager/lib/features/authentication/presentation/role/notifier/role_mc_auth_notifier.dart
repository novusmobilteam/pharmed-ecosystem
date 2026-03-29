import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../../domain/entity/role_medical_consumable_authentication.dart';
import '../../../domain/usecase/get_role_mc_authentication_usecase.dart';
import '../../../domain/usecase/save_role_mc_authentication_usecase.dart';

class RoleMcAuthNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetRoleMcAuthenticationUseCase _getAuthUseCase;
  final SaveRoleMcAuthenticationUseCase _saveAuthUseCase;
  final Role _role;

  RoleMcAuthNotifier({
    required GetRoleMcAuthenticationUseCase getAuthUseCase,
    required SaveRoleMcAuthenticationUseCase saveAuthUseCase,
    required Role role,
  }) : _getAuthUseCase = getAuthUseCase,
       _saveAuthUseCase = saveAuthUseCase,
       _role = role;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.update();

  RoleMedicalConsumableAuthentication? _roleAuth;
  RoleMedicalConsumableAuthentication? get roleAuth => _roleAuth;

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
