import 'package:pharmed_ui/pharmed_ui.dart';

enum PrescriptionType {
  white(1),
  serumWhite(2),
  red(3),
  green(4),
  orange(5),
  purple(6);

  final int id;

  const PrescriptionType(this.id);

  static PrescriptionType fromId(int? id) {
    return PrescriptionType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PrescriptionType.white,
    );
  }

  String get label {
    switch (this) {
      case PrescriptionType.white:
        return contextlessL10n().enumCore_prescriptionTypeWhite;
      case PrescriptionType.serumWhite:
        return contextlessL10n().enumCore_prescriptionTypeSerumWhite;

      case PrescriptionType.red:
        return contextlessL10n().enumCore_prescriptionTypeRed;

      case PrescriptionType.green:
        return contextlessL10n().enumCore_prescriptionTypeGreen;

      case PrescriptionType.orange:
        return contextlessL10n().enumCore_prescriptionTypeOrange;

      case PrescriptionType.purple:
        return contextlessL10n().enumCore_prescriptionTypePurple;
    }
  }
}
