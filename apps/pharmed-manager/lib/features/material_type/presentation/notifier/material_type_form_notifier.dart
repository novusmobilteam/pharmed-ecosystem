import 'package:flutter/material.dart' hide MaterialType;

import '../../../../../core/core.dart';

import '../../domain/entity/material_type.dart';
import '../../domain/usecase/create_material_type_usecase.dart';
import '../../domain/usecase/update_material_type_usecase.dart';

class MaterialTypeFormNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<MaterialType> {
  final CreateMaterialTypeUseCase _createMaterialTypeUseCase;
  final UpdateMaterialTypeUseCase _updateMaterialTypeUseCase;

  MaterialTypeFormNotifier({
    required CreateMaterialTypeUseCase createMaterialTypeUseCase,
    required UpdateMaterialTypeUseCase updateMaterialTypeUseCase,
    MaterialType? materialType,
  }) : _createMaterialTypeUseCase = createMaterialTypeUseCase,
       _updateMaterialTypeUseCase = updateMaterialTypeUseCase,
       _materialType = materialType ?? MaterialType(isActive: true);

  MaterialType _materialType;
  MaterialType get materialType => _materialType;

  bool get isCreate => _materialType.id == null;

  OperationKey submitOp = OperationKey.submit();

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () =>
          isCreate ? _createMaterialTypeUseCase.call(_materialType) : _updateMaterialTypeUseCase.call(_materialType),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void updateName(String? value) {
    _materialType = _materialType.copyWith(name: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _materialType = _materialType.copyWith(isActive: value?.isActive);
    notifyListeners();
  }
}
