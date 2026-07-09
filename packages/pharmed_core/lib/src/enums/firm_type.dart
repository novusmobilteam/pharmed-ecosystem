import 'package:collection/collection.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

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
        return contextlessL10n().enumCore_firmTypeSupplier;
      case FirmType.customer:
        return contextlessL10n().enumCore_firmTypeCustomer;
      case FirmType.manufacturer:
        return contextlessL10n().enumCore_firmTypeManufacturer;
    }
  }
}

FirmType? firmTypeFromId(int? value) {
  if (value == null) return null;
  return FirmType.values.firstWhereOrNull(
    (e) => e.id == value,
  );
}
