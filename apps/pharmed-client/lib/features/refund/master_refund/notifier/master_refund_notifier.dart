import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/hardware/hardware.dart';
import '../../../../core/providers/providers.dart';
import 'master_refund_state.dart';

final masterRefundNotifierProvider = NotifierProvider<MasterRefundNotifier, MasterRefundState>(
  MasterRefundNotifier.new,
);

class MasterRefundNotifier extends Notifier<MasterRefundState> {
  late final MasterDrawerOrchestrator _orchestrator;
  int _cabinId = 0;
  Hospitalization? _hospitalization;

  GetMasterRefundablesUseCase get _getRefundables => ref.read(getMasterRefundablesUseCaseProvider);
  CheckMasterRefundStatusUseCase get _checkStatus => ref.read(checkMasterRefundStatusUseCaseProvider);
  CompleteRefundUseCase get _completeRefund => ref.read(completeRefundUseCaseProvider);

  @override
  MasterRefundState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);
    return const MasterRefundUninitialized();
  }

  Future<void> init(CabinVisualizerData data) async {
    _cabinId = data.cabinId;
    _hospitalization = null;
    state = MasterRefundPatientSelection(cabinId: _cabinId);
  }

  void _onDrawerStage(MasterDrawerStage? previous, MasterDrawerStage current) {
    switch (current) {
      case MasterDrawerOpened():
        _onDrawerOpened();
      case MasterDrawerClosed():
        _onCurrentDrawerClosed();
      case MasterDrawerFailed(:final failure, :final detail):
        _onDrawerFailed(failure, detail);
      default:
        break;
    }
  }

  Future<void> _startExecuting(List<RefundTarget> hardwareTargets) async {
    final jobs = RefundQueueBuilder.build(hardwareTargets);
    state = MasterRefundExecuting(cabinId: _cabinId, jobs: jobs);
    await _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  Future<void> _openJobAt({required int jobIndex, required int targetIndex}) async {
    final s = state;
    if (s is! MasterRefundExecuting) return;
    if (jobIndex < 0 || jobIndex >= s.jobs.length) {
      await _loadItems(); // kuyruk bitti — temiz Selection'a dön
      return;
    }
    final job = s.jobs[jobIndex];

    final updatedJobs = List<RefundDrawerJob>.from(s.jobs);
    updatedJobs[jobIndex] = job.copyWith(status: CabinOperationJobStatus.active);
    state = s.copyWith(jobs: updatedJobs, currentIndex: jobIndex, currentTargetIndex: targetIndex, isSaving: false);

    final openAssignment = job.isKubik ? job.representativeTarget.assignment : job.targets[targetIndex].assignment;
    await _orchestrator.open(assignment: openAssignment);
  }

  Future<void> confirmCurrent() async {
    final s = state;
    if (s is! MasterRefundExecuting || s.isSaving) return;
    final job = s.currentJob;
    final target = s.currentTarget;
    if (job == null || target == null) return;

    if (job.isKubik) {
      state = s.copyWith(isSaving: true);
      final ok = await _completeTarget(target);
      if (!ok) return;
      await _advanceCubicLid();
    } else {
      _orchestrator.confirmClose();
    }
  }

  void _onDrawerOpened() {
    final s = state;
    if (s is! MasterRefundExecuting) return;
    final job = s.currentJob;
    if (job == null) return;
    if (job.isKubik) {
      _orchestrator.openCubicLid(job.targets[s.currentTargetIndex].assignment);
    }
  }

  Future<void> _advanceCubicLid() async {
    final s = state;
    if (s is! MasterRefundExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final nextIndex = s.currentTargetIndex + 1;
    if (nextIndex < job.targets.length) {
      state = s.copyWith(currentTargetIndex: nextIndex, isSaving: false);
      await _orchestrator.openCubicLid(job.targets[nextIndex].assignment);
    } else {
      state = s.copyWith(isSaving: false);
      _orchestrator.confirmClose();
    }
  }

  Future<void> _onCurrentDrawerClosed() async {
    final s = state;
    if (s is! MasterRefundExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    if (!job.isKubik) {
      final nextTarget = s.currentTargetIndex + 1;
      if (nextTarget < job.targets.length) {
        await _orchestrator.stop();
        await _openJobAt(jobIndex: s.currentIndex, targetIndex: nextTarget);
        return;
      }
    }

    final updatedJobs = List<RefundDrawerJob>.from(s.jobs);
    updatedJobs[s.currentIndex] = job.copyWith(status: CabinOperationJobStatus.completed);
    await _orchestrator.stop();

    final nextIndex = s.currentIndex + 1;
    state = MasterRefundExecuting(cabinId: s.cabinId, jobs: updatedJobs, currentIndex: nextIndex);
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  /// TODO: cabinDrawerDetailId kaynağı doğrulanmalı — item.source.stock
  /// (toOrigin: orijinal alım stoğunun detayı) doğru mu, yoksa toDrawer/
  /// toReturnBox için ayrı bir kaynak mı gerekiyor (bkz. RefundQueueBuilder/
  /// CompleteRefundParams görülmeden netleşmedi).
  Future<bool> _completeTarget(RefundTarget target) async {
    final item = target.item;
    final result = await _completeRefund.call(
      CompleteRefundParams(
        type: item.returnType!,
        id: item.id,
        quantity: (item.returnQuantity ?? item.appliedQuantity).toDouble(),
        cabinDrawerDetailId: item.source.stock?.cabinDrawerDetailId,
      ),
    );
    return result.when(
      ok: (_) => true,
      error: (e) {
        final current = state;
        if (current is MasterRefundExecuting) {
          state = MasterRefundError(
            failure: CabinApiFailure(message: e.message),
            previousState: current.copyWith(isSaving: false),
            isQueueError: true,
          );
        }
        return false;
      },
    );
  }

  void _onDrawerFailed(MasterDrawerFailure failure, String? detail) {
    final s = state;
    if (s is! MasterRefundExecuting) return;
    state = MasterRefundError(
      failure: CabinMasterDrawerFailure(failure: failure, detail: detail),
      previousState: s.copyWith(isSaving: false),
      isQueueError: true,
    );
  }

  Future<void> continueAfterError() async {
    final s = state;
    if (s is! MasterRefundError || s.previousState is! MasterRefundExecuting) return;
    final exec = s.previousState as MasterRefundExecuting;
    final job = exec.currentJob;
    if (job == null) return;
    final updatedJobs = List<RefundDrawerJob>.from(exec.jobs);
    updatedJobs[exec.currentIndex] = job.copyWith(status: CabinOperationJobStatus.failed);
    await _orchestrator.stop();
    final nextIndex = exec.currentIndex + 1;
    state = MasterRefundExecuting(cabinId: exec.cabinId, jobs: updatedJobs, currentIndex: nextIndex);
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  Future<void> abortAfterError() async {
    final s = state;
    if (s is! MasterRefundError || s.previousState is! MasterRefundExecuting) return;
    await _orchestrator.stop();
    await _loadItems();
  }

  Future<void> selectPatient(Hospitalization hospitalization) async {
    _hospitalization = hospitalization;
    state = const MasterRefundLoading();
    await _loadItems();
  }

  Future<void> _loadItems() async {
    final hospitalization = _hospitalization;
    if (hospitalization == null) {
      state = MasterRefundPatientSelection(cabinId: _cabinId);
      return;
    }

    final result = await _getRefundables.call(hospitalization.id ?? 0);
    result.when(
      ok: (sourceItems) {
        final items = sourceItems.map((s) => RefundableItem(source: s, appliedQuantity: s.dosePiece)).toList();
        state = MasterRefundMedicineSelection(cabinId: _cabinId, hospitalization: hospitalization, items: items);
      },
      error: (e) => state = MasterRefundError(
        failure: CabinApiFailure(message: e.message),
        previousState: MasterRefundMedicineSelection(
          cabinId: _cabinId,
          hospitalization: hospitalization,
          items: const [],
        ),
      ),
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! MasterRefundMedicineSelection || s.isChecking) return;
    state = s.copyWith(search: value);
  }

  void toggleItem(int itemId) {
    final s = state;
    if (s is! MasterRefundMedicineSelection || s.isChecking) return;
    final next = Set<int>.from(s.selectedItemIds);
    next.contains(itemId) ? next.remove(itemId) : next.add(itemId);
    state = s.copyWith(selectedItemIds: next);
  }

  void updateAmount(int itemId, double amount, {void Function(String message)? onFailed}) {
    final s = state;
    if (s is! MasterRefundMedicineSelection || s.isChecking) return;

    if (amount <= 0) {
      onFailed?.call('İade miktarı 0 olamaz');
      return;
    }

    final max = s.maxAmountFor(itemId);
    if (amount > max) {
      onFailed?.call('İade edilecek miktar alım miktarından fazla olamaz');
      return;
    }

    final items = s.items.map((it) => it.id == itemId ? it.copyWith(returnQuantity: amount) : it).toList();
    state = s.copyWith(items: items);
  }

  /// Seçili tüm item'lar için sırayla check koşturur, sonucu donanımsız
  /// (direkt complete) / donanımlı (kuyruğa aday) diye ikiye ayırır.
  Future<void> startRefund() async {
    final s = state;
    if (s is! MasterRefundMedicineSelection || !s.canStart) return;

    state = s.copyWith(isChecking: true);

    final selected = s.selectedItems;
    final hardwareEntries = <RefundTarget>[];
    final nonHardwareEntries = <RefundTarget>[];
    final checkStatuses = Map<int, RefundCheckStatus>.from(s.checkStatuses);

    for (final item in selected) {
      checkStatuses[item.id] = const RefundCheckLoading();
      state = s.copyWith(checkStatuses: Map.of(checkStatuses), isChecking: true);

      final quantity = s.amountFor(item.id);
      final returnType = (item.medicine is Drug) ? (item.medicine as Drug).returnType : null;

      if (item.medicine?.id == null || returnType == null) {
        checkStatuses[item.id] = const RefundCheckFailed(
          message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.',
        );
        state = MasterRefundError(
          failure: const CabinValidationFailure(reason: CabinValidationReason.noValidTargets),
          previousState: s.copyWith(checkStatuses: Map.of(checkStatuses), isChecking: false),
        );
        return;
      }

      final result = await _checkStatus.call(item: item, returnType: returnType, quantity: quantity);

      final failed = result.when(
        ok: (checkedItem) {
          checkStatuses[item.id] = const RefundCheckSuccess();
          if (checkedItem.requiresCabinTarget) {
            hardwareEntries.add(RefundTarget(item: checkedItem));
          } else {
            nonHardwareEntries.add(RefundTarget(item: checkedItem));
          }
          return false;
        },
        error: (e) {
          checkStatuses[item.id] = RefundCheckFailed(message: e.message);
          return true;
        },
      );

      if (failed) {
        state = MasterRefundError(
          failure: CabinApiFailure(message: (checkStatuses[item.id] as RefundCheckFailed).message ?? ''),
          previousState: s.copyWith(checkStatuses: Map.of(checkStatuses), isChecking: false),
        );
        return;
      }
    }

    for (final entry in nonHardwareEntries) {
      final ok = await _completeTarget(entry);
      if (!ok) {
        await _loadItems();
        final reloaded = state;
        if (reloaded is MasterRefundMedicineSelection) {
          state = MasterRefundError(
            failure: const CabinApiFailure(message: 'İade sırasında bir hata oluştu.'),
            previousState: reloaded,
          );
        }
        return;
      }
    }

    if (hardwareEntries.isEmpty) {
      await _loadItems();
      return;
    }

    await _startExecuting(hardwareEntries);
  }

  void dismissError() {
    final s = state;
    if (s is MasterRefundError) state = s.previousState;
  }
}
