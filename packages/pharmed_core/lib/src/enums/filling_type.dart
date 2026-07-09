import 'package:pharmed_ui/pharmed_ui.dart';

/// Dolum Listesi Tip
/// Ekranda yer alan min, max, kritik radio buttonları. İstek atılırken de kullanılıyor.
enum FillingType {
  all(4),
  max(3), //  Stok maksimum seviyenin altına düşmüşse
  min(1), // Stok minimum seviyenin altına düşmüşse
  critic(2); // Stok kritik seviyenin altına düşmüşse

  final int id;

  const FillingType(this.id);

  static FillingType fromId(int? id) {
    return FillingType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => FillingType.min,
    );
  }

  String get label {
    switch (this) {
      case FillingType.min:
        return contextlessL10n().enumCore_fillingTypeMinimum;
      case FillingType.critic:
        return contextlessL10n().enumCore_fillingTypeCritical;
      case FillingType.max:
        return contextlessL10n().enumCore_fillingTypeMaximum;
      case FillingType.all:
        return contextlessL10n().filter_all;
    }
  }
}
