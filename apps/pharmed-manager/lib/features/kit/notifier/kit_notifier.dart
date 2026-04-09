import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class KitNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Kit> {
  final GetKitsUseCase _getKitsUseCase;
  final DeleteKitUseCase _deleteKitUseCase;

  KitNotifier({required GetKitsUseCase getKitsUseCase, required DeleteKitUseCase deleteKitUseCase})
    : _deleteKitUseCase = deleteKitUseCase,
      _getKitsUseCase = getKitsUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isFetching => isLoading(fetchOp);

  Future<void> getKits() async {
    await execute(fetchOp, operation: () => _getKitsUseCase.call(), onData: (data) => allItems = data);
  }

  Future<void> deleteKit(Kit kit, {Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteKitUseCase.call(kit),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı.');
        getKits();
      },
    );
  }
}
