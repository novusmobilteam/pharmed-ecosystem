import 'package:pharmed_core/pharmed_core.dart';

sealed class DrawerSlotVisual {
  const DrawerSlotVisual({required this.slotId});

  final int slotId;
}

final class KubicSlotVisual extends DrawerSlotVisual {
  const KubicSlotVisual({required super.slotId, required this.cells, required this.columnCount});

  final List<DrawerStatus> cells;
  final int columnCount;
  int get rowCount => (cells.length / columnCount).ceil();
}

final class UnitDoseSlotVisual extends DrawerSlotVisual {
  const UnitDoseSlotVisual({required super.slotId, required this.cells});

  final List<DrawerStatus> cells;
}

final class SerumSlotVisual extends DrawerSlotVisual {
  const SerumSlotVisual({required super.slotId, required this.status, this.heightFactor = 2});

  final DrawerStatus status;
  final int heightFactor;
}
