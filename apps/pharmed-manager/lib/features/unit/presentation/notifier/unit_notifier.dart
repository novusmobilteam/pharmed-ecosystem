import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/unit.dart';
import '../../domain/usecase/delete_unit_usecase.dart';
import '../../domain/usecase/get_units_usecase.dart';

class UnitNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Unit> {
  final GetUnitsUseCase _getUnitsUseCase;
  final DeleteUnitUseCase _deleteUnitUseCase;

  UnitNotifier({required GetUnitsUseCase getUnitsUseCase, required DeleteUnitUseCase deleteUnitUseCase})
    : _getUnitsUseCase = getUnitsUseCase,
      _deleteUnitUseCase = deleteUnitUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  // Getters
  bool get isFetching => isLoading(fetchOp);

  // Functions
  Future<void> getUnits() async {
    await execute(
      fetchOp,
      operation: () => _getUnitsUseCase.call(GetUnitsParams()),
      onData: (response) => allItems = response.data ?? [],
    );
  }

  Future<void> deleteUnit(Unit unit, {Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteUnitUseCase.call(unit),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı.');
        getUnits();
      },
    );
  }
}
