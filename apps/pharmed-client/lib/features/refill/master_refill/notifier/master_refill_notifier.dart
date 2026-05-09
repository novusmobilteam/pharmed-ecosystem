// lib/features/refill/master_refill/presentation/notifier/master_refill_notifier.dart
//
// [SWREQ-CLI-MREFILL-002] [IEC 62304 §5.5]
// Master kabin dolum ekranı state yönetimi.
//
// Sorumluluk:
//   - CabinVisualizerData'dan groups, stocks, faults alır — ekstra istek yok
//   - init() → GetMedicineAssignmentsUseCase ile atamaları çeker
//   - onDrawerTap: her iki tip için DrawerSelected — göz bekleniyor
//   - onCellTap:
//       Kübik    → CellSelected, tek göz input
//       Birim doz → CellSelected, seçili unit'in tüm gözleri için stepInputs
//   - saveRefill() → RefillMedicineUseCase
//   - Çekmece kapandığında (MasterDrawerClosed) saveRefill otomatik tetiklenir
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../../core/providers/providers.dart';
import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/cabin_operation/master_drawer/master_drawer_orchestrator.dart';
import '../../refill.dart';
import 'refill_step_input.dart';

final masterRefillNotifierProvider = NotifierProvider<MasterRefillNotifier, MasterRefillState>(
  MasterRefillNotifier.new,
);

class MasterRefillNotifier extends Notifier<MasterRefillState> {
  late final MasterDrawerOrchestrator _orchestrator;

  GetMedicineAssignmentsUseCase get _getAssignments => ref.read(getMedicineAssignmentsUseCaseProvider);
  RefillMasterCabinUseCase get _refillMedicine => ref.read(refillMasterCabinUsecaseProvider);

  @override
  MasterRefillState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init();

    ref.listen<MasterDrawerSessionState>(masterDrawerSessionProvider, (_, next) {
      if (next.stage is MasterDrawerClosed) {
        saveRefill();
        _orchestrator.stop();
      }
    });

    ref.onDispose(() => _orchestrator.dispose());

