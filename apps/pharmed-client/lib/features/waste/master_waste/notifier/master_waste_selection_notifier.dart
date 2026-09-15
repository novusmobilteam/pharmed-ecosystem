import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/providers.dart';
import '../../../auth/auth.dart';
import '../../../dashboard/dashboard.dart';
import 'waste_medicine_group.dart';

// [SWREQ-CLI-MWASTE-002] [IEC 62304 §5.5]
// İlaç-merkezli master kabin FİRE/İMHA akışını yöneten ChangeNotifier.
//
// Donanım/çekmece kuyruğu YOKTUR — "Fire Et"/"İmha Et" İLAÇ (grup) bazında,
// o grupta seçili kalemleri sırayla API'ye gönderir (bkz. skill
// master-cabin-operations §6: fire/imha ayrı bir Executing fazı kullanmaz).
// Şahit atama mantığı MasterIntakeNotifier.addWitness/resolveExistingWitness
// ile birebir aynıdır (WitnessContext üzerinden, bkz. skill patient-gateway).
//
// Sınıf: Class B

enum DisposeType { wastage, destruction }

extension DisposeTypeX on DisposeType {
  String localizedLabel(BuildContext context) => switch (this) {
    DisposeType.wastage => context.l10n.waste_action_wastage,
    DisposeType.destruction => context.l10n.waste_action_destruction,
  };
}

final masterWasteSelectionNotifierProvider = ChangeNotifierProvider<MasterWasteNotifier>((ref) {
  return MasterWasteNotifier(
    ref: ref,
    getDisposables: ref.read(getMasterDisposablesUseCaseProvider),
    getStation: ref.read(getCurrentStationUseCaseProvider),
    wastage: ref.read(masterWastageUseCaseProvider),
    destruction: ref.read(masterDestructionUseCaseProvider),
  );
});

class MasterWasteNotifier extends ChangeNotifier with ApiRequestMixin {
  MasterWasteNotifier({
    required Ref ref,
    required GetMasterDisposablesUseCase getDisposables,
    required GetCurrentStationUseCase getStation,
    required MasterWastageUseCase wastage,
    required MasterDestructionUseCase destruction,
  }) : _ref = ref,
       _getDisposables = getDisposables,

       _wastage = wastage,
       _destruction = destruction;

  final Ref _ref;
  final GetMasterDisposablesUseCase _getDisposables;

  final MasterWastageUseCase _wastage;
  final MasterDestructionUseCase _destruction;

  final OperationKey fetchDisposablesOp = OperationKey.custom('fetch-disposables');
  final OperationKey submitOp = OperationKey.submit();
  bool get isSubmitting => isLoading(submitOp);

  Station? _currentStation;

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  List<DisposableItem> _disposables = [];
  List<DisposableItem> get disposables => _disposables;

  List<WasteMedicineGroup> get groups => WasteMedicineGroup.groupByMedicineName(_disposables);

  final Set<int> _selectedItemIds = {};
  Set<int> get selectedItemIds => Set.unmodifiable(_selectedItemIds);
  bool isSelected(int itemId) => _selectedItemIds.contains(itemId);

  final Map<int, double> _wasteQuantities = {};

  // Bu hospitalization seçimi süresince giriş yapmış (login olmuş) tüm şahitler.
  // Item id'leri fetch'ler arası KARARLI olmayabileceği için (backend disposed
  // item'ları düşürüp kalanları yeniden hesaplayabilir), şahit ataması id eşleşmesiyle
  // değil, her fetch sonrası bu havuz item'lara YENİDEN uygulanarak korunur.
  final List<User> _confirmedWitnesses = [];

  bool _canWitnessItem(DisposableItem item, User user) {
    final witnesses = item.witnessContext.witnesses;
    return witnesses.isEmpty || witnesses.any((w) => w.id == user.id);
  }

  num amountFor(int itemId) {
    final item = _disposables.firstWhereOrNull((it) => it.id == itemId);
    return _wasteQuantities[itemId] ?? item?.dosePiece ?? 0;
  }

  /// Uygulanmış dozdan (item.dosePiece) fazlası fire/imha edilemez.
  num maxAmountFor(int itemId) {
    final item = _disposables.firstWhereOrNull((it) => it.id == itemId);
    return item?.dosePiece ?? 0;
  }

  String? _submittingGroupName;
  DisposeType? _submittingType;

  bool isGroupSubmitting(String groupName, DisposeType type) =>
      isSubmitting && _submittingGroupName == groupName && _submittingType == type;

  Future<void> init(StationCabinsContext ctx) async {
    _currentStation = ctx.station;
  }

