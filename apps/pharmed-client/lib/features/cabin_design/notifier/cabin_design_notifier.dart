// [SWREQ-CLI-CABIN-DESIGN-001] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';
import 'cabin_design_state.dart';

final cabinDesignNotifierProvider = NotifierProvider<CabinDesignNotifier, CabinDesignState>(CabinDesignNotifier.new);

class CabinDesignNotifier extends Notifier<CabinDesignState> {
  GetCabinVisualizerDataUseCase get _getVisualizerData => ref.read(getCabinVisualizerDataUseCaseProvider);
  SetReturnDrawerUseCase get _setReturnDrawer => ref.read(setReturnDrawerUseCaseProvider);

  @override
  CabinDesignState build() => const CabinDesignLoading();

  Future<void> init(int cabinId) async {
    state = const CabinDesignLoading();

    final result = await _getVisualizerData.call(cabinId: cabinId);

    result.when(
      ok: (data) {
        final groups = data.groups;
        final current = groups.firstWhereOrNull((g) => g.isReturnDrawer);
        final cabin = groups.firstOrNull?.slot.cabin;

        if (cabin == null) {
          state = CabinDesignError(message: '...', previousState: const CabinDesignLoading());
          return;
        }

        state = CabinDesignReady(
          cabin: cabin,
          groups: groups,
          currentReturnSlotId: current?.slot.id,
          selectedSlotId: groups.firstOrNull?.slot.id,
        );
      },
      error: (e) => state = CabinDesignError(message: e.message, previousState: const CabinDesignLoading()),
    );
  }

  void selectSlot(int slotId) {
    final s = state;
    if (s is! CabinDesignReady) return;
    state = s.copyWith(selectedSlotId: slotId);
  }

  void toggleReturnDrawer(bool value) {
    final s = state;
    if (s is! CabinDesignReady || s.isSaving) return;
    final slotId = s.selectedSlotId;
    if (slotId == null) return;
    state = s.copyWith(pendingReturnSlotId: slotId, pendingReturnValue: value);
  }

  void dismissError() {
    final s = state;
    if (s is CabinDesignError) state = s.previousState;
  }

  Future<bool> save() async {
    final s = state;
    if (s is! CabinDesignReady || !s.canSave) return false;

    final slotId = s.pendingReturnSlotId!;
    final value = s.pendingReturnValue!;

    state = s.copyWith(isSaving: true);

    final result = await _setReturnDrawer.call(slotId, value);

    return result.when(
      ok: (_) {
        state = s.copyWith(
          currentReturnSlotId: value ? slotId : null,
          clearCurrentReturnSlotId: !value,
          clearPendingReturn: true,
          isSaving: false,
        );
        return true;
      },
      error: (e) {
        state = CabinDesignError(message: e.message, previousState: s.copyWith(isSaving: false));
        return false;
      },
    );
  }
}
