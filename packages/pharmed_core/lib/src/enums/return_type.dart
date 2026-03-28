/// İade Tipi
enum ReturnType {
  /// Yerine İade
  toOrigin(1),

  /// Çekmeceye İade
  toDrawer(2),

  /// İade Kutusuna İade
  toReturnBox(3),

  /// Eczaneye İade
  toPharmacy(4);

  final int id;

  const ReturnType(this.id);

  static ReturnType? fromId(int? id) {
    return ReturnType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ReturnType.toOrigin,
    );
  }

  String get label {
    switch (this) {
      case ReturnType.toOrigin:
        return "Yerine İade";
      case ReturnType.toDrawer:
        return "Çekmeceye İade";
      case ReturnType.toReturnBox:
        return "İade Kutusuna İade";
      case ReturnType.toPharmacy:
        return "Eczaneye İade";
    }
  }
}
