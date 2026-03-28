import 'package:collection/collection.dart';

enum FirmType {
  supplier(1),
  customer(2),
  manufacturer(3);

  final int id;

  const FirmType(this.id);
}

extension FirmTypeExtension on FirmType {
  String get label {
    switch (this) {
      case FirmType.supplier:
        return 'Tedarikçi';
      case FirmType.customer:
        return 'Müşteri';
      case FirmType.manufacturer:
        return 'Üretici';
    }
  }
}

FirmType? firmTypeFromId(int? value) {
  if (value == null) return null;
  return FirmType.values.firstWhereOrNull(
    (e) => e.id == value,
  );
}
