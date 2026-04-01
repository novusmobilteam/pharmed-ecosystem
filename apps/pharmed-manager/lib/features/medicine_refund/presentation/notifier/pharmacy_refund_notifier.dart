import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../../core/widgets/unified_table/unified_table_models.dart';

class PharmacyRefundNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Refund> {
  final GetPharmacyRefundsUseCase _getPharmacyRefundsUseCase;
  final CompletePharmacyRefundUseCase _completePharmacyRefundUseCase;
  final DeletePharmacyRefundUseCase _deletePharmacyRefundUseCase;

  PharmacyRefundNotifier({
    required GetPharmacyRefundsUseCase getPharmacyRefundsUseCase,
    required CompletePharmacyRefundUseCase completePharmacyRefundUseCase,
    required DeletePharmacyRefundUseCase deletePharmacyRefundUseCase,
  }) : _getPharmacyRefundsUseCase = getPharmacyRefundsUseCase,
       _completePharmacyRefundUseCase = completePharmacyRefundUseCase,
       _deletePharmacyRefundUseCase = deletePharmacyRefundUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();
  OperationKey completeOp = OperationKey.create();

  bool get isFetching => isLoading(fetchOp);

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  void selectCategory(String id) {
    if (_selectedCategoryId == id) return;
    _selectedCategoryId = id;
    notifyListeners();
  }

  List<Station> get _stations {
    final map = <int, Station>{};
    for (final refund in allItems) {
      final s = refund.station;
      if (s?.id != null) map[s!.id!] = s;
    }
    return map.values.toList();
  }

  List<TableSideCategory> get tableCategories => _stations
      .map(
        (s) => TableSideCategory(
          id: s.id!.toString(),
          label: s.name ?? 'İsimsiz İstasyon',
          count: allItems.where((r) => r.station?.id == s.id).length,
        ),
      )
      .toList();

  List<Refund> get categoryFilteredItems {
    final id = int.tryParse(_selectedCategoryId ?? '');
    if (id == null) return filteredItems;
    return filteredItems.where((r) => r.station?.id == id).toList();
  }

  String? _description;
  set description(String? value) {
    _description = value;
    notifyListeners();
  }

  Future<void> getRefunds() async {
    await execute(
      fetchOp,
      operation: () => _getPharmacyRefundsUseCase.call(),
      onData: (refunds) {
        allItems = refunds;
        // İlk istasyonu varsayılan seç
        final firstId = _stations.firstOrNull?.id?.toString();
        if (firstId != null) _selectedCategoryId = firstId;
        notifyListeners();
      },
    );
  }

  void deleteRefund(Refund refund, {Function(String?)? onSuccess, Function(String?)? onFailed}) async {
    final id = refund.id;
    if (id == null) {
      onFailed?.call('Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz');
      return;
    }
    await executeVoid(
      deleteOp,
      operation: () => _deletePharmacyRefundUseCase.call(DeletePharmacyRefundParams(id: id, description: _description)),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('Silme işlemi başarıyla tamamlandı.');
        getRefunds();
      },
    );
  }

  void completeRefund(Refund refund, {Function(String?)? onSuccess, Function(String?)? onFailed}) async {
    final id = refund.id;
    if (id == null) {
      onFailed?.call('Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz');
      return;
    }
    await executeVoid(
      completeOp,
      operation: () => _completePharmacyRefundUseCase.call(id),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call('İade alma işlemi başarıyla tamamlandı.');
        getRefunds();
      },
    );
  }
}
