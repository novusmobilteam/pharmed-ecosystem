import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../prescription/domain/entity/prescription_item.dart';
import '../../../prescription/domain/repository/i_prescription_repository.dart';

class UnscannedBarcodesViewModel extends ChangeNotifier with ApiRequestMixin {
  final IPrescriptionRepository _prescriptionRepository;

  UnscannedBarcodesViewModel({required IPrescriptionRepository prescriptionRepository})
    : _prescriptionRepository = prescriptionRepository;

  // Operation Keys
  static const fetchOperation = OperationKey.fetch();

  // Data
  List<PrescriptionItem> _items = [];
  List<PrescriptionItem> get items => _items;

  // Getters
  bool get isFetching => isLoading(fetchOperation);
  bool get isEmpty => _items.isEmpty;

  // Functions
  Future<void> fetch() async {
    await execute(
      fetchOperation,
      operation: () => _prescriptionRepository.getUnscannedBarcodes(),
      onData: (data) => _items = data,
      loadingMessage: 'Taranmamış barkodlar yükleniyor...',
    );
  }
}
