import 'package:pharmed_core/pharmed_core.dart';

sealed class MasterCabinStockState {
  const MasterCabinStockState();
}

final class MasterCabinStockUninitialized extends MasterCabinStockState {
  const MasterCabinStockUninitialized();
}

final class MasterCabinStockLoading extends MasterCabinStockState {
  const MasterCabinStockLoading();
}

final class MasterCabinStockIdle extends MasterCabinStockState {
  const MasterCabinStockIdle({required this.cabinId, this.search = '', this.stocks = const []});

  final int cabinId;
  final String search;
  final List<MedicineAssignment> stocks;

  MasterCabinStockIdle copyWith({List<MedicineAssignment>? stocks, Set<int>? selectedUnitIds, String? search}) {
    return MasterCabinStockIdle(cabinId: cabinId, search: search ?? this.search, stocks: stocks ?? this.stocks);
  }

  List<MedicineAssignment> get visibleStocks {
    if (search.trim().isEmpty) return stocks;
    final q = search.toLowerCase().trim();
    return stocks.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }
}

final class MasterCabinStockError extends MasterCabinStockState {
  const MasterCabinStockError({required this.previousState, this.isQueueError = false});

  final MasterCabinStockState previousState;
  final bool isQueueError;
}
