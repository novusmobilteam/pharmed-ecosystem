import 'package:collection/collection.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum StockTransactionKind {
  materialPurchasing(1),
  excessStock(2),
  insufficientStock(3),
  materialRefund(4),
  counting(5),
  materialUse(6);

  final int id;

  const StockTransactionKind(this.id);

  static StockTransactionKind? fromId(int? value) {
    if (value == null) return null;
    return StockTransactionKind.values.firstWhereOrNull((e) => e.id == value);
  }

  String get label {
    switch (this) {
      case StockTransactionKind.materialPurchasing:
        return contextlessL10n().enumCore_stockTxKindPurchase;

      // Fazla ve Eksik stok bildirimi
      case StockTransactionKind.excessStock:
        return contextlessL10n().enumCore_stockTxKindExcess;
      case StockTransactionKind.insufficientStock:
        return contextlessL10n().enumCore_stockTxKindShortage;

      case StockTransactionKind.materialRefund:
        return contextlessL10n().enumCore_stockTxKindReturn;

      case StockTransactionKind.counting:
        return contextlessL10n().enumCore_stockTxKindCensus;

      case StockTransactionKind.materialUse:
        return contextlessL10n().enumCore_stockTxKindUsage;
    }
  }
}
