import 'package:collection/collection.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum StockTransactionType {
  entry(1),
  exit(2);

  final int id;

  const StockTransactionType(this.id);

  String get label {
    switch (this) {
      case StockTransactionType.entry:
        return contextlessL10n().enumCore_stockTxTypeIn;
      case StockTransactionType.exit:
        return contextlessL10n().enumCore_stockTxTypeOut;
    }
  }

  static StockTransactionType? fromId(int? value) {
    if (value == null) return null;
    return StockTransactionType.values.firstWhereOrNull(
      (e) => e.id == value,
    );
  }
}
