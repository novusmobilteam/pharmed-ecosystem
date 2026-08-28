import 'package:pharmed_core/pharmed_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import 'inventory_state.dart';

final inventoryNotifierProvider = NotifierProvider<InventoryNotifier, InventoryState>(InventoryNotifier.new);

class InventoryNotifier extends Notifier<InventoryState> {
  GetStationAssignmentsUseCase get _getAssignments => ref.read(getStationAssignmentsUseCaseProvider);

  @override
  InventoryState build() {
    _load();
    return const InventoryLoading();
  }

  void _enterLoading() {
    final current = state;
    state = current is InventoryLoaded ? current.copyWith(isLoading: true) : const InventoryLoading();
  }

  Future<void> _load() async {
    final result = await _getAssignments.call();
    result.when(
      ok: (items) {
        state = InventoryLoaded(items: items);
      },
      error: (e) => state = InventoryError(message: e.message),
    );
  }

  Future<void> refresh() async {
    _enterLoading();
    await _load();
  }
}
