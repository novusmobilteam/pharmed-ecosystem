import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class UnitNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Unit> {
  final GetUnitsUseCase _getUnitsUseCase;
  final DeleteUnitUseCase _deleteUnitUseCase;

  UnitNotifier({required GetUnitsUseCase getUnitsUseCase, required DeleteUnitUseCase deleteUnitUseCase})
    : _getUnitsUseCase = getUnitsUseCase,
      _deleteUnitUseCase = deleteUnitUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  // Getters
  bool get isFetching => isLoading(fetchOp);

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchOp,
      fetchMethod: (int skip, int take) =>
          _getUnitsUseCase.call(PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery)),
    );
  }

  Future<void> deleteUnit(Unit unit, {Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteUnitUseCase.call(unit),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call(null);
        fetch();
      },
    );
  }
}
