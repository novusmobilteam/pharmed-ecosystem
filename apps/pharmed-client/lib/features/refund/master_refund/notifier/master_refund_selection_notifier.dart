import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/features/dashboard/dashboard.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/usecase_providers.dart';

final masterRefundSelectionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterRefundSelectionNotifier>((ref) {
  return MasterRefundSelectionNotifier(
    getMasterRefundablesUseCase: ref.read(getMasterRefundablesUseCaseProvider),
    checkMasterRefundStatusUseCase: ref.read(checkMasterRefundStatusUseCaseProvider),
    completeRefundUseCase: ref.read(completeRefundUseCaseProvider),
  );
});

class MasterRefundSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetMasterRefundablesUseCase _getMasterRefundablesUseCase;
  final CheckMasterRefundStatusUseCase _checkMasterRefundStatusUseCase;
  final CompleteRefundUseCase _completeRefundUseCase;

  MasterRefundSelectionNotifier({
    required GetMasterRefundablesUseCase getMasterRefundablesUseCase,
    required CheckMasterRefundStatusUseCase checkMasterRefundStatusUseCase,
    required CompleteRefundUseCase completeRefundUseCase,
  }) : _getMasterRefundablesUseCase = getMasterRefundablesUseCase,
       _checkMasterRefundStatusUseCase = checkMasterRefundStatusUseCase,
       _completeRefundUseCase = completeRefundUseCase;

  final OperationKey fetchRefundablesOp = OperationKey.custom('fetch-refundables');
  final OperationKey checkOp = OperationKey.custom('check-op');
  final OperationKey completeOp = OperationKey.custom('complete-op');
  final OperationKey startRefundOp = OperationKey.custom('start-refund');

  StationCabinsContext? _stationContext;

  List<CabinTargetedPrescriptionItem> _refundables = [];
  List<CabinTargetedPrescriptionItem> get refundables => _refundables;

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  List<CabinTargetedPrescriptionItem> _selectedItems = [];
  List<CabinTargetedPrescriptionItem> get selectedItems => _selectedItems;

  List<RefundTarget> _refundTargets = [];
  List<RefundTarget> get refundTargets => _refundTargets;

  final Map<int, double> _returnQuantities = {};

  /// Hem completeDirectRefund'un (donanımsız) hem startRefund'un (donanımlı)
  /// per-item check/complete durumunu paylaşır — kart üzerindeki tek bir
  /// "bu item şu an işleniyor" göstergesine karşılık gelir, ikisi aynı anda
  /// aynı item üzerinde tetiklenemeyeceği için çakışma riski yok.
  final Map<int, RefundCheckStatus> _itemStatuses = {};
  Map<int, RefundCheckStatus> get itemStatuses => _itemStatuses;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool get isError => isFailed(fetchRefundablesOp);

  bool get isStartingRefund => isLoading(startRefundOp);

  num amountFor(int itemId) {
    final item = _refundables.firstWhereOrNull((it) => it.id == itemId);
    return _returnQuantities[itemId] ?? item?.dosePiece ?? 0;
  }

  /// Uygulanmış dozdan (item.dosePiece) fazlası iade edilemez.
  num maxAmountFor(int itemId) {
    final item = _refundables.firstWhereOrNull((it) => it.id == itemId);
    return item?.dosePiece ?? 0;
  }

  void init(StationCabinsContext ctx) {
    _stationContext = ctx;
  }

  MedicineAssignment? _resolveReturnDrawerAssignment(RefundableItem checkedItem) {
    final ctx = _stationContext;
    if (ctx == null) return null;

    for (final data in ctx.cabinDataByCabinId.values) {
      final group = data.groups.firstWhereOrNull((g) => g.isReturnDrawer);
      if (group == null) continue;
      final unit = group.units.firstOrNull;
      if (unit == null) continue;

      final resolvedUnit = unit.drawerSlot == null ? unit.copyWith(drawerSlot: group.slot) : unit;
      final matchingStock = data.stocks.firstWhereOrNull((s) => s.cabinDrawerId == unit.id);
      final detail = matchingStock?.cabinDrawerDetail;

      return MedicineAssignment.empty(cabinDrawerId: unit.id ?? 0).copyWith(
        drawerUnit: resolvedUnit,
        medicine: checkedItem.medicine,
        cabinDrawerDetail: detail != null ? [detail] : null,
      );
    }
    return null;
  }

  void clearSelection() {
    _selectedHospitalization = null;
    _refundables.clear();
    _selectedItems.clear;
    notifyListeners();
  }

  void selectHospitalization(Hospitalization hosp) {
    if (_selectedHospitalization?.id == hosp.id) {
      _selectedHospitalization = null;
      _refundables.clear();
      _selectedItems = [];
      notifyListeners();
      return;
    }
    _selectedHospitalization = hosp;
    _selectedItems = [];
    notifyListeners();
    _getRefundables();
  }

  Future<void> _getRefundables() async {
    if (_selectedHospitalization == null) return;
    final id = _selectedHospitalization!.id ?? 0;

    await execute(
      fetchRefundablesOp,
      operation: () => _getMasterRefundablesUseCase.call(id),
      onData: (refundables) {
        _refundables = refundables;
        notifyListeners();
      },
    );
  }

  void selectRefundableItem(CabinTargetedPrescriptionItem item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
      notifyListeners();
      return;
    }
    _selectedItems.add(item);
    notifyListeners();
  }

  void updateAmount(int itemId, double amount, {void Function(String message)? onFailed}) {
    if (amount <= 0) {
      onFailed?.call(contextlessL10n().refund_error_amountZero);
      return;
    }
    final max = maxAmountFor(itemId);
    if (amount > max) {
      onFailed?.call(contextlessL10n().refund_error_amountExceeded);
      return;
    }
    _returnQuantities[itemId] = amount;
    notifyListeners();
  }

  /// Kart üzerindeki "İade Et" butonundan çağrılır — check + complete'i
  /// arka arkaya, donanıma hiç dokunmadan yürütür. Yalnızca
  /// requiresCabinHardware=false tipler (toPharmacy/toReturnBox) için.
  Future<void> completeDirectRefund(int itemId, {Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    final item = _refundables.firstWhereOrNull((it) => it.id == itemId);
    if (item == null) return;

    final quantity = amountFor(itemId);
    final drug = item.medicine?.when(drug: (d) => d, consumable: (_) => null);
    final returnType = drug?.returnType;

    if (item.medicine?.id == null || returnType == null) {
      onFailed?.call(contextlessL10n().refund_error_genericCheckFailed);
      return;
    }

    _itemStatuses[itemId] = const RefundCheckLoading();
    notifyListeners();

    final refundableItem = RefundableItem(source: item, appliedQuantity: item.dosePiece, returnQuantity: quantity);
    RefundableItem? checkedItem;

    await execute(
      checkOp,
      operation: () => _checkMasterRefundStatusUseCase.call(
        item: refundableItem,
        returnType: returnType,
        quantity: quantity.toDouble(),
      ),
      onFailed: (error) {
        _itemStatuses.remove(itemId);
        notifyListeners();
        onFailed?.call(error.message);
      },
      onData: (data) => checkedItem = data,
    );

    await executeVoid(
      completeOp,
      operation: () => _completeRefundUseCase.call(
        CompleteRefundParams(
          type: checkedItem!.returnType!,
          id: checkedItem!.id,
          quantity: (checkedItem!.returnQuantity ?? checkedItem!.appliedQuantity).toDouble(),
          cabinDrawerDetailId: checkedItem!.source.stock?.cabinDrawerDetailId,
        ),
      ),
      onFailed: (error) {
        _itemStatuses.remove(itemId);
        notifyListeners();
        onFailed?.call(error.message);
      },
      onSuccess: () {
        _itemStatuses.remove(itemId);
        onSuccess?.call();
        _getRefundables();
      },
    );
  }

  /// "İadeyi Başlat" — checkbox'la seçilmiş (zaten hep donanımlı) item'lar
  /// için check koşturur, execution'a devredilecek RefundTarget listesini
  /// üretir. Başarıyla bitince `onSuccess` çağrılır — View bunu execution
  /// notifier'ının `start(refundTargets)`'ını tetiklemek için kullanır.
  /// Herhangi bir item'da hata olursa `_refundTargets` TAMAMEN temizlenir —
  /// yarım kalmış bir listeyle asla execution'a geçilmemeli.
  Future<void> startRefund({Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    if (_selectedItems.isEmpty) return;

    _refundTargets = [];
    notifyListeners();

    for (final item in _selectedItems) {
      final quantity = amountFor(item.id);
      final drug = item.medicine?.when(drug: (d) => d, consumable: (_) => null);
      final returnType = drug?.returnType;

      if (item.medicine?.id == null || returnType == null) {
        _refundTargets = [];
        onFailed?.call(contextlessL10n().refund_error_genericCheckFailed);
        notifyListeners();
        return;
      }

      _itemStatuses[item.id] = const RefundCheckLoading();
      notifyListeners();

      final refundableItem = RefundableItem(source: item, appliedQuantity: item.dosePiece, returnQuantity: quantity);

      var itemFailed = false;

      await execute(
        startRefundOp,
        operation: () => _checkMasterRefundStatusUseCase.call(
          item: refundableItem,
          returnType: returnType,
          quantity: quantity.toDouble(),
        ),
        onData: (checked) {
          var resolved = checked;
          if (resolved.returnType == ReturnType.toDrawer) {
            final assignment = _resolveReturnDrawerAssignment(resolved);
            if (assignment == null) {
              itemFailed = true;
              _itemStatuses[item.id] = RefundCheckFailed(
                message: contextlessL10n().refund_error_returnDrawerNotDefined,
              );
              return;
            }
            resolved = resolved.copyWith(resolvedTarget: assignment);
          }
          _itemStatuses[item.id] = const RefundCheckSuccess();
          _refundTargets.add(
            RefundTarget(item: resolved, isReturnDrawerTarget: resolved.returnType == ReturnType.toDrawer),
          );
          notifyListeners();
        },
        onFailed: (error) {
          itemFailed = true;
          _itemStatuses[item.id] = RefundCheckFailed(message: error.message);
        },
      );

      if (itemFailed) {
        final message = (_itemStatuses[item.id] as RefundCheckFailed?)?.message;
        _refundTargets = [];
        notifyListeners();
        onFailed?.call(message);
        return;
      }
    }

    onSuccess?.call();
  }

  /// Execution kuyruğu bitince (View'dan çağrılır) listeyi tazeler, seçim
  /// ve handoff state'ini sıfırlar.
  Future<void> refreshAfterExecution() async {
    _selectedItems = [];
    _refundTargets = [];
    await _getRefundables();
  }
}
