import 'package:pharmed_ui/pharmed_ui.dart';

enum CabinColor {
  blue(hex: '#007bff'),
  turquoise(hex: '#17a2b8'),
  green(hex: '#28a745'),
  red(hex: '#dc3545'),
  orange(hex: '#fd7e14'),
  purple(hex: '#6f42c1'),
  grey(hex: '#6c757d'),
  black(hex: '#343a40'),
  white(hex: '#f8f9fa');

  final String hex;

  const CabinColor({required this.hex});

  String get label {
    switch (this) {
      case CabinColor.blue:
        return contextlessL10n().enumCore_cabinColorBlue;
      case CabinColor.turquoise:
        return contextlessL10n().enumCore_cabinColorTurquoise;
      case CabinColor.green:
        return contextlessL10n().enumCore_cabinColorGreen;
      case CabinColor.red:
        return contextlessL10n().enumCore_cabinColorRed;
      case CabinColor.orange:
        return contextlessL10n().enumCore_cabinColorOrange;
      case CabinColor.purple:
        return contextlessL10n().enumCore_cabinColorPurple;
      case CabinColor.grey:
        return contextlessL10n().enumCore_cabinColorGray;
      case CabinColor.black:
        return contextlessL10n().enumCore_cabinColorBlack;
      case CabinColor.white:
        return contextlessL10n().enumCore_cabinColorWhite;
    }
  }

  static CabinColor? fromHex(String? hex) {
    return CabinColor.values.firstWhere(
      (e) => e.hex == hex,
      orElse: () => CabinColor.blue,
    );
  }
}
