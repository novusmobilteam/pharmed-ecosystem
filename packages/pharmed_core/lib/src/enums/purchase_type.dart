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
        return 'Orderlı';
      case PurchaseType.orderless:
        return 'Ordersız';
      case PurchaseType.both:
        return 'Her İkisi de';
    }
  }
}
