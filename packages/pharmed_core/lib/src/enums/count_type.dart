import 'package:pharmed_ui/pharmed_ui.dart';

/// Sayım Tipi
enum CountType {
  noCount(1), // Sayım Yok
  normalCount(2), // Normal Sayım
  blindCount(3); // Kör Sayım

  final int id;

  const CountType(this.id);

  static CountType fromId(int? id) {
    return CountType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => CountType.noCount,
    );
  }

  String get label {
    switch (this) {
      case CountType.noCount:
        return contextlessL10n().enumCore_countTypeNone;
      case CountType.normalCount:
        return contextlessL10n().enumCore_countTypeNormal;
      case CountType.blindCount:
        return contextlessL10n().enumCore_countTypeBlind;
    }
  }
}
