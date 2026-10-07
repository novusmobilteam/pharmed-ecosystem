import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/mixins/mixins.dart';
import '../../../../core/providers/providers.dart';
import '../../../dashboard/dashboard.dart';

final masterCabinStockNotifierProvider = ChangeNotifierProvider.autoDispose<MasterCabinStockNotifier>((ref) {
  return MasterCabinStockNotifier(getAssignments: ref.read(getCabinAssignmentsWitCabinUseCaseProvider));
});

/// Master kabin stok listesi: seçili kabinin atamaları + arama.
class MasterCabinStockNotifier extends ChangeNotifier with ApiRequestMixin {
  MasterCabinStockNotifier({required GetCabinAssignmentsWithCabinUseCase getAssignments})
    : _getAssignments = getAssignments;

  final GetCabinAssignmentsWithCabinUseCase _getAssignments;

  final OperationKey _fetchStocksOp = const OperationKey.custom('fetch-cabin-stocks');
  bool get isFetchingStocks => isLoading(_fetchStocksOp);
  bool get hasFetchError => isFailed(_fetchStocksOp);

  int? _cabinId;
  int? get cabinId => _cabinId;

  List<MedicineAssignment> _stocks = const [];

  /// Kabindeki tüm atamalar — arama uygulanmamış.
  List<MedicineAssignment> get stocks => _stocks;

  String _search = '';
  String get search => _search;

  /// Arama uygulanmış liste — ekranda gösterilen.
  List<MedicineAssignment> get visibleStocks {
    final q = _search.toLowerCase().trim();
    if (q.isEmpty) return _stocks;
    return _stocks.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  Future<void> init(CabinRouteContext ctx) async {
    final cabinId = ctx.cabin?.id;
    if (cabinId == null) return;
    _cabinId = cabinId;

    await execute(
      _fetchStocksOp,
      operation: () => _getAssignments.call(cabinId),
      onData: (data) {
        _stocks = data;
        notifyListeners();
      },
    );
  }

  void onSearchChanged(String value) {
    if (value == _search) return;
    _search = value;
    notifyListeners();
  }
}
