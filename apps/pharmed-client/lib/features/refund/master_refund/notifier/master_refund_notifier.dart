import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/dashboard/dashboard.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/hardware/hardware.dart';
import '../../../../core/providers/providers.dart';
import 'master_refund_state.dart';

final masterRefundNotifierProvider = NotifierProvider<MasterRefundNotifier, MasterRefundState>(
  MasterRefundNotifier.new,
);

class MasterRefundNotifier extends Notifier<MasterRefundState> {
  late final MasterDrawerOrchestrator _orchestrator;

  Hospitalization? _hospitalization;
  StationCabinsContext? _stationContext;

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

  Future<void> init(StationCabinsContext ctx) async {
    _hospitalization = null;
    _stationContext = ctx;
    state = MasterRefundPatientSelection();
  }

  MedicineAssignment? _resolveReturnDrawerAssignment(RefundableItem checkedItem) {
    final ctx = _stationContext;
    if (ctx == null) return null;

    // İade çekmecesi, kaynak item'ın kabininden BAĞIMSIZ — istasyonda tek bir
    // fiziksel konumda tanımlı (genelde ayrı bir CabinType.returnCabin).
    // Backend'in resolvedTarget'ı eksik/güvenilmez olabildiği için item'ın
    // kendi kabin bilgisine hiç bakmıyoruz — istasyondaki TÜM kabinleri
    // tarayıp isReturnDrawer grubunu buluyoruz.
    for (final data in ctx.cabinDataByCabinId.values) {
      final group = data.groups.firstWhereOrNull((g) => g.isReturnDrawer);
      if (group == null) continue;

      final unit = group.units.firstOrNull;
      if (unit == null) continue;

      final resolvedUnit = unit.drawerSlot == null ? unit.copyWith(drawerSlot: group.slot) : unit;

      // CabinOperationCellGeometry.forKubik, detailId'yi
      // assignment.cabinDrawerDetail?.firstOrNull?.id'den okuyor — bu yüzden
      // sentetik assignment'a bu alanı MUTLAKA doldurmamız gerekiyor, aksi
      // halde detailId hep 0 gider (bkz. startRefund'daki bug). Kaynak:
      // CabinVisualizerData.stocks içinde, cabinDrawerId == unit.id olan
      // CabinStock kaydının kendi cabinDrawerDetail'i (DrawerCell).
      final matchingStock = data.stocks.firstWhereOrNull((s) => s.cabinDrawerId == unit.id);
      final detail = matchingStock?.cabinDrawerDetail;

      return MedicineAssignment.empty(cabinId: data.cabin.id ?? 0, cabinDrawerId: unit.id ?? 0).copyWith(
        drawerUnit: resolvedUnit,
        medicine: checkedItem.medicine,
        cabinDrawerDetail: detail != null ? [detail] : null,
      );
    }

    return null;
  }

  void _onDrawerStage(MasterDrawerStage? previous, MasterDrawerStage current) {
    switch (current) {
      case MasterDrawerOpened():
        if (previous is MasterDrawerWaitingForPull) {
          _onDrawerOpened();
        }
      case MasterDrawerClosed():
        _onCurrentDrawerClosed();
      case MasterDrawerLidFailed(:final failure, :final detail):
        MedLogger.warn(
          unit: 'MasterRefund',
          swreq: 'SWREQ-CLI-MREFUND-002', // gerçek SWREQ tag'ini kendi dosyandan doğrula
          message: 'Kübik kapak açma reddedildi',
          context: {'failure': failure.name, 'detail': detail},
        );
      case MasterDrawerFailed(:final failure, :final detail):
        _onDrawerFailed(failure, detail);
      default:
        break;
    }
  }

