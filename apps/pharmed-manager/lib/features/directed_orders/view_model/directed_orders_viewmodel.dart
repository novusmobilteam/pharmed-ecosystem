import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class DirectedOrdersViewModel extends ChangeNotifier with ApiRequestMixin {
  final IHospitalizationRepository _hospitalizationRepository;

  DirectedOrdersViewModel({required IHospitalizationRepository hospitalizationRepository})
    : _hospitalizationRepository = hospitalizationRepository;

  // Operation Keys
  static const fetch = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetch);

  List<Hospitalization> _items = [];
  List<Hospitalization> get items => _items;

  // Functions
  Future<void> fetchHospitalizations() async {
    await execute(
      fetch,
      operation: () => _hospitalizationRepository.getHospitalizations(PagedQueryParams()),
      onData: (response) {
        _items = response.data ?? [];
      },
    );
  }
}
