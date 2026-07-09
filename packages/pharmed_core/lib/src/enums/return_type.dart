import 'package:pharmed_ui/pharmed_ui.dart';

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
        return contextlessL10n().enumCore_returnTypeToOrigin;
      case ReturnType.toDrawer:
        return contextlessL10n().enumCore_returnTypeToDrawer;
      case ReturnType.toReturnBox:
        return contextlessL10n().enumCore_returnTypeToReturnBox;
      case ReturnType.toPharmacy:
        return contextlessL10n().enumCore_returnTypeToPharmacy;
    }
  }
}
