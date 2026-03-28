import '../../../warehouse/domain/entity/warehouse.dart';
import 'stock_transaction.dart';

extension StockTransactionListX on List<StockTransaction> {
  List<Warehouse> get toUniqueWarehouses {
    final warehouseMap = <int, Warehouse>{};
    for (final ts in this) {
      if (ts.warehouse?.id != null) {
        warehouseMap[ts.warehouse!.id!] = ts.warehouse!;
      }
    }
    return warehouseMap.values.toList();
  }
}
