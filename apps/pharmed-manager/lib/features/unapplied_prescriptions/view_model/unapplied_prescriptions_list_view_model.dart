import 'package:flutter/widgets.dart';

import 'package:pharmed_manager/core/core.dart';
import '../../prescription/domain/entity/prescription.dart';
import '../../prescription/domain/repository/i_prescription_repository.dart';

class UnappliedPrescriptionListViewModel extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<Prescription>, DateFilterMixin<Prescription> {
  final IPrescriptionRepository _prescriptionRepository;

  UnappliedPrescriptionListViewModel({required IPrescriptionRepository prescriptionRepository})
    : _prescriptionRepository = prescriptionRepository;

  // Operation Keys
  static const fetch = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetch);

  @override
  List<Prescription> get filteredItems {
    if (super.searchQuery.isNotEmpty) {
      return super.filteredItems;
    }
    return applyDateFilter(allItems);
  }

  // Functions
  Future<void> fetchUnappliedPrescriptions() async {
    await execute(
      fetch,
      operation: () => _prescriptionRepository.getUnappliedPrescriptions(),
      onData: (data) => allItems = data,
    );
  }

  @override
  DateTime? getDateField(Prescription item) => item.hospitalizationDate;
}
