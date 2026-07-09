import 'package:pharmed_ui/pharmed_ui.dart';

/// Alım Tipi
enum PurchaseType {
  ordered(1), // Orderlı
  orderless(2), // Ordersız
  both(3); // Her İkisi sde

  final int id;

  const PurchaseType(this.id);

  static PurchaseType fromId(int? id) {
    return PurchaseType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PurchaseType.ordered,
    );
  }

  String get label {
    switch (this) {
      case PurchaseType.ordered:
        return contextlessL10n().patientPicker_orderedToggleLabel;
      case PurchaseType.orderless:
        return contextlessL10n().patientPicker_orderlessToggleLabel;
      case PurchaseType.both:
        return contextlessL10n().enumCore_purchaseTypeBoth;
    }
  }
}
