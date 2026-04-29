import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class InconsistencyNotifier extends ChangeNotifier with SearchMixin<Inconsistency>, ApiRequestMixin {
  final GetInconsistenciesUseCase _getInconsistenciesUseCase;

  InconsistencyNotifier({required GetInconsistenciesUseCase getInconsistenciesUseCase})
    : _getInconsistenciesUseCase = getInconsistenciesUseCase;

  // Operation Keys
  OperationKey fetchOp = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetchOp);

  Future<void> getInconsistencies() async {
    await execute(
      fetchOp,
      operation: () => _getInconsistenciesUseCase.call(),
      onData: (response) => allItems = response.data ?? [],
    );
  }
}
