// [SWREQ-UI-CAB-006]
// Arıza bildirimi ekranı state yönetimi.
//
// Sorumluluk:
//   - init() → GetFaultsUseCase ile tüm arızaları çeker
//   - Çekmece / göz seçimi → bellekte lookup, istek atılmaz
//   - onCellTap() → aktif arızayı bulur, yeni/sonlandır modunu belirler
//   - submit() → CreateFaultRecordUseCase veya ClearFaultRecordUseCase
//   - İşlem sonrası arızaları yeniler, göz seçimi korunur
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import '../../fault.dart';

final masterFaultNotifierProvider = NotifierProvider<MasterFaultNotifier, MasterFaultState>(MasterFaultNotifier.new);

class MasterFaultNotifier extends Notifier<MasterFaultState> {
  GetMasterCabinFaultRecordsUseCase get _getFaults => ref.read(getMasterCabinFaultRecordsProvider);
  CreateMasterCabinFaultRecordUseCase get _createFault => ref.read(createMasterCabinFaultRecordProvider);
  ClearMasterCabinFaultRecordUseCase get _clearFault => ref.read(clearMasterCabinFaultRecordProvider);

  @override
  MasterFaultState build() => const MasterFaultUninitialized();

  Future<void> init(CabinVisualizerData data) async {
    state = MasterFaultLoading(groups: data.groups, cabinId: data.cabinId);

    final result = await _getFaults.call();

    state = result.when(
      ok: (faults) => MasterFaultIdle(groups: data.groups, faults: faults, cabinId: data.cabinId),
      error: (e) => MasterFaultError(
        message: e.message,
        previous: MasterFaultIdle(groups: data.groups, faults: const [], cabinId: data.cabinId),
      ),
    );
  }

  void onDrawerTap(DrawerGroup group) {
    final current = state;
    final groups = current.groups;
    final faults = current.faults;
    final cabinId = current.cabinId;

    // Toggle
    final currentSlotId = switch (current) {
      MasterFaultDrawerSelected s => s.selectedSlotId,
      MasterFaultCellSelected s => s.selectedSlotId,
      _ => null,
    };

    if (currentSlotId == (group.slot.id ?? -1)) {
      state = MasterFaultIdle(groups: groups, faults: faults, cabinId: cabinId);
      return;
    }

    state = MasterFaultDrawerSelected(groups: groups, faults: faults, cabinId: cabinId, selectedGroup: group);
  }

  void onCellTap(DrawerUnit unit, int? stepNo) {
    final current = state;
    final groups = current.groups;
    final faults = current.faults;
    final cabinId = current.cabinId;

    final selectedGroup = switch (current) {
      MasterFaultDrawerSelected s => s.selectedGroup,
      MasterFaultCellSelected s => s.selectedGroup,
      _ => null,
    };

    if (selectedGroup == null) return;

    // Toggle — aynı göz tekrar tıklandı
    if (current is MasterFaultCellSelected && current.selectedUnit.id == unit.id) {
      state = MasterFaultDrawerSelected(groups: groups, faults: faults, cabinId: cabinId, selectedGroup: selectedGroup);
      return;
    }

    final slotId = unit.id;

    // Aktif arızayı bul (endDate == null)
    final activeFault = _findActiveFault(slotId: slotId, faults: faults);

    // Geçmişi bul (en yeni en üstte)
    final history = _findFaultHistory(slotId: slotId, faults: faults);

    state = MasterFaultCellSelected(
      groups: groups,
      faults: faults,
      cabinId: cabinId,
      selectedGroup: selectedGroup,
      selectedUnit: unit,
      faultHistory: history,
      activeFault: activeFault,
      selectedStatus: activeFault?.workingStatus ?? CabinWorkingStatus.faulty,
      description: activeFault?.description,
    );
  }

  /// Segmented button — sadece yeni kayıt modunda çalışır.
  void onStatusChanged(int index) {
    final current = state;
    if (current is! MasterFaultCellSelected) return;
    if (!current.isNewRecord) return;

    final status = index == 0 ? CabinWorkingStatus.faulty : CabinWorkingStatus.maintenance;

    state = MasterFaultCellSelected(
      groups: current.groups,
      faults: current.faults,
      cabinId: current.cabinId,
      selectedGroup: current.selectedGroup,
      selectedUnit: current.selectedUnit,
      faultHistory: current.faultHistory,
      activeFault: current.activeFault,
      selectedStatus: status,
      description: current.description,
    );
  }

