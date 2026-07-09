import 'package:pharmed_ui/pharmed_ui.dart';

enum WarningSubject {
  /// Zamansız Alım
  untimelyIntake(1),

  /// Tutarsızlık Çözümü
  inconsistencyResolution(2),

  /// İmha
  destruction(3),

  /// Fire
  wastage(4);

  final int id;

  const WarningSubject(this.id);

  static WarningSubject fromId(int? id) {
    return WarningSubject.values.firstWhere(
      (e) => e.id == id,
      orElse: () => WarningSubject.untimelyIntake,
    );
  }

  String get label {
    switch (this) {
      case WarningSubject.untimelyIntake:
        return contextlessL10n().enumCore_warningSubjectUntimelyPurchase;
      case WarningSubject.wastage:
        return contextlessL10n().enumCore_warningSubjectWaste;
      case WarningSubject.inconsistencyResolution:
        return contextlessL10n().enumCore_warningSubjectInconsistencyResolution;
      case WarningSubject.destruction:
        return contextlessL10n().enumCore_warningSubjectDisposal;
    }
  }
}
