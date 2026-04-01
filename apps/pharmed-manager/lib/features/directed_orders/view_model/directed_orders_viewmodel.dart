import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class DirectedOrdersViewModel extends ChangeNotifier with SearchMixin<Hospitalization>, ApiRequestMixin {
  final IHospitalizationRepository _hospitalizationRepository;

  DirectedOrdersViewModel({required IHospitalizationRepository hospitalizationRepository})
    : _hospitalizationRepository = hospitalizationRepository;

  // Operation Keys
  static const fetch = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetch);

  // Functions
  Future<void> fetchHospitalizations() async {
    await execute(
      fetch,
      operation: () => _hospitalizationRepository.getHospitalizations(),
      onData: (response) {
        allItems = response?.data ?? [];
      },
    );
  }
}
