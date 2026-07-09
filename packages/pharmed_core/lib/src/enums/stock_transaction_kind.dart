import 'package:collection/collection.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum StockTransactionKind {
  refill(1),
  stockOut(2),
  refund(3),
  censusExcess(4),
  censusShortage(5),
  censusConsistent(6),
  intake(7),
  returnInward(8),
  wastage(9),
  unload(10);

  final int id;

  const StockTransactionKind(this.id);

  static StockTransactionKind? fromId(int? value) {
    if (value == null) return null;
    return StockTransactionKind.values.firstWhereOrNull((e) => e.id == value);
  }

  String get label {
    switch (this) {
      case StockTransactionKind.refill:
        return contextlessL10n().enumCore_stockTxKindRefill;
      case StockTransactionKind.stockOut:
        return contextlessL10n().enumCore_stockTxKindStockOut;
      case StockTransactionKind.refund:
        return contextlessL10n().enumCore_stockTxKindReturn;
      case StockTransactionKind.censusExcess:
        return contextlessL10n().enumCore_stockTxKindExcess;
      case StockTransactionKind.censusShortage:
        return contextlessL10n().enumCore_stockTxKindShortage;
      case StockTransactionKind.censusConsistent:
        return contextlessL10n().enumCore_stockTxKindConsistent;
      case StockTransactionKind.intake:
        return contextlessL10n().enumCore_stockTxKindPurchase;
      case StockTransactionKind.returnInward:
        return contextlessL10n().enumCore_stockTxKindReturnInward;
      case StockTransactionKind.wastage:
        return contextlessL10n().enumCore_stockTxKindWastage;
      case StockTransactionKind.unload:
        return contextlessL10n().enumCore_stockTxKindUnload;
    }
  }
}
