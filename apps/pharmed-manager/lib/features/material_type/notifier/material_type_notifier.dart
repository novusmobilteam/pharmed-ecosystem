import 'package:flutter/material.dart' hide MaterialType;
import 'package:pharmed_manager/core/core.dart';

class MaterialTypeNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<MaterialType> {
  final GetMaterialTypesUseCase _getMaterialTypesUseCase;
  final DeleteMaterialTypeUseCase _deleteMaterialTypeUseCase;

  MaterialTypeNotifier({
    required GetMaterialTypesUseCase getMaterialTypesUseCase,
    required DeleteMaterialTypeUseCase deleteMaterialTypeUseCase,
  }) : _getMaterialTypesUseCase = getMaterialTypesUseCase,
       _deleteMaterialTypeUseCase = deleteMaterialTypeUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isFetching => isLoading(fetchOp);

  Future<void> getMaterialTypes() async {
    await execute(
      fetchOp,
      operation: () => _getMaterialTypesUseCase.call(GetMaterialTypeParams()),
      onData: (response) => allItems = response.data ?? [],
    );
  }

  Future<void> deleteMaterialType(
    MaterialType type, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteMaterialTypeUseCase.call(type),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı.');
        getMaterialTypes();
      },
    );
  }
}
