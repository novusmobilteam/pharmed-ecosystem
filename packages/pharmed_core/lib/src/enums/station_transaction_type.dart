import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum StationTransactionType {
  refill(1),
  stockOut(2),
  refund(3),
  countExcess(4),
  countShortage(5),
  countConsistent(6),
  materialPurchasing(7),
  refundInward(8),
  wastage(9),
  unloading(10);

  const StationTransactionType(this.value);

  /// Backend'deki enum değeri; filtrede ve eşleştirmede kullanılır.
  final int value;

  static StationTransactionType? fromValue(int? value) {
    for (final type in values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

extension StationTransactionTypeLabel on StationTransactionType {
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      StationTransactionType.refill => l10n.enumCore_stationTransactionTypeRefill,
      StationTransactionType.stockOut => l10n.enumCore_stationTransactionTypeStockOut,
      StationTransactionType.refund => l10n.enumCore_stationTransactionTypeRefund,
      StationTransactionType.countExcess => l10n.enumCore_stationTransactionTypeCountExcess,
      StationTransactionType.countShortage => l10n.enumCore_stationTransactionTypeCountShortage,
      StationTransactionType.countConsistent => l10n.enumCore_stationTransactionTypeCountConsistent,
      StationTransactionType.materialPurchasing => l10n.enumCore_stationTransactionTypeMaterialPurchasing,
      StationTransactionType.refundInward => l10n.enumCore_stationTransactionTypeRefundInward,
      StationTransactionType.wastage => l10n.enumCore_stationTransactionTypeWastage,
      StationTransactionType.unloading => l10n.enumCore_stationTransactionTypeUnloading,
    };
  }
}
