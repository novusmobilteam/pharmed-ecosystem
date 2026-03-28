import 'package:collection/collection.dart';

enum WarehouseType {
  drug(1),
  mainWarehouse(2),
  medicalConsumable(3);

  final int id;

  const WarehouseType(this.id);
}

extension WarehouseTypeExtension on WarehouseType {
  String get label {
    switch (this) {
      case WarehouseType.drug:
        return 'İlaç';
      case WarehouseType.medicalConsumable:
        return 'Tıbbi Sarf';
      case WarehouseType.mainWarehouse:
        return 'Ana Depo';
    }
  }
}

WarehouseType? warehouseTypeFromId(int? value) {
  if (value == null) return null;
  return WarehouseType.values.firstWhereOrNull(
    (e) => e.id == value,
  );
}
