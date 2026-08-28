import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';
import '../../../dashboard/dashboard.dart';
import 'master_cabin_stock_state.dart';

final masterCabinStockNotifierProvider = NotifierProvider<MasterCabinStockNotifier, MasterCabinStockState>(
  MasterCabinStockNotifier.new,
);

class MasterCabinStockNotifier extends Notifier<MasterCabinStockState> {
  GetCabinAssignmentsWithCabinUseCase get _getAssignments => ref.read(getCabinAssignmentsWitCabinUseCaseProvider);

  @override
  MasterCabinStockState build() {
    return const MasterCabinStockUninitialized();
  }

  Future<void> init(CabinRouteContext ctx) async {
    final cabinId = ctx.cabin?.id;
    if (cabinId == null) {
      return;
    }
    state = const MasterCabinStockLoading();

    final result = await _getAssignments.call(cabinId);
    result.when(
      ok: (stocks) {
        state = MasterCabinStockIdle(cabinId: cabinId, stocks: stocks);
      },
      error: (e) {
        state = MasterCabinStockError(previousState: MasterCabinStockIdle(cabinId: cabinId));
      },
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! MasterCabinStockIdle) return;
    state = s.copyWith(search: value);
  }
}
