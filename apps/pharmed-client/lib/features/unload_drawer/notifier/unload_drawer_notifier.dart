// features/unload_drawer/notifier/unload_drawer_notifier.dart

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/hardware/hardware.dart';
import '../../../../core/providers/providers.dart';
import 'unload_drawer_state.dart';

final unloadDrawerNotifierProvider = NotifierProvider<UnloadDrawerNotifier, UnloadDrawerState>(
  UnloadDrawerNotifier.new,
);

class UnloadDrawerNotifier extends Notifier<UnloadDrawerState> {
  late final MasterDrawerOrchestrator _orchestrator;
  int _cabinId = 0;
  UnloadDrawerMode _mode = UnloadDrawerMode.drawer;
  CabinVisualizerData? _visualizerData;

  GetReturnDrawerMedicinesUseCase get _getDrawerMedicines => ref.read(getReturnDrawerMedicinesUseCaseProvider);
  UnloadReturnDrawerUseCase get _unloadDrawer => ref.read(unloadReturnDrawerUseCaseProvider);
  GetReturnBoxMedicinesUseCase get _getBoxMedicines => ref.read(getReturnBoxMedicinesUseCaseProvider);
  UnloadReturnBoxUseCase get _unloadBox => ref.read(unloadReturnBoxUseCaseProvider);

  @override
  UnloadDrawerState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);
    return const UnloadDrawerUninitialized();
  }

  Future<void> init(CabinVisualizerData data) async {
    _cabinId = data.cabinId;
    _visualizerData = data;
    _mode = UnloadDrawerMode.drawer;
    state = UnloadDrawerLoading(mode: _mode);
    await _loadItems();
  }

  Future<void> switchMode(UnloadDrawerMode mode) async {
    final s = state;
    if (s is UnloadDrawerExecuting) return; // donanım açıkken mod değişimi engellenir
    if (s is UnloadDrawerSelection && s.mode == mode) return;
    _mode = mode;
    state = UnloadDrawerLoading(mode: mode);
    await _loadItems();
  }

  Future<void> _loadItems() async {
    final result = _mode == UnloadDrawerMode.drawer ? await _getDrawerMedicines.call() : await _getBoxMedicines.call();

    result.when(
      ok: (items) => state = UnloadDrawerSelection(cabinId: _cabinId, mode: _mode, items: items ?? const []),
      error: (e) => state = UnloadDrawerError(
        failure: CabinApiFailure(message: e.message),
        previousState: UnloadDrawerSelection(cabinId: _cabinId, mode: _mode, items: const []),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // BOX MODU — donanımsız, seçimli
  // ---------------------------------------------------------------------

  void toggleItem(int itemId) {
    final s = state;
    if (s is! UnloadDrawerSelection || s.isSubmitting) return;
    final next = Set<int>.from(s.selectedIds);
    next.contains(itemId) ? next.remove(itemId) : next.add(itemId);
    state = s.copyWith(selectedIds: next);
  }

  Future<void> confirmBoxUnload() async {
    final s = state;
    if (s is! UnloadDrawerSelection || s.mode != UnloadDrawerMode.box || !s.canConfirm) return;

    state = s.copyWith(isSubmitting: true);
    final result = await _unloadBox.call(s.selectedIds.toList());

    result.when(
      ok: (_) => _loadItems(),
      error: (e) => state = UnloadDrawerError(
        failure: CabinApiFailure(message: e.message),
        previousState: s.copyWith(isSubmitting: false),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // DRAWER MODU — donanımlı, tek adım (queue yok)
  // ---------------------------------------------------------------------

  /// CabinDesign'da işaretlenmiş iade çekmecesinin unit'i üzerinden açılış
  /// assignment'ı üretir — refund'daki _resolveReturnDrawerAssignment ile
  /// aynı kaynak, medicine taşımaya gerek yok (execution kartında item
  /// listesi zaten notifier state'inden geliyor, assignment.medicine'e
  /// bağımlı değil).
  MedicineAssignment? _resolveReturnDrawerAssignment() {
    final group = _visualizerData?.groups.firstWhereOrNull((g) => g.isReturnDrawer);
    final unit = group?.units.firstOrNull;
    if (group == null || unit == null) return null;
    return MedicineAssignment.empty(cabinId: _cabinId, cabinDrawerId: unit.id ?? 0).copyWith(drawerUnit: unit);
  }

  Future<void> startDrawerUnload() async {
    final s = state;
    if (s is! UnloadDrawerSelection || s.mode != UnloadDrawerMode.drawer || !s.canConfirm) return;

    final assignment = _resolveReturnDrawerAssignment();
    if (assignment == null) {
      state = UnloadDrawerError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.noValidTargets),
        previousState: s,
      );
      return;
    }

    state = UnloadDrawerExecuting(cabinId: _cabinId, items: s.selectedItems, assignment: assignment);
    await _orchestrator.open(assignment: assignment);
  }

  void _onDrawerStage(MasterDrawerStage? previous, MasterDrawerStage current) {
    switch (current) {
      case MasterDrawerClosed():
        _onDrawerClosedAfterUnload();
      case MasterDrawerFailed(:final failure, :final detail):
        _onDrawerFailed(failure, detail);
      default:
        break; // MasterDrawerOpened: kübik lid komutu yok, kullanıcı bekleniyor
    }
  }

  Future<void> confirmDrawerUnload() async {
    final s = state;
    if (s is! UnloadDrawerExecuting || s.isSaving) return;
    state = s.copyWith(isSaving: true);

    final ids = s.items.map((e) => e.id).whereType<int>().toList();
    final result = await _unloadDrawer.call(ids);

    result.when(
      ok: (_) {
        final current = state;
        if (current is UnloadDrawerExecuting) {
          state = current.copyWith(status: CabinOperationJobStatus.completed, isSaving: false);
        }
        _orchestrator.confirmClose();
      },
      error: (e) => state = UnloadDrawerError(
        failure: CabinApiFailure(message: e.message),
        previousState: s.copyWith(isSaving: false),
        isQueueError: true,
      ),
    );
  }

  Future<void> _onDrawerClosedAfterUnload() async {
    await _orchestrator.stop();
    _mode = UnloadDrawerMode.drawer;
    state = UnloadDrawerLoading(mode: _mode);
    await _loadItems();
  }

  void _onDrawerFailed(MasterDrawerFailure failure, String? detail) {
    final s = state;
    if (s is! UnloadDrawerExecuting) return;
    state = UnloadDrawerError(
      failure: CabinMasterDrawerFailure(failure: failure, detail: detail),
      previousState: s.copyWith(isSaving: false),
      isQueueError: true,
    );
  }

  Future<void> continueAfterError() async {
    final s = state;
    if (s is! UnloadDrawerError || s.previousState is! UnloadDrawerExecuting) return;
    await _orchestrator.stop();
    _mode = UnloadDrawerMode.drawer;
    state = UnloadDrawerLoading(mode: _mode);
    await _loadItems();
  }

  Future<void> abortAfterError() async {
    final s = state;
    if (s is! UnloadDrawerError || s.previousState is! UnloadDrawerExecuting) return;
    await _orchestrator.stop();
    _mode = UnloadDrawerMode.drawer;
    state = UnloadDrawerLoading(mode: _mode);
    await _loadItems();
  }

  void dismissError() {
    final s = state;
    if (s is UnloadDrawerError) state = s.previousState;
  }
}
