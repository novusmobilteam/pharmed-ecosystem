import 'package:pharmed_ui/pharmed_ui.dart';

/// Dolum Listesi Tip
/// Ekranda yer alan min, max, kritik radio buttonları. İstek atılırken de kullanılıyor.
enum RefillType {
  all(4),
  max(3), //  Stok maksimum seviyenin altına düşmüşse
  min(1), // Stok minimum seviyenin altına düşmüşse
  critic(2); // Stok kritik seviyenin altına düşmüşse

  final int id;

  const RefillType(this.id);

  static RefillType fromId(int? id) {
    return RefillType.values.firstWhere((e) => e.id == id, orElse: () => RefillType.min);
  }

  String get label {
    switch (this) {
      case RefillType.min:
        return contextlessL10n().enumCore_fillingTypeMinimum;
      case RefillType.critic:
        return contextlessL10n().enumCore_fillingTypeCritical;
      case RefillType.max:
        return contextlessL10n().enumCore_fillingTypeMaximum;
      case RefillType.all:
        return contextlessL10n().filter_all;
    }
  }
}
