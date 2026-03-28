import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';
import '../data/repository/inconsitency_repository_impl.dart';
import '../domain/entity/inconsistency.dart';

class InconsistencyListViewModel extends ChangeNotifier with SearchMixin<Inconsistency>, ApiRequestMixin {
  final InconsistencyRepository _inconsistencyRepository;

  InconsistencyListViewModel({required InconsistencyRepository inconsistencyRepository})
    : _inconsistencyRepository = inconsistencyRepository;

  // Operation Keys
  static const fetch = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetch);

  Future<void> fetchInconsistencies() async {
    await execute(
      fetch,
      operation: () => _inconsistencyRepository.getInconsistencies(),
      onData: (response) => allItems = response.data ?? [],
    );
  }
}
