import 'package:collection/collection.dart';

enum StockTransactionType {
  entry(1),
  exit(2);

  final int id;

  const StockTransactionType(this.id);

  String get label {
    switch (this) {
      case StockTransactionType.entry:
        return 'Stok Giriş';
      case StockTransactionType.exit:
        return 'Stok Çıkış';
    }
  }

  static StockTransactionType? fromId(int? value) {
    if (value == null) return null;
    return StockTransactionType.values.firstWhereOrNull(
      (e) => e.id == value,
    );
  }
}
