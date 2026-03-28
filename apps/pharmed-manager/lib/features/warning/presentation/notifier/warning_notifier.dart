import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/warning.dart';
import '../../domain/usecase/delete_warning_usecase.dart';
import '../../domain/usecase/get_warnings_usecase.dart';

class WarningNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Warning> {
  final GetWarningsUseCase _getWarningsUseCase;
  final DeleteWarningUseCase _deleteWarningUseCase;

  WarningNotifier({required GetWarningsUseCase getWarningsUseCase, required DeleteWarningUseCase deleteWarningUseCase})
    : _getWarningsUseCase = getWarningsUseCase,
      _deleteWarningUseCase = deleteWarningUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isFetching => isLoading(fetchOp);

  // Functions
  Future<void> getWarnings() async {
    await execute(fetchOp, operation: () => _getWarningsUseCase.call(), onData: (data) => allItems = data);
  }

  Future<void> deleteWarning(
    Warning warning, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteWarningUseCase.call(warning),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı.');
        getWarnings();
      },
    );
  }
}
