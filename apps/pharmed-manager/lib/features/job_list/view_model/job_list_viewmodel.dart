import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';
import '../../prescription/domain/entity/prescription_item.dart';
import '../../prescription/domain/repository/i_prescription_repository.dart';

class JobListViewModel extends ChangeNotifier with SearchMixin<PrescriptionItem>, ApiRequestMixin {
  final IPrescriptionRepository _prescriptionRepository;

  JobListViewModel({required IPrescriptionRepository prescriptionRepository})
    : _prescriptionRepository = prescriptionRepository;

  // Operation Keys
  static const fetch = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetch);

  // Functions
  Future<void> fetchDailyJobList() async {
    await execute(fetch, operation: () => _prescriptionRepository.getDailyJobList(), onData: (data) => allItems = data);
  }
}