  void clearSelection() {
    _selectedHospitalization = null;
    _disposables.clear();
    _selectedItemIds.clear();
    _wasteQuantities.clear();
    notifyListeners();
  }

  void selectHospitalization(Hospitalization hosp) {
    if (_selectedHospitalization?.id == hosp.id) {
      clearSelection();
      return;
    }
    _selectedHospitalization = hosp;
    _selectedItemIds.clear();
    _wasteQuantities.clear();
    notifyListeners();
    _fetch();
  }

  Future<void> _fetch() async {
    if (_selectedHospitalization == null) return;
    final id = _selectedHospitalization!.id ?? 0;

    await execute(
      fetchDisposablesOp,
      operation: () => _getDisposables.call(id),
      onData: (items) {
        _disposables = _applyConfirmedWitnesses(items);
        notifyListeners();
      },
    );
  }

  void toggleItem(int itemId) {
    if (isSubmitting) return;
    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
    } else {
      _selectedItemIds.add(itemId);
    }
    notifyListeners();
  }

  void updateAmount(int itemId, double amount, {void Function(String message)? onFailed}) {
    if (isSubmitting) return;
    if (amount <= 0) {
      onFailed?.call(contextlessL10n().waste_error_amountZero);
      return;
    }
    final max = maxAmountFor(itemId);
    if (amount > max) {
      onFailed?.call(contextlessL10n().waste_error_wastageAmountExceeded);
      return;
    }
    _wasteQuantities[itemId] = amount;
    notifyListeners();
  }

  bool itemNeedsWitness(DisposableItem item) => item.needsWitness(currentStation: _currentStation);

  void addWitness(int itemId, User user) {
    final currentUserId = _ref.read(authNotifierProvider.notifier).currentUser?.id;
    if (currentUserId != null && user.id == currentUserId) return;

    if (!_confirmedWitnesses.any((w) => w.id == user.id)) {
      _confirmedWitnesses.add(user);
    }

    _disposables = _applyConfirmedWitnesses(_disposables);
    notifyListeners();
  }

  User? resolveExistingWitness(int itemId) {
    final target = _disposables.firstWhereOrNull((i) => i.id == itemId);
    if (target == null) return null;
    return _confirmedWitnesses.firstWhereOrNull((w) => _canWitnessItem(target, w));
  }

  Future<void> disposeGroup(
    WasteMedicineGroup group,
    DisposeType type, {
    VoidCallback? onSuccess,
    void Function(String message)? onFailed,
  }) async {
    if (isSubmitting) return;

    final selected = group.items.where((i) => _selectedItemIds.contains(i.id)).toList();
    if (selected.isEmpty) return; // buton zaten disabled ama savunma amaçlı

    _submittingGroupName = group.name;
    _submittingType = type;
    notifyListeners();

    var successCount = 0;
    String? failureMessage;

    for (final item in selected) {
      var succeeded = false;

      await _submitOne(
        item,
        type,
        onSuccess: () {
          succeeded = true;
          _selectedItemIds.remove(item.id);
          _wasteQuantities.remove(item.id);
        },
        onFailed: (message) => failureMessage = message,
      );

      if (succeeded) {
        successCount++;
      } else {
        break; // İlk hatada kuyruğu durdur — kalan seçili item'lara dokunma.
      }
    }

    _submittingGroupName = null;
    _submittingType = null;
    notifyListeners();

    // En az bir başarılı gönderim olduysa liste artık sunucuyla senkron değildir —
    // item başına DEĞİL, döngü bitince TEK seferde yeniden çekilir.
    if (successCount > 0) {
      await _fetch();
    }

    if (failureMessage != null) {
      onFailed?.call(failureMessage!);
    } else {
      onSuccess?.call();
    }
  }

  Future<void> _submitOne(
    DisposableItem item,
    DisposeType type, {
    VoidCallback? onSuccess,
    void Function(String message)? onFailed,
  }) async {
    final params = WasteParams(
      prescriptionItemId: item.id,
      witnessId: item.witnessContext.witness?.id,
      quantity: amountFor(item.id).toDouble(),
    );

    await executeVoid(
      submitOp,
      operation: () => type == DisposeType.wastage ? _wastage.call(params) : _destruction.call(params),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call(),
    );
  }

  List<DisposableItem> _applyConfirmedWitnesses(List<DisposableItem> items) {
    if (_confirmedWitnesses.isEmpty) return items;

    return items.map((item) {
      if (item.witnessContext.witness != null) return item;
      if (!itemNeedsWitness(item)) return item;

      final matching = _confirmedWitnesses.firstWhereOrNull((w) => _canWitnessItem(item, w));
      if (matching == null) return item;

      return item.copyWith(witnessContext: item.witnessContext.copyWith(witness: matching));
    }).toList();
  }
}
