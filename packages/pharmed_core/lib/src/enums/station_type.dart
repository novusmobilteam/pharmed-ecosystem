import 'package:collection/collection.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum StationType {
  medicineBased(1),
  patientBased(2);

  final int id;

  const StationType(this.id);

  static StationType? fromId(int? value) {
    if (value == null) return null;
    return StationType.values.firstWhereOrNull((e) => e.id == value);
  }

  String get label {
    switch (this) {
      case StationType.medicineBased:
        return contextlessL10n().stationSetup_station_typeMedicineBasedLabel;
      case StationType.patientBased:
        return contextlessL10n().stationSetup_station_typePatientBasedLabel;
    }
  }
}
