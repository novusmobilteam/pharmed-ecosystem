import 'package:flutter/foundation.dart';

import 'package:pharmed_manager/core/core.dart';

class UnappliedPrescriptionDetailViewModel extends ChangeNotifier with ApiRequestMixin, SearchMixin<PrescriptionItem> {
  final IPrescriptionRepository _prescriptionRepository;

  UnappliedPrescriptionDetailViewModel({required IPrescriptionRepository prescriptionRepository})
    : _prescriptionRepository = prescriptionRepository;

  // Operation Keys
  static const fetchDetail = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetchDetail);

  // Functions
  Future<void> getPrescriptionDetail(int prescriptionId) async {
    await execute(
      fetchDetail,
      operation: () => _prescriptionRepository.getUnappliedPrescriptionDetail(prescriptionId),
      onData: (data) {
        // SearchMixin içindeki allItems'a veriyi atıyoruz
        allItems = data;
      },
    );
  }
}