  void onDescriptionChanged(String value) {
    final current = state;
    if (current is! MasterFaultCellSelected) return;

    state = MasterFaultCellSelected(
      groups: current.groups,
      faults: current.faults,
      cabinId: current.cabinId,
      selectedGroup: current.selectedGroup,
      selectedUnit: current.selectedUnit,
      faultHistory: current.faultHistory,
      activeFault: current.activeFault,
      selectedStatus: current.selectedStatus,
      description: value.isEmpty ? null : value,
    );
  }

  Future<void> submit() async {
    final current = state;
    if (current is! MasterFaultCellSelected) return;
    if (!current.canSubmit) return;

    state = MasterFaultSaving(
      groups: current.groups,
      faults: current.faults,
      cabinId: current.cabinId,
      selectedGroup: current.selectedGroup,
      selectedUnit: current.selectedUnit,
    );

    final Result<void> result;

    if (current.isNewRecord) {
      // Yeni arıza kaydı
      final fault = MasterFault(
        slotId: current.selectedUnit.id,
        startDate: DateTime.now(),
        workingStatus: current.selectedStatus,
        description: current.description,
      );

      result = await _createFault.call(
        status: current.selectedStatus,
        fault: fault,
        cellId: current.selectedUnit.id ?? 0,
      );
    } else {
      // Aktif kaydı sonlandır
      final activeFault = current.activeFault;
      if (activeFault is! MasterFault) return;
      final closed = activeFault.copyWith(endDate: DateTime.now());

      result = await _clearFault.call(
        status: current.selectedStatus,
        fault: closed,
        cellId: current.selectedUnit.id ?? 0,
      );
    }

    result.when(
      ok: (_) => _refreshFaults(
        groups: current.groups,
        cabinId: current.cabinId,
        selectedGroup: current.selectedGroup,
        selectedUnit: current.selectedUnit,
        isNewRecord: current.isNewRecord,
      ),
      error: (e) {
        state = MasterFaultError(message: e.message, previous: current);
      },
    );
  }

  Future<void> _refreshFaults({
    required List<DrawerGroup> groups,
    required int cabinId,
    required DrawerGroup selectedGroup,
    required DrawerUnit selectedUnit,
    required bool isNewRecord,
  }) async {
    final result = await _getFaults.call();

    state = result.when(
      ok: (faults) {
        final activeFault = _findActiveFault(slotId: selectedUnit.id, faults: faults);
        final history = _findFaultHistory(slotId: selectedUnit.id, faults: faults);

        final nextSelected = MasterFaultCellSelected(
          groups: groups,
          faults: faults,
          cabinId: cabinId,
          selectedGroup: selectedGroup,
          selectedUnit: selectedUnit,
          faultHistory: history,
          activeFault: activeFault,
          selectedStatus: activeFault?.workingStatus ?? CabinWorkingStatus.faulty,
          description: null,
        );

        final message = isNewRecord ? 'Arıza kaydı oluşturuldu.' : 'Arıza kaydı kapatıldı.';

        return MasterFaultSuccess(message: message, previous: nextSelected);
      },
      error: (e) => MasterFaultError(
        message: e.message,
        previous: MasterFaultDrawerSelected(
          groups: groups,
          faults: const [],
          cabinId: cabinId,
          selectedGroup: selectedGroup,
        ),
      ),
    );
  }

  void dismissError() {
    final current = state;
    if (current is! MasterFaultError) return;
    state = current.previous;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MasterFaultSuccess) return;
    state = current.previous;
  }

  MasterFault? _findActiveFault({required int? slotId, required List<MasterFault> faults}) {
    if (slotId == null) return null;
    try {
      return faults.firstWhere((f) => f.slotId == slotId && f.endDate == null);
    } catch (_) {
      return null;
    }
  }

  List<MasterFault> _findFaultHistory({required int? slotId, required List<MasterFault> faults}) {
    if (slotId == null) return const [];
    return faults.where((f) => f.slotId == slotId).toList().reversed.toList();
  }
}
