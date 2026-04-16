import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/medicine_withdraw/domain/mapper/medicine_withdraw_item_mapper.dart';

import '../../../../core/core.dart';

import '../../../medicine_management/domain/entity/cabin_operation_item.dart';

class MedicineRefundNotifier extends ChangeNotifier with ApiRequestMixin {
  Hospitalization? _hospitalization;
  final GetRefundablesUseCase _getRefundablesUseCase;
  final CheckRefundStatusUseCase _checkRefundStatusUseCase;
  final CompleteRefundUseCase _completeRefundUseCase;

  final Future<void> Function(MedicineRefundNotifier notifier, MedicineAssignment assignment) onCheckCompleted;

  MedicineRefundNotifier({
    required Hospitalization hospitalization,
    required GetRefundablesUseCase getRefundablesUseCase,
    required CheckRefundStatusUseCase checkRefundStatusUseCase,
    required CompleteRefundUseCase completeRefundUseCase,
    required this.onCheckCompleted,
  }) : _getRefundablesUseCase = getRefundablesUseCase,
       _checkRefundStatusUseCase = checkRefundStatusUseCase,
       _completeRefundUseCase = completeRefundUseCase,
       _hospitalization = hospitalization;

  // Operation Keys
  OperationKey fetchOp = OperationKey.fetch();
  OperationKey checkOp = OperationKey.custom('check');
  OperationKey layoutOp = OperationKey.custom('layout');
  OperationKey assignmentOp = OperationKey.custom('assignment');
  OperationKey submitOp = OperationKey.submit();

  // Getters
  bool get isFetching => isLoading(fetchOp);
  bool get isEmpty => _items.isEmpty;

  // Data
  List<CabinOperationItem> _items = [];
  List<CabinOperationItem> get items => _items;

  CabinOperationItem? _selectedItem;
  CabinOperationItem? get selectedItem => _selectedItem;

  List<CabinOperationItem> get completedItems => _items.where((item) => _completedItemIds.contains(item.id)).toList();

  Set<int> _completedItemIds = {};

  String? get refundNote => _selectedItem?.medicine is Drug ? (_selectedItem?.medicine as Drug?)?.returnNote : null;

  ReturnType get type => (_selectedItem?.medicine as Drug?)?.returnType ?? ReturnType.toReturnBox;

  List<DrawerGroup> _drawers = [];
  List<DrawerGroup> get drawers => _drawers;

  MedicineWithdrawItem? _currentItem;
  MedicineWithdrawItem? get currentItem => _currentItem;

  List<MedicineAssignment> _assignments = [];
  List<MedicineAssignment> get assignments => _assignments;

  double? _refundAmount;
  double? get refundAmount {
    if (_refundAmount != null) return _refundAmount;
    return _selectedItem?.dosePiece;
  }

  void getRefundables() async {
    await execute(
      fetchOp,
      operation: () => _getRefundablesUseCase.call(_hospitalization?.id ?? 0),
      onData: (data) {
        _items = (data).map((e) => e.toCabinOperationItem()).toList();
        notifyListeners();
      },
    );
  }

  void checkRefundStatus({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    final id = _selectedItem?.id;
    final medicineId = _selectedItem?.medicine?.id;
    final quantity = refundAmount;

    if (id == null || quantity == null || medicineId == null) {
      onFailed?.call('Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.');
      return;
    }

    await execute(
      checkOp,
      operation: () => _checkRefundStatusUseCase.call(
        CheckRefundStatusParams(id: id, quantity: quantity, returnType: type, medicineId: medicineId),
      ),
      onData: (item) {
        // 1. Durum: Donanım işlemi gerekiyor (toDrawer veya toOrigin)
        if (item != null) {
          _currentItem = item;

          notifyListeners();
          onCheckCompleted(this, item.cabinAssignment);
          return;
        }

        // 2. Durum: Donanım gerektirmeyen tipler (toPharmacy, toReturnBox)
        completeRefund(onFailed: onFailed, onSuccess: onSuccess);
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  void completeRefund({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    final id = _selectedItem?.id;
    final quantity = refundAmount;

    if (id == null || quantity == null) {
      onFailed?.call('Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.');
      return;
    }

    await executeVoid(
      submitOp,
      operation: () => _completeRefundUseCase.call(
        CompleteRefundParams(
          type: _selectedItem?.medicine?.returnType ?? ReturnType.toReturnBox,
          id: id,
          quantity: quantity,
          cabinDrawerDetailId: _currentItem?.stock?.cabinDrawerDetailId,
        ),
      ),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İade işlemi başarıyla tamamlandı.');
        _completeProcess();
      },
    );
  }

  void _completeProcess() {
    if (_selectedItem == null) return;
    _completedItemIds.add(_selectedItem!.id);
    _selectedItem = null;
    notifyListeners();
    getRefundables();
  }

  void selectItem(CabinOperationItem item) {
    _selectedItem = item;
    notifyListeners();
  }

  void changeAmount(String? value, {Function(String msg)? onFailed}) {
    if (value == null) return;
    final parsed = double.tryParse(value);
    if (parsed == null) return;

    final dosePiece = _selectedItem?.dosePiece;

    if (parsed > (dosePiece ?? 1000000)) {
      onFailed?.call('İade edilecek miktar alım miktarından fazla olamaz');
      return;
    }

    if (parsed <= 0.0) {
      onFailed?.call('İade miktarı 0 olamaz');
      return;
    }

    _refundAmount = parsed;
    notifyListeners();
  }
}
