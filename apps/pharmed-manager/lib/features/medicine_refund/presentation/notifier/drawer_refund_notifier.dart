import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/refund.dart';
import '../../domain/usecase/get_drawer_refunds_usecase.dart';

import '../../../../core/widgets/unified_table/unified_table_models.dart';

class DrawerRefundNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Refund> {
  final GetDrawerRefundsUseCase _getDrawerRefundsUseCase;

  DrawerRefundNotifier({required GetDrawerRefundsUseCase getDrawerRefundsUseCase})
    : _getDrawerRefundsUseCase = getDrawerRefundsUseCase;

  OperationKey fetchOp = OperationKey.fetch();

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

  Future<void> getRefunds() async {
    await execute(
      fetchOp,
      operation: () => _getDrawerRefundsUseCase.call(),
      onData: (refunds) {
        allItems = refunds;
        final firstId = _stations.firstOrNull?.id?.toString();
        if (firstId != null) _selectedCategoryId = firstId;
        notifyListeners();
      },
    );
  }
}
