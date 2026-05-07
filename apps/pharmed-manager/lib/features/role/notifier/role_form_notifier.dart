import 'package:flutter/material.dart';

import '../../../core/core.dart';

class RoleFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateRoleUseCase _createRoleUseCase;
  final UpdateRoleUseCase _updateRoleUseCase;

  Role _role;

  RoleFormNotifier({
    required CreateRoleUseCase createRoleUseCase,
    required UpdateRoleUseCase updateRoleUseCase,
    Role? role,
  }) : _createRoleUseCase = createRoleUseCase,
       _updateRoleUseCase = updateRoleUseCase,
       _role = role ?? Role(isActive: true);

  OperationKey submitOp = OperationKey(OperationType.create);

  Role get role => _role;
  bool get isCreate => _role.id == null;
  bool get isValid => _role.isValid;
  String? get statusMessage => message(submitOp);

  void updateName(String? value) {
    _role = _role.updateName(value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _role = _role.updateStatus(value);
    notifyListeners();
  }

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    if (!isValid) return;

    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createRoleUseCase.call(_role) : _updateRoleUseCase(_role),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı'),
    );
  }
}
