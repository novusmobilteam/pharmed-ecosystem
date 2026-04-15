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

import '../../../../core/providers/providers.dart';
import '../state/fault_ui_state.dart';

final faultNotifierProvider = NotifierProvider<FaultNotifier, FaultUiState>(FaultNotifier.new);

class FaultNotifier extends Notifier<FaultUiState> {
  GetCabinFaultsUseCase get _getFaults => ref.read(getCabinFaultsUseCaseProvider);
  CreateFaultRecordUseCase get _createFault => ref.read(createFaultRecordUseCaseProvider);
  ClearFaultRecordUseCase get _clearFault => ref.read(clearFaultRecordUseCaseProvider);

  @override
  FaultUiState build() => const FaultUninitialized();

  Future<void> init(CabinVisualizerData data) async {
    state = FaultLoading(groups: data.groups, cabinId: data.cabinId);

    final result = await _getFaults.call();

    state = result.when(
      ok: (faults) => FaultIdle(groups: data.groups, faults: faults, cabinId: data.cabinId),
      error: (e) => FaultError(
        message: e.message,
        previous: FaultIdle(groups: data.groups, faults: const [], cabinId: data.cabinId),
      ),
    );
  }

  // ── Çekmece seçimi ───────────────────────────────────────────────

  void onDrawerTap(DrawerGroup group) {
    final current = state;
    final groups = _extractGroups(current);
    final faults = _extractFaults(current);
    final cabinId = _extractCabinId(current);

    // Toggle
    final currentSlotId = switch (current) {
      FaultDrawerSelected s => s.selectedSlotId,
      FaultCellSelected s => s.selectedSlotId,
      _ => null,
    };

    if (currentSlotId == (group.slot.id ?? -1)) {
      state = FaultIdle(groups: groups, faults: faults, cabinId: cabinId);
      return;
    }

    state = FaultDrawerSelected(groups: groups, faults: faults, cabinId: cabinId, selectedGroup: group);
  }

  // ── Göz seçimi ───────────────────────────────────────────────────

