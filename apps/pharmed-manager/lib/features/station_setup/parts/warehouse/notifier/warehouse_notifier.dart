import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class WarehouseNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Warehouse> {
  final GetWarehousesUseCase _getWarehousesUseCase;
  final DeleteWarehouseUseCase _deleteWarehouseUseCase;

  WarehouseNotifier({
    required GetWarehousesUseCase getWarehousesUseCase,
    required DeleteWarehouseUseCase deleteWarehouseUseCase,
  }) : _getWarehousesUseCase = getWarehousesUseCase,
       _deleteWarehouseUseCase = deleteWarehouseUseCase;

  OperationKey deleteOp = OperationKey.delete();
  OperationKey fetchOp = OperationKey.fetch();

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getWarehousesUseCase.call(
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
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
        onSuccess?.call(null);
        fetch();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