    return const MasterRefillUninitialized();
  }

  Future<void> openDrawer() async {
    final current = state;
    if (current is! MasterRefillCellSelected) return;

    final openCubicLid = current.selectedGroup.isKubik;
    final assignment = current.isKubik
        ? current.selectedAssignment
        : current.assignments.firstWhereOrNull((a) => a.cabinDrawerId == current.selectedUnit.id);

    if (assignment == null) return;

    await _orchestrator.open(assignment: assignment, openCubicLid: openCubicLid);
  }

  void confirmClose() => _orchestrator.confirmClose();
  Future<void> cancelDrawer() => _orchestrator.stop();

  Future<void> init(CabinVisualizerData data) async {
    final cabinId = data.cabinId;
    state = MasterRefillLoading(groups: data.groups, cabinId: cabinId);

    final result = await _getAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) => MasterRefillIdle(
        groups: data.groups,
        cabinId: cabinId,
        stocks: data.stocks,
        faults: data.masterFaults,
        assignments: assignments,
      ),
      error: (e) => MasterRefillError(
        message: e.message,
        previousState: MasterRefillIdle(
          groups: data.groups,
          cabinId: cabinId,
          stocks: data.stocks,
          faults: data.masterFaults,
          assignments: const [],
        ),
      ),
    );
  }

  void onDrawerTap(DrawerGroup group) {
    final currentSlotId = switch (state) {
      MasterRefillDrawerSelected s => s.selectedSlotId,
      MasterRefillCellSelected s => s.selectedSlotId,
      _ => null,
    };

    // Aynı çekmece tekrar tıklandı → Idle'a dön
    if (currentSlotId == (group.slot.id ?? -1)) {
      state = MasterRefillIdle(
        groups: state.groups,
        assignments: state.assignments,
        stocks: state.stocks,
        faults: state.faults,
        cabinId: state.cabinId,
      );
      return;
    }

    // Her iki tip için DrawerSelected — göz/sıra seçimi bekleniyor
    state = MasterRefillDrawerSelected(
      groups: state.groups,
      assignments: state.assignments,
      stocks: state.stocks,
      faults: state.faults,
      selectedGroup: group,
      cabinId: state.cabinId,
    );
  }

  void onCellTap(DrawerUnit unit, int? stepNo) {
    final selectedGroup = state.selectedGroup;
    if (selectedGroup == null) return;

    // Toggle — aynı göz/sıra tekrar tıklandı → DrawerSelected'a dön
    if (state is MasterRefillCellSelected) {
      final current = state as MasterRefillCellSelected;
      final isSameSelection = current.isKubik
          ? current.selectedUnitId == unit.id && current.selectedStepNo == stepNo
          : current.selectedUnitId == unit.id;

      if (isSameSelection) {
        state = MasterRefillDrawerSelected(
          groups: state.groups,
          assignments: state.assignments,
          stocks: state.stocks,
          faults: state.faults,
          selectedGroup: selectedGroup,
          cabinId: state.cabinId,
        );
        return;
      }
    }

    if (selectedGroup.isKubik || selectedGroup.isSerum) {
      _selectKubikCell(selectedGroup, unit, stepNo);
    } else {
      _selectUnitDoseCell(selectedGroup, unit);
    }
  }

  void _selectKubikCell(DrawerGroup group, DrawerUnit unit, int? stepNo) {
    state = MasterRefillCellSelected(
      groups: state.groups,
      assignments: state.assignments,
      stocks: state.stocks,
      faults: state.faults,
      selectedGroup: group,
      selectedUnit: unit,
      selectedStepNo: stepNo,
      cabinId: state.cabinId,
      stepInputs: null,
      fillingQuantity: 0,
      countQuantity: 0,
      miadDate: null,
    );
  }

  void _selectUnitDoseCell(DrawerGroup group, DrawerUnit unit) {
    final config = group.slot.drawerConfig;
    final numberOfSteps = config?.numberOfSteps ?? 6;
    final stepMultiplier = config?.stepMultiplier ?? 1;
    final totalSteps = numberOfSteps * stepMultiplier;

    final stepInputs = List.generate(totalSteps, (i) {
      final stepNo = i + 1;
      final stock = state.stocks.firstWhereOrNull(
        (s) => s.cabinDrawerDetail?.drawerUnit?.id == unit.id && s.cabinDrawerDetail?.stepNo == stepNo,
      );
      return RefillStepInput(
        unit: unit,
        stepNo: stepNo,
        countQuantity: stock?.quantity?.toDouble() ?? 0,
        miadDate: null,
      );
    });

    state = MasterRefillCellSelected(
      groups: state.groups,
      assignments: state.assignments,
      stocks: state.stocks,
      faults: state.faults,
      selectedGroup: group,
      selectedUnit: unit,
      cabinId: state.cabinId,
      stepInputs: stepInputs,
    );
  }

  // ── Kübik input değişiklikleri ────────────────────────────────────────────

  void onFillingQuantityChanged(double value) {
    final current = state;
    if (current is! MasterRefillCellSelected || !current.isKubik) return;
    state = current.copyWithKubik(fillingQuantity: value);
  }

  void onCountQuantityChanged(double value) {
    final current = state;
    if (current is! MasterRefillCellSelected || !current.isKubik) return;
    state = current.copyWithKubik(countQuantity: value);
  }

  void onMiadDateChanged(DateTime? date) {
    final current = state;
    if (current is! MasterRefillCellSelected || !current.isKubik) return;
    state = current.copyWithKubik(miadDate: date);
  }

  // ── Birim doz göz bazlı input değişiklikleri ──────────────────────────────

  void onStepFillingChanged(int index, double value) {
    final current = state;
    if (current is! MasterRefillCellSelected || !current.isUnitDose) return;
    final updated = current.stepInputs![index].copyWith(fillingQuantity: value);
    state = current.copyWithStepInput(index, updated);
  }

  void onStepCountChanged(int index, double value) {
    final current = state;
    if (current is! MasterRefillCellSelected || !current.isUnitDose) return;
    final updated = current.stepInputs![index].copyWith(countQuantity: value);
    state = current.copyWithStepInput(index, updated);
  }

  void onStepMiadChanged(int index, DateTime? date) {
    final current = state;
    if (current is! MasterRefillCellSelected || !current.isUnitDose) return;
    final updated = current.stepInputs![index].copyWith(miadDate: date);
    state = current.copyWithStepInput(index, updated);
  }

  // ── Kaydet ───────────────────────────────────────────────────────────────

  Future<void> saveRefill() async {
    final current = state;
    if (current is! MasterRefillCellSelected) return;
    if (!current.canSave) return;

    state = MasterRefillSaving(
      groups: current.groups,
      assignments: current.assignments,
      stocks: current.stocks,
      faults: current.faults,
      selectedGroup: current.selectedGroup,
      selectedUnit: current.selectedUnit,
      cabinId: current.cabinId,
    );

    final List<RefillMedicineParams> params;

    if (current.isKubik) {
      final assignment = current.selectedAssignment!;
      params = [
        RefillMedicineParams(
          cabinDrawerDetailId: assignment.id ?? 0,
          quantity: current.fillingQuantity,
          countQuantity: current.countQuantity,
          miadDate: current.miadDate,
          materialId: assignment.medicine?.id ?? 0,
          shelfNo: current.selectedUnit.orderNo ?? 0,
          compartmentNo: current.selectedUnit.compartmentNo ?? 0,
        ),
      ];
    } else {
      // Birim doz: (unitId, stepNo) → cabinDrawerDetailId lookup
      params = current.stepInputs!.where((s) => s.hasInput).map((s) {
        final assignment = current.assignments.firstWhereOrNull((a) => a.cabinDrawerId == s.unit.id);
        // stepNo bazlı cabinDrawerDetail bul
        final detail = assignment?.cabinDrawerDetail?.firstWhereOrNull((d) => d.stepNo == s.stepNo);
        return RefillMedicineParams(
          cabinDrawerDetailId: detail?.id ?? 0,
          quantity: s.fillingQuantity,
          countQuantity: s.countQuantity,
          miadDate: s.miadDate,
          materialId: assignment?.medicine?.id ?? 0,
          shelfNo: s.unit.orderNo ?? 0,
          compartmentNo: s.stepNo,
        );
      }).toList();
    }

    final result = await _refillMedicine.call(params);

    result.when(
      ok: (_) => _refreshAssignments(
        groups: current.groups,
        stocks: current.stocks,
        faults: current.faults,
        selectedGroup: current.selectedGroup,
        selectedUnit: current.selectedUnit,
        cabinId: current.cabinId,
        message: 'Dolum başarıyla kaydedildi',
      ),
      error: (e) {
        state = MasterRefillError(message: e.message, previousState: current);
      },
    );
  }

  Future<void> _refreshAssignments({
    required List<DrawerGroup> groups,
    required List<CabinStock> stocks,
    required List<MasterFault> faults,
    required DrawerGroup selectedGroup,
    required DrawerUnit selectedUnit,
    required int cabinId,
    required String message,
  }) async {
    final result = await _getAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) => MasterRefillSuccess(
        groups: groups,
        assignments: assignments,
        stocks: stocks,
        faults: faults,
        selectedGroup: selectedGroup,
        selectedUnit: selectedUnit,
        cabinId: cabinId,
        message: message,
      ),
      error: (e) => MasterRefillError(
        message: e.message,
        previousState: MasterRefillIdle(
          groups: groups,
          assignments: const [],
          stocks: stocks,
          faults: faults,
          cabinId: cabinId,
        ),
      ),
    );
  }

  // ── Dismiss ───────────────────────────────────────────────────────────────

  void dismissError() {
    final current = state;
    if (current is! MasterRefillError) return;
    state = current.previousState;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MasterRefillSuccess) return;

    // Birim doz: aynı unit'i yeniden seç — stoklar refresh'ten geldi
    if (!current.selectedGroup.isKubik && !current.selectedGroup.isSerum) {
      _selectUnitDoseCell(current.selectedGroup, current.selectedUnit);
      return;
    }

    // Kübik: seçimi koru, inputları sıfırla
    state = MasterRefillCellSelected(
      groups: current.groups,
      assignments: current.assignments,
      stocks: current.stocks,
      faults: current.faults,
      selectedGroup: current.selectedGroup,
      selectedUnit: current.selectedUnit,
      cabinId: current.cabinId,
      fillingQuantity: 0,
      countQuantity: 0,
      miadDate: null,
    );
  }
}
