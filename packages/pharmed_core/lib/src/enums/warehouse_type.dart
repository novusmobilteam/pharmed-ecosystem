import 'package:collection/collection.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

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
        return contextlessL10n().tableCore_stationDrugColumn;
      case WarehouseType.medicalConsumable:
        return contextlessL10n().tableCore_stationConsumableColumn;
      case WarehouseType.mainWarehouse:
        return contextlessL10n().enumCore_warehouseTypeMain;
    }
  }
}

WarehouseType? warehouseTypeFromId(int? value) {
  if (value == null) return null;
  return WarehouseType.values.firstWhereOrNull(
    (e) => e.id == value,
  );
}
