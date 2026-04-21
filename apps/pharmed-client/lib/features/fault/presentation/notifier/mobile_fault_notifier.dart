import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../fault.dart';

final mobileFaultNotifierProvider = NotifierProvider<MobileFaultNotifier, MobileFaultState>(MobileFaultNotifier.new);

class MobileFaultNotifier extends Notifier<MobileFaultState> {
  GetMobileCabinFaultRecordsUseCase get _getFaults => ref.read(getMobileCabinFaultRecordsProvider);
  CreateMobileCabinFaultRecordUseCase get _createFault => ref.read(createMobileCabinFaultRecordProvider);
  ClearMobileCabinFaultRecordUseCase get _clearFault => ref.read(clearMobileCabinFaultRecordProvider);

  @override
  MobileFaultState build() => const MobileFaultUninitialized();

  Future<void> init(CabinVisualizerData data) async {
    final slots = data.slots.whereType<MobileSlotVisual>().toList();

    state = MobileFaultLoading(slots: slots, cabinId: data.cabinId);

    final result = await _getFaults.call();

    state = result.when(
      ok: (faults) => MobileFaultIdle(slots: slots, faults: faults, cabinId: data.cabinId),
      error: (e) => MobileFaultError(
        message: e.message,
        previous: MobileFaultIdle(slots: slots, faults: const [], cabinId: data.cabinId),
      ),
    );
  }

  void onSlotTap(MobileSlotVisual slot) {
    final current = state;
    final slots = current.slots;
    final faults = current.faults;
    final cabinId = current.cabinId;

    // Toggle
    if (current is MobileFaultSlotSelected && current.selectedSlot.slotId == slot.slotId) {
      state = MobileFaultIdle(slots: slots, faults: faults, cabinId: cabinId);
      return;
    }

    final activeFault = _findActiveFault(slotId: slot.slotId, faults: faults);
    final history = _findFaultHistory(slotId: slot.slotId, faults: faults);

    state = MobileFaultSlotSelected(
      slots: slots,
      faults: faults,
      cabinId: cabinId,
      selectedSlot: slot,
      faultHistory: history,
      activeFault: activeFault,
      selectedStatus: activeFault?.workingStatus ?? CabinWorkingStatus.faulty,
      description: null,
    );
  }

  void onStatusChanged(int index) {
    final current = state;
    if (current is! MobileFaultSlotSelected) return;
    if (!current.isNewRecord) return;

    final status = index == 0 ? CabinWorkingStatus.faulty : CabinWorkingStatus.maintenance;

    state = MobileFaultSlotSelected(
      slots: current.slots,
      faults: current.faults,
      cabinId: current.cabinId,
      selectedSlot: current.selectedSlot,
      faultHistory: current.faultHistory,
      activeFault: current.activeFault,
      selectedStatus: status,
      description: current.description,
    );
  }

  void onDescriptionChanged(String value) {
    final current = state;
    if (current is! MobileFaultSlotSelected) return;

    state = MobileFaultSlotSelected(
      slots: current.slots,
      faults: current.faults,
      cabinId: current.cabinId,
      selectedSlot: current.selectedSlot,
      faultHistory: current.faultHistory,
      activeFault: current.activeFault,
      selectedStatus: current.selectedStatus,
      description: value.isEmpty ? null : value,
    );
  }

  Future<void> submit() async {
    final current = state;
    if (current is! MobileFaultSlotSelected) return;
    if (!current.canSubmit) return;

    state = MobileFaultSaving(
      slots: current.slots,
      faults: current.faults,
      cabinId: current.cabinId,
      selectedSlot: current.selectedSlot,
    );

    final Result<void> result;

    if (current.isNewRecord) {
      final fault = MobileFault(
        cabinDesignId: current.selectedSlot.slotId,
        startDate: DateTime.now(),
        workingStatus: current.selectedStatus,
        description: current.description,
      );

      result = await _createFault.call(
        status: current.selectedStatus,
        fault: fault,
        slotId: current.selectedSlot.slotId,
      );
    } else {
      final activeFault = current.activeFault;
      if (activeFault is! MobileFault) return;
      final closed = activeFault.copyWith(endDate: DateTime.now());

      result = await _clearFault.call(
        status: current.selectedStatus,
        fault: closed,
        slotId: current.selectedSlot.slotId,
      );
    }

    result.when(
      ok: (_) => _refreshFaults(
        slots: current.slots,
        cabinId: current.cabinId,
        selectedSlot: current.selectedSlot,
        isNewRecord: current.isNewRecord,
        currentFaults: current.faults,
      ),
      error: (e) {
        state = MobileFaultError(message: e.message, previous: current);
      },
    );
  }

  void dismissError() {
    final current = state;
    if (current is! MobileFaultError) return;
    state = current.previous;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MobileFaultSuccess) return;
    state = current.previous;
  }

  Future<void> _refreshFaults({
    required List<MobileSlotVisual> slots,
    required List<MobileFault> currentFaults,
    required int cabinId,
    required MobileSlotVisual selectedSlot,
    required bool isNewRecord,
  }) async {
    final result = await _getFaults.call();

    state = result.when(
      ok: (faults) {
        final activeFault = _findActiveFault(slotId: selectedSlot.slotId, faults: faults);
        final history = _findFaultHistory(slotId: selectedSlot.slotId, faults: faults);

        final nextSelected = MobileFaultSlotSelected(
          slots: slots,
          faults: faults,
          cabinId: cabinId,
          selectedSlot: selectedSlot,
          faultHistory: history,
          activeFault: activeFault,
          selectedStatus: activeFault?.workingStatus ?? CabinWorkingStatus.faulty,
          description: null,
        );

        ref.read(dashboardNotifierProvider.notifier).refreshCabinVisualizer();
        return MobileFaultSuccess(
          message: isNewRecord ? 'Arıza kaydı oluşturuldu.' : 'Arıza kaydı kapatıldı.', // TODO(l10n): move to view layer or pass translated string as parameter
          previous: nextSelected,
        );
      },
      error: (e) => MobileFaultError(
        message: e.message,
        previous: MobileFaultSlotSelected(
          slots: slots,
          faults: currentFaults,
          cabinId: cabinId,
          selectedSlot: selectedSlot,
          faultHistory: const [],
          activeFault: null,
          selectedStatus: CabinWorkingStatus.faulty,
        ),
      ),
    );
  }

  MobileFault? _findActiveFault({required int slotId, required List<MobileFault> faults}) {
    try {
      return faults.firstWhere((f) => f.cabinDesignId == slotId && f.endDate == null);
    } catch (_) {
      return null;
    }
  }

  List<MobileFault> _findFaultHistory({required int slotId, required List<MobileFault> faults}) =>
      faults.where((f) => f.cabinDesignId == slotId).toList().reversed.toList();
}