  void onCellTap(DrawerUnit unit, int? stepNo) {
    final current = state;

    final groups = _extractGroups(current);
    final faults = _extractFaults(current);
    final cabinId = _extractCabinId(current);

    final selectedGroup = switch (current) {
      FaultDrawerSelected s => s.selectedGroup,
      FaultCellSelected s => s.selectedGroup,
      _ => null,
    };

    if (selectedGroup == null) return;

    // Toggle — aynı göz tekrar tıklandı
    if (current is FaultCellSelected && current.selectedUnit.id == unit.id) {
      state = FaultDrawerSelected(groups: groups, faults: faults, cabinId: cabinId, selectedGroup: selectedGroup);
      return;
    }

    final slotId = unit.id;

    // Aktif arızayı bul (endDate == null)
    final activeFault = _findActiveFault(slotId: slotId, faults: faults);

    // Geçmişi bul (en yeni en üstte)
    final history = _findFaultHistory(slotId: slotId, faults: faults);

    state = FaultCellSelected(
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

  // ── Form ─────────────────────────────────────────────────────────

  /// Segmented button — sadece yeni kayıt modunda çalışır.
  void onStatusChanged(int index) {
    final current = state;
    if (current is! FaultCellSelected) return;
    if (!current.isNewRecord) return;

    final status = index == 0 ? CabinWorkingStatus.faulty : CabinWorkingStatus.maintenance;

    state = FaultCellSelected(
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
    if (current is! FaultCellSelected) return;

    state = FaultCellSelected(
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

  // ── Submit ───────────────────────────────────────────────────────

  Future<void> submit() async {
    final current = state;
    if (current is! FaultCellSelected) return;
    if (!current.canSubmit) return;

    state = FaultSaving(
      groups: current.groups,
      faults: current.faults,
      cabinId: current.cabinId,
      selectedGroup: current.selectedGroup,
      selectedUnit: current.selectedUnit,
    );

    final Result<void> result;

    if (current.isNewRecord) {
      // Yeni arıza kaydı
      final fault = Fault(
        slotId: current.selectedUnit.id,
        startDate: DateTime.now(),
        workingStatus: current.selectedStatus,
        description: current.description,
      );

      final params = CreateFaultRecordParams(
        fault: fault,
        slotId: current.selectedUnit.id ?? 0,
        status: current.selectedStatus,
      );

      result = await _createFault.call(params);
    } else {
      // Aktif kaydı sonlandır
      final closed = current.activeFault!.copyWith(endDate: DateTime.now());

      final params = CreateFaultRecordParams(
        fault: closed,
        slotId: current.selectedUnit.id ?? 0,
        status: current.selectedStatus,
      );

      result = await _clearFault.call(params);
    }

    result.when(
      ok: (_) => _refreshFaults(
        groups: current.groups,
        cabinId: current.cabinId,
        selectedGroup: current.selectedGroup,
        selectedUnit: current.selectedUnit,
      ),
      error: (e) {
        state = FaultError(message: e.message, previous: current);
      },
    );
  }

  // ── Hata sonrası geri dön ────────────────────────────────────────

  void dismissError() {
    final current = state;
    if (current is! FaultError) return;
    state = current.previous;
  }

  // ── Refresh ──────────────────────────────────────────────────────

  Future<void> _refreshFaults({
    required List<DrawerGroup> groups,
    required int cabinId,
    required DrawerGroup selectedGroup,
    required DrawerUnit selectedUnit,
  }) async {
    final result = await _getFaults.call();

    state = result.when(
      ok: (faults) {
        final activeFault = _findActiveFault(slotId: selectedUnit.id, faults: faults);
        final history = _findFaultHistory(slotId: selectedUnit.id, faults: faults);

        return FaultCellSelected(
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
      },
      error: (e) => FaultError(
        message: e.message,
        previous: FaultDrawerSelected(groups: groups, faults: const [], cabinId: cabinId, selectedGroup: selectedGroup),
      ),
    );
  }

  // ── Yardımcılar ──────────────────────────────────────────────────

  Fault? _findActiveFault({required int? slotId, required List<Fault> faults}) {
    if (slotId == null) return null;
    try {
      return faults.firstWhere((f) => f.slotId == slotId && f.endDate == null);
    } catch (_) {
      return null;
    }
  }

  List<Fault> _findFaultHistory({required int? slotId, required List<Fault> faults}) {
    if (slotId == null) return const [];
    return faults.where((f) => f.slotId == slotId).toList().reversed.toList();
  }

  List<DrawerGroup> _extractGroups(FaultUiState s) => switch (s) {
    FaultLoading(:final groups) => groups,
    FaultIdle(:final groups) => groups,
    FaultDrawerSelected(:final groups) => groups,
    FaultCellSelected(:final groups) => groups,
    FaultSaving(:final groups) => groups,
    FaultError(:final previous) => _extractGroups(previous),
    _ => const [],
  };

  List<Fault> _extractFaults(FaultUiState s) => switch (s) {
    FaultIdle(:final faults) => faults,
    FaultDrawerSelected(:final faults) => faults,
    FaultCellSelected(:final faults) => faults,
    FaultSaving(:final faults) => faults,
    FaultError(:final previous) => _extractFaults(previous),
    _ => const [],
  };

  int _extractCabinId(FaultUiState s) => switch (s) {
    FaultLoading(:final cabinId) => cabinId,
    FaultIdle(:final cabinId) => cabinId,
    FaultDrawerSelected(:final cabinId) => cabinId,
    FaultCellSelected(:final cabinId) => cabinId,
    FaultSaving(:final cabinId) => cabinId,
    FaultError(:final previous) => _extractCabinId(previous),
    _ => 0,
  };
}
