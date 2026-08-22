// [SWREQ-CLI-MWASTE-002] [IEC 62304 §5.5]
// İlaç-merkezli master kabin FİRE/İMHA akışını yöneten notifier.
//
// İade (MasterRefundNotifier) ile aynı hasta→kalem seçim iskeletini
// paylaşır, ama donanım/çekmece kuyruğu YOKTUR — "Fire/İmha Et" doğrudan
// seçili kalemleri sırayla API'ye gönderir, ayrı bir Executing fazı yoktur.
// Şahit atama mantığı MasterIntakeNotifier.addWitness/resolveExistingWitness
// ile birebir aynıdır (WitnessContext üzerinden).
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/providers/providers.dart';
import '../../../auth/auth.dart';
import '../../../dashboard/dashboard.dart';
import 'master_waste_state.dart';

final masterWasteNotifierProvider = NotifierProvider<MasterWasteNotifier, MasterWasteState>(MasterWasteNotifier.new);

class MasterWasteNotifier extends Notifier<MasterWasteState> {
  Hospitalization? _hospitalization;

  Station? _currentStation;
  Station? get currentStation => _currentStation;

  GetMasterDisposablesUseCase get _getDisposables => ref.read(getMasterDisposablesUseCaseProvider);
  GetCurrentStationUseCase get _getStation => ref.read(getCurrentStationUseCaseProvider);
  MasterWastageUseCase get _wastageUseCase => ref.read(masterWastageUseCaseProvider);
  MasterDestructionUseCase get _destructionUseCase => ref.read(masterDestructionUseCaseProvider);

  @override
  MasterWasteState build() => const MasterWasteUninitialized();

  Future<void> init(StationCabinsContext ctx) async {
    _hospitalization = null;
    _currentStation = ctx.station;

    state = const MasterWasteLoading();

    final stationResult = await _getStation.call();
    stationResult.when(ok: (s) => _currentStation = s, error: (_) => _currentStation = null);

    state = MasterWastePatientSelection();
  }

  Future<void> selectPatient(Hospitalization hospitalization) async {
    _hospitalization = hospitalization;
    state = const MasterWasteLoading();
    await _loadItems();
  }

  Future<void> _loadItems() async {
    final hospitalization = _hospitalization;
    if (hospitalization == null) {
      state = MasterWastePatientSelection();
      return;
    }

    final result = await _getDisposables.call(hospitalization.id ?? 0);
    result.when(
      ok: (items) => state = MasterWasteMedicineSelection(hospitalization: hospitalization, items: items),
      error: (e) => state = MasterWasteError(
        failure: CabinApiFailure(message: e.message),
        previousState: MasterWasteMedicineSelection(hospitalization: hospitalization, items: const []),
      ),
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! MasterWasteMedicineSelection || s.isSubmitting) return;
    state = s.copyWith(search: value);
  }

  void changeType(DisposeType type) {
    final s = state;
    if (s is! MasterWasteMedicineSelection || s.isSubmitting) return;
    state = s.copyWith(type: type);
  }

  void toggleItem(int itemId) {
    final s = state;
    if (s is! MasterWasteMedicineSelection || s.isSubmitting) return;

    final next = Set<int>.from(s.selectedItemIds);
    if (next.contains(itemId)) {
      next.remove(itemId);
      state = s.copyWith(selectedItemIds: next);
      return;
    }

    next.add(itemId);
    final amounts = Map<int, double>.from(s.amounts)..putIfAbsent(itemId, () => 1);
    state = s.copyWith(selectedItemIds: next, amounts: amounts);
  }

  void updateAmount(int itemId, double amount, {void Function(String message)? onFailed}) {
    final s = state;
    if (s is! MasterWasteMedicineSelection || s.isSubmitting) return;

    if (amount <= 0) {
      onFailed?.call(contextlessL10n().waste_error_amountZero);
      return;
    }
    final max = s.maxAmountFor(itemId);
    if (amount > max) {
      onFailed?.call(
        s.type == DisposeType.wastage
            ? contextlessL10n().waste_error_wastageAmountExceeded
            : contextlessL10n().waste_error_destructionAmountExceeded,
      );
      return;
    }

    final amounts = Map<int, double>.from(s.amounts)..[itemId] = amount;
    state = s.copyWith(amounts: amounts);
  }

  void addWitness(int itemId, User user) {
    final s = state;
    if (s is! MasterWasteMedicineSelection) return;

    final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;
    if (currentUserId != null && user.id == currentUserId) return;

    final items = s.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(witnessContext: item.witnessContext.copyWith(witness: user));
      }

      final isSelected = s.selectedItemIds.contains(item.id);
      if (!isSelected || item.witnessContext.witness != null) return item;

      final canWitness =
          item.witnessContext.witnesses.isEmpty || item.witnessContext.witnesses.any((w) => w.id == user.id);
      return canWitness ? item.copyWith(witnessContext: item.witnessContext.copyWith(witness: user)) : item;
    }).toList();

    state = s.copyWith(items: items);
  }

  User? resolveExistingWitness(int itemId) {
    final s = state;
    if (s is! MasterWasteMedicineSelection) return null;
    final target = s.items.firstWhereOrNull((i) => i.id == itemId);
    if (target == null) return null;

    final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;

    for (final item in s.items) {
      if (!s.selectedItemIds.contains(item.id)) continue;
      final w = item.witnessContext.witness;
      if (w == null) continue;
      if (currentUserId != null && w.id == currentUserId) continue;
      final targetWitnesses = target.witnessContext.witnesses;
      final canWitness = targetWitnesses.isEmpty || targetWitnesses.any((x) => x.id == w.id);
      if (canWitness) return w;
    }
    return null;
  }

  Future<void> startWasteOperation({void Function(String message)? onSuccess, required DisposeType type}) async {
    final s = state;
    if (s is! MasterWasteMedicineSelection || !s.canStart) return;

    final selected = s.selectedItems;

    final missingWitness = selected.firstWhereOrNull(
      (it) => it.needsWitness(currentStation: _currentStation) && it.witnessContext.witness == null,
    );
    if (missingWitness != null) {
      state = MasterWasteError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.witnessRequired),
        previousState: s,
      );
      return;
    }

    state = s.copyWith(submittingType: type);

    for (final item in selected) {
      final ok = await _submitOne(item, type, s.amountFor(item.id));
      if (!ok) return;
    }

    onSuccess?.call(contextlessL10n().waste_success_operationCompleted);
    await _loadItems();
  }

  Future<bool> _submitOne(DisposableItem item, DisposeType type, double quantity) async {
    final params = WasteParams(
      prescriptionItemId: item.id,
      witnessId: item.witnessContext.witness?.id,
      quantity: quantity,
    );
    final result = type == DisposeType.wastage
        ? await _wastageUseCase.call(params)
        : await _destructionUseCase.call(params);

    return result.when(
      ok: (_) => true,
      error: (e) {
        final current = state;
        if (current is MasterWasteMedicineSelection) {
          state = MasterWasteError(
            failure: CabinApiFailure(message: e.message),
            previousState: current.copyWith(isSubmitting: false),
          );
        }
        return false;
      },
    );
  }

  void dismissError() {
    final s = state;
    if (s is! MasterWasteError) return;
    final prev = s.previousState;
    state = prev is MasterWasteMedicineSelection ? prev.copyWith(isSubmitting: false) : prev;
  }
}
