import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class InconsistencyNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Inconsistency> {
  final GetInconsistenciesUseCase _getInconsistenciesUseCase;

  InconsistencyNotifier({required GetInconsistenciesUseCase getInconsistenciesUseCase})
    : _getInconsistenciesUseCase = getInconsistenciesUseCase;

  // Operation Keys
  OperationKey fetchOp = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetchOp);

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchOp,
      fetchMethod: (skip, take) =>
          _getInconsistenciesUseCase.call(PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery)),
    );
  }
}
