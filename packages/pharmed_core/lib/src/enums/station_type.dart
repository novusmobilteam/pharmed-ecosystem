import 'package:collection/collection.dart';

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
        return 'İlaç Bazlı';
      case StationType.patientBased:
        return 'Hasta Bazlı';
    }
  }
}
