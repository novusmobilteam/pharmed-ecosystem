import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';
import 'redirected_intake_orders_state.dart';

final redirectedIntakeOrdersNotifierProvider =
    NotifierProvider<RedirectedIntakeOrdersNotifier, RedirectedIntakeOrdersState>(RedirectedIntakeOrdersNotifier.new);

class RedirectedIntakeOrdersNotifier extends Notifier<RedirectedIntakeOrdersState> {
  GetRedirectedIntakeOrdersUseCase get _getOrders => ref.read(getRedirectedIntakeOrdersUseCaseProvider);
  CheckRedirectedIntakeUseCase get _checkRedirected => ref.read(checkRedirectedIntakeUseCaseProvider);

  @override
  RedirectedIntakeOrdersState build() => const RedirectedOrdersNoPatient();

  /// PatientSelectionPanel'in `selectedPatient` prop'una vermek için —
  /// hangi state'te olursak olalım seçili hastayı döner.
  Hospitalization? get selectedHospitalization => switch (state) {
    RedirectedOrdersLoading(:final hospitalization) => hospitalization,
    RedirectedOrdersLoaded(:final hospitalization) => hospitalization,
    RedirectedOrdersError(:final hospitalization) => hospitalization,
    _ => null,
  };

  Future<void> selectPatient(Hospitalization hospitalization) async {
    state = RedirectedOrdersLoading(hospitalization);
    final id = hospitalization.id;
    if (id == null) {
      state = RedirectedOrdersError(hospitalization, null);
      return;
    }

    final result = await _getOrders.call(id);
    result.when(
      ok: (orders) => state = RedirectedOrdersLoaded(hospitalization: hospitalization, orders: orders),
      error: (e) => state = RedirectedOrdersError(hospitalization, e.message),
    );
  }

  void toggleOrder(int referralId) {
    final s = state;
    if (s is! RedirectedOrdersLoaded) return;
    final next = Set<int>.from(s.selectedOrderIds);
    next.contains(referralId) ? next.remove(referralId) : next.add(referralId);
    state = s.copyWith(selectedOrderIds: next);
  }

  Future<void> checkSelected() async {
    final s = state;
    if (s is! RedirectedOrdersLoaded || !s.canStart) return;

    final states = {...s.checkStates};
    for (final id in s.selectedOrderIds) {
      states[id] = const CheckLoading();
    }
    state = s.copyWith(checkStates: states);

    for (final id in s.selectedOrderIds) {
      final result = await _checkRedirected.call(id);
      final current = state;
      if (current is! RedirectedOrdersLoaded) return;
      final updated = {...current.checkStates};
      result.when(
        ok: (_) => updated[id] = const CheckSuccess(),
        error: (e) => updated[id] = CheckFailed(message: e.message),
      );
      state = current.copyWith(checkStates: updated);
    }
  }
}
