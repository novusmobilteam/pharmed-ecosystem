import 'package:collection/collection.dart';

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
    return StockTransactionKind.values.firstWhereOrNull(
      (e) => e.id == value,
    );
  }

  String get label {
    switch (this) {
      case StockTransactionKind.materialPurchasing:
        return 'Malzeme Alımı';
      case StockTransactionKind.excessStock:
        return 'Stok Fazlası';
      case StockTransactionKind.insufficientStock:
        return 'Stok Eksiği';
      case StockTransactionKind.materialRefund:
        return 'Malzeme İadesi';
      case StockTransactionKind.counting:
        return 'Sayım';
      case StockTransactionKind.materialUse:
        return 'Malzeme Kullanımı';
    }
  }
}
