import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class WarehouseTableNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Warehouse> {
  final GetWarehousesUseCase _getWarehousesUseCase;
  final DeleteWarehouseUseCase _deleteWarehouseUseCase;

  WarehouseTableNotifier({
    required GetWarehousesUseCase getWarehousesUseCase,
    required DeleteWarehouseUseCase deleteWarehouseUseCase,
  }) : _getWarehousesUseCase = getWarehousesUseCase,
       _deleteWarehouseUseCase = deleteWarehouseUseCase;

  OperationKey deleteOp = OperationKey.delete();
  OperationKey fetchOp = OperationKey.fetch();

  Future<void> getWarehouses() async {
    await execute(
      fetchOp,
      operation: () => _getWarehousesUseCase.call(GetWarehousesParams()),
      onData: (response) {
        if (response.data != null) {
          allItems = response.data!;
        }
      },
    );
  }

  Future<void> deleteWarehouse(
    Warehouse warehouse, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteWarehouseUseCase.call(warehouse),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        getWarehouses();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
