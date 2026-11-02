// [SWREQ-CLI-CABINSTOCK-001] [IEC 62304 §5.5]
// Master kabin stok listesi: istasyondaki tüm kabinlerin atamaları (kabin
// seçim adımı yok) + kabin filtresi + arama. Hangi kabinin iç yerleşiminin
// gösterileceği StationCabinScope'tadır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/mixins/mixins.dart';
import '../../../../core/providers/providers.dart';
import '../../../dashboard/dashboard.dart';

final masterCabinStockNotifierProvider = ChangeNotifierProvider.autoDispose<MasterCabinStockNotifier>((ref) {
  return MasterCabinStockNotifier(getAssignments: ref.read(getStationAssignmentsUseCaseProvider));
});

class MasterCabinStockNotifier extends ChangeNotifier with ApiRequestMixin {
  MasterCabinStockNotifier({required GetStationAssignmentsUseCase getAssignments}) : _getAssignments = getAssignments;

  final GetStationAssignmentsUseCase _getAssignments;

  final OperationKey _fetchStocksOp = const OperationKey.custom('fetch-cabin-stocks');
  bool get isFetchingStocks => isLoading(_fetchStocksOp);
  bool get hasFetchError => isFailed(_fetchStocksOp);

  final StationCabinScope scope = StationCabinScope();

  List<MedicineAssignment> _stocks = const [];

  /// İstasyondaki tüm atamalar — filtre/arama uygulanmamış.
  List<MedicineAssignment> get stocks => _stocks;

  /// Kabin filtresi uygulanmış, arama uygulanmamış liste — çıktı bunu basar.
  List<MedicineAssignment> get filteredStocks => scope.filtered(_stocks);

  String _search = '';
  String get search => _search;

  /// Kabin filtresi + arama uygulanmış liste — ekranda gösterilen.
  List<MedicineAssignment> get visibleStocks {
    final byCabin = filteredStocks;
    final q = _search.toLowerCase().trim();
    if (q.isEmpty) return byCabin;
    return byCabin.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  Future<void> init(StationCabinsContext ctx) async {
    scope.attach(ctx);
    if (!scope.hasCabins) return;

    await execute(
      _fetchStocksOp,
      operation: () => _getAssignments.call(),
      onData: (data) {
        _stocks = scope.stationAssignments(data);
        notifyListeners();
      },
    );
  }

  void viewCabin(int cabinId) {
    if (scope.view(cabinId)) notifyListeners();
  }

  void setCabinFilter(int? cabinId) {
    if (scope.setFilter(cabinId)) notifyListeners();
  }

  void onSearchChanged(String value) {
    if (value == _search) return;
    _search = value;
    notifyListeners();
  }
}
