import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class MedicineActivityViewModel extends ChangeNotifier with SearchMixin<PrescriptionItem>, ApiRequestMixin {
  final IPrescriptionRepository _prescriptionRepository;

  MedicineActivityViewModel({required IPrescriptionRepository prescriptionRepository})
    : _prescriptionRepository = prescriptionRepository;

  // Operation Keys
  static const fetch = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetch);

  // Functions
  Future<void> fetchActivities() async {
    await execute(
      fetch,
      operation: () => _prescriptionRepository.getMedicineActivities(),
      onData: (data) => allItems = data,
    );
  }
}