  Future<void> _startExecuting(List<RefundTarget> hardwareTargets) async {
    final jobs = RefundQueueBuilder.build(hardwareTargets);
    state = MasterRefundExecuting(jobs: jobs);
    await _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  Future<void> _openJobAt({required int jobIndex, required int targetIndex}) async {
    final s = state;
    if (s is! MasterRefundExecuting) return;
    if (jobIndex < 0 || jobIndex >= s.jobs.length) {
      await _loadItems();
      return;
    }
    final job = s.jobs[jobIndex];

    final updatedJobs = List<RefundDrawerJob>.from(s.jobs);
    updatedJobs[jobIndex] = job.copyWith(status: CabinOperationJobStatus.active);
    state = s.copyWith(jobs: updatedJobs, currentIndex: jobIndex, currentTargetIndex: targetIndex, isSaving: false);

    final openAssignment = job.staysOpenAcrossTargets
        ? job.representativeTarget.assignment
        : job.targets[targetIndex].assignment;
    await _orchestrator.open(assignment: openAssignment);
  }

  Future<void> confirmCurrent() async {
    final s = state;
    if (s is! MasterRefundExecuting || s.isSaving) return;
    final job = s.currentJob;
    if (job == null) return;

    if (job.isReturnDrawer) {
      state = s.copyWith(isSaving: true);
      for (final target in job.targets) {
        final ok = await _completeTarget(target);
        if (!ok) return;
      }
      final current = state;
      if (current is MasterRefundExecuting) {
        state = current.copyWith(isSaving: false);
      }
      _orchestrator.confirmClose();
      return;
    }

    final target = s.currentTarget;
    if (target == null) return;

    if (job.isKubik) {
      state = s.copyWith(isSaving: true);
      // Aynı fiziksel göze (drawerUnit.id) ait, currentTargetIndex'ten
      // başlayan ARDIŞIK tüm target'lar (RefundQueueBuilder sıralaması
      // orderNo'ya göre olduğu için bunlar garanti bitişiktir) TEK tıklamada
      // tamamlanır — kullanıcı her kayıt için ayrı ayrı "sonraki göz"e
      // basmak zorunda kalmaz. Kapak fiziksel olarak değişmediği sürece
      // (aynı gözdeyken) hepsi arka arkaya backend'e gönderilir.
      final ok = await _completeCurrentCellTargets();
      if (!ok) return;
      await _advanceWithinOpenDrawer();
    } else {
      _orchestrator.confirmClose();
    }
  }

  /// currentTargetIndex'ten başlayarak aynı göze ait tüm target'ları
  /// tamamlar, currentTargetIndex'i bu grubun SON elemanına ilerletir.
  /// _advanceWithinOpenDrawer bir sonraki çağrıldığında artık gerçek bir
  /// sonraki FİZİKSEL göze geçmiş olur (aynı gözde tekrar lid komutu
  /// göndermez — bkz. mevcut sameCellAsCurrent guard'ı).
  Future<bool> _completeCurrentCellTargets() async {
    final s = state;
    if (s is! MasterRefundExecuting) return false;
    final job = s.currentJob;
    if (job == null) return false;

    var index = s.currentTargetIndex;
    final cellId = job.targets[index].assignment.drawerUnit?.id;

    while (true) {
      final ok = await _completeTarget(job.targets[index]);
      if (!ok) return false; // _completeTarget zaten hata state'ini set etti

      final nextIndex = index + 1;
      final sameCell = nextIndex < job.targets.length && job.targets[nextIndex].assignment.drawerUnit?.id == cellId;
      if (!sameCell) break;

      index = nextIndex;
      final current = state;
      if (current is MasterRefundExecuting) {
        state = current.copyWith(currentTargetIndex: index);
      }
    }

    return true;
  }

  void _onDrawerOpened() {
    final s = state;
    if (s is! MasterRefundExecuting) return;
    final job = s.currentJob;
    if (job == null) return;
    if (job.isKubik) {
      _orchestrator.openCubicLid(job.targets[s.currentTargetIndex].assignment);
    }

    if (job.isReturnDrawer) return;
    // isReturnDrawer: hiçbir lid komutu gönderilmez, doğrudan
    // confirmCurrent beklenir (kullanıcı manuel kapaklı kutuya bırakır).
  }

  Future<void> _advanceWithinOpenDrawer() async {
    final s = state;
    if (s is! MasterRefundExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final nextIndex = s.currentTargetIndex + 1;
    if (nextIndex < job.targets.length) {
      // Aynı fiziksel göze (DrawerUnit) ait birden fazla target olabilir —
      // örn. aynı ilaçtan farklı zamanlarda ayrı ayrı alınmış kayıtlar hepsi
      // aynı kübik gözden çıkıyor. Bu durumda kapak zaten AÇIK, tekrar
      // openCubicLid göndermek gereksiz/hatalı bir donanım komutu üretir —
      // hedef göz değişmediyse (drawerUnit.id aynıysa) komut atlanır.
      final currentCellId = job.targets[s.currentTargetIndex].assignment.drawerUnit?.id;
      final nextCellId = job.targets[nextIndex].assignment.drawerUnit?.id;
      final sameCellAsCurrent = currentCellId != null && currentCellId == nextCellId;

      state = s.copyWith(currentTargetIndex: nextIndex, isSaving: false);
      if (job.isKubik && !sameCellAsCurrent) {
        await _orchestrator.openCubicLid(job.targets[nextIndex].assignment);
      }
      // isReturnDrawer: donanıma zaten hiç komut yok (mevcut davranış korunuyor).
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

    if (!job.staysOpenAcrossTargets) {
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
    state = MasterRefundExecuting(jobs: updatedJobs, currentIndex: nextIndex);
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

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
            //isQueueError: true,
          );
        } else if (current is MasterRefundMedicineSelection) {
          state = current.copyWith(
            checkStatuses: Map<int, RefundCheckStatus>.from(current.checkStatuses)
              ..[item.id] = RefundCheckFailed(message: e.message),
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
    state = MasterRefundExecuting(jobs: updatedJobs, currentIndex: nextIndex);
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
      state = MasterRefundPatientSelection();
      return;
    }

    final result = await _getRefundables.call(hospitalization.id ?? 0);
    result.when(
      ok: (sourceItems) {
        final items = sourceItems.map((s) => RefundableItem(source: s, appliedQuantity: s.dosePiece)).toList();
        state = MasterRefundMedicineSelection(hospitalization: hospitalization, items: items);
      },
      error: (e) => state = MasterRefundError(
        failure: CabinApiFailure(message: e.message),
        previousState: MasterRefundMedicineSelection(hospitalization: hospitalization, items: const []),
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
      onFailed?.call(contextlessL10n().refund_error_amountZero);
      return;
    }

    final max = s.maxAmountFor(itemId);
    if (amount > max) {
      onFailed?.call(contextlessL10n().refund_error_amountExceeded);
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

    final selected = s.selectedItems.where((it) {
      final drug = it.medicine?.when(drug: (d) => d, consumable: (_) => null);
      return drug?.returnType?.requiresCabinHardware ?? false;
    }).toList();

    if (selected.isEmpty) {
      state = s.copyWith(isChecking: false);
      return;
    }

    final hardwareEntries = <RefundTarget>[];
    final nonHardwareEntries = <RefundTarget>[];
    final checkStatuses = Map<int, RefundCheckStatus>.from(s.checkStatuses);

    for (final item in selected) {
      checkStatuses[item.id] = const RefundCheckLoading();
      state = s.copyWith(checkStatuses: Map.of(checkStatuses), isChecking: true);

      final quantity = s.amountFor(item.id);
      print('Quantity: $quantity');
      final returnType = (item.medicine is Drug) ? (item.medicine as Drug).returnType : null;

      if (item.medicine?.id == null || returnType == null) {
        checkStatuses[item.id] = RefundCheckFailed(message: contextlessL10n().refund_error_genericCheckFailed);
        state = MasterRefundError(
          failure: const CabinValidationFailure(reason: CabinValidationReason.noValidTargets),
          previousState: s.copyWith(checkStatuses: Map.of(checkStatuses), isChecking: false),
        );
        return;
      }

      final result = await _checkStatus.call(item: item, returnType: returnType, quantity: quantity);

      final failed = result.when(
        ok: (checkedItem) {
          var resolved = checkedItem;

          if (resolved.returnType == ReturnType.toDrawer) {
            // Backend'in resolvedTarget'ına GÜVENME — dolu gelse bile
            // medicine/drawerUnit eksik olabiliyor (bkz. toReturnBox'taki
            // requiresCabinTarget deneyimiyle aynı ders). Koşulsuz kendi
            // çözümümüzle üzerine yaz.
            final returnAssignment = _resolveReturnDrawerAssignment(resolved);
            if (returnAssignment == null) {
              checkStatuses[item.id] = RefundCheckFailed(
                message: contextlessL10n().refund_error_returnDrawerNotDefined,
              );
              return true;
            }
            resolved = resolved.copyWith(resolvedTarget: returnAssignment);
          }

          checkStatuses[item.id] = const RefundCheckSuccess();
          if (resolved.requiresCabinTarget) {
            hardwareEntries.add(
              RefundTarget(item: resolved, isReturnDrawerTarget: resolved.returnType == ReturnType.toDrawer),
            );
          } else {
            nonHardwareEntries.add(RefundTarget(item: resolved));
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
            failure: CabinApiFailure(message: contextlessL10n().refund_error_completeFailed),
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

  /// Donanım gerektirmeyen iade tiplerinde (İade Kutusu / Eczane) kart
  /// üzerindeki "İade Et" butonundan çağrılır. Seçim ekranını terk etmeden
  /// tek item için check + complete akışını yürütür.
  /// Dönüş `true` ise View, tipe göre teslim mesajını gösterir.
  Future<bool> completeDirectRefund(int itemId) async {
    final s = state;
    if (s is! MasterRefundMedicineSelection) return false;

    final item = s.items.firstWhereOrNull((it) => it.id == itemId);
    if (item == null) return false;

    state = s.copyWith(
      checkStatuses: Map<int, RefundCheckStatus>.from(s.checkStatuses)..[itemId] = const RefundCheckLoading(),
    );

    final quantity = s.amountFor(itemId);
    final drug = item.medicine?.when(drug: (d) => d, consumable: (_) => null);
    final returnType = drug?.returnType;

    if (item.medicine?.id == null || returnType == null) {
      final current = state;
      if (current is MasterRefundMedicineSelection) {
        state = current.copyWith(
          checkStatuses: Map<int, RefundCheckStatus>.from(current.checkStatuses)
            ..[itemId] = RefundCheckFailed(message: contextlessL10n().refund_error_genericCheckFailed),
        );
      }
      return false;
    }

    final result = await _checkStatus.call(item: item, returnType: returnType, quantity: quantity);

    RefundableItem? checkedItem;
    final failed = result.when(
      ok: (c) {
        checkedItem = c;
        return false;
      },
      error: (e) {
        final current = state;
        if (current is MasterRefundMedicineSelection) {
          state = current.copyWith(
            checkStatuses: Map<int, RefundCheckStatus>.from(current.checkStatuses)
              ..[itemId] = RefundCheckFailed(message: e.message),
          );
        }
        return true;
      },
    );

    if (failed || checkedItem == null) return false;

    final checked = checkedItem!;

    // Bu metod SADECE donanımsız (toReturnBox/toPharmacy) kart butonundan
    // çağrılır — checkedItem.requiresCabinTarget'a bakılmaz, her koşulda
    // doğrudan tamamlanır. (Önceki "requiresCabinTarget true ise kuyruğa
    // devret" fallback'i KALDIRILDI: server'daki bu alan returnType ile
    // birebir örtüşmüyor ve iade kutusu/eczane akışını yanlışlıkla çekmece
    // açılışına yönlendiriyordu.)
    final ok = await _completeTarget(RefundTarget(item: checked));
    if (ok) await _loadItems();
    return ok;
  }

  void dismissError() {
    final s = state;
    if (s is MasterRefundError) state = s.previousState;
  }
}
