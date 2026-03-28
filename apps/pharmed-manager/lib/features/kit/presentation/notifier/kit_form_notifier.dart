import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

import '../../domain/entity/kit.dart';
import '../../domain/usecase/create_kit_usecase.dart';
import '../../domain/usecase/update_kit_usecase.dart';

class KitFormNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Kit> {
  final CreateKitUseCase _createKitUseCase;
  final UpdateKitUseCase _updateKitUseCase;

  KitFormNotifier({required CreateKitUseCase createKitUseCase, required UpdateKitUseCase updateKitUseCase, Kit? kit})
    : _createKitUseCase = createKitUseCase,
      _updateKitUseCase = updateKitUseCase,
      _kit = kit ?? Kit(isActive: true);

  Kit _kit;
  Kit get kit => _kit;

  bool get isCreate => _kit.id == null;

  OperationKey submitOp = OperationKey.submit();

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createKitUseCase.call(_kit) : _updateKitUseCase.call(_kit),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void updateName(String? value) {
    _kit = _kit.copyWith(name: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _kit = _kit.copyWith(isActive: value?.isActive);
    notifyListeners();
  }
}
