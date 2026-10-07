import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mixins/mixins.dart';
import '../../../core/providers/providers.dart';

final inventoryNotifierProvider = ChangeNotifierProvider.autoDispose<InventoryNotifier>((ref) {
  return InventoryNotifier(getAssignments: ref.read(getStationAssignmentsUseCaseProvider));
});

class InventoryNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetStationAssignmentsUseCase _getAssignments;

  InventoryNotifier({required GetStationAssignmentsUseCase getAssignments}) : _getAssignments = getAssignments {
    _fetchItems();
  }

  final OperationKey _getItemsOp = const OperationKey.custom('fetch-items');
  bool get isFetchingItems => isLoading(_getItemsOp);

  List<MedicineAssignment> _items = [];
  List<MedicineAssignment> get items => _items;

  Future<void> _fetchItems() async {
    await execute(
      _getItemsOp,
      operation: () => _getAssignments(),
      onData: (data) {
        _items = data;
        notifyListeners();
      },
    );
  }
}
