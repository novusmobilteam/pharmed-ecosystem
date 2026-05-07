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

final class MobileSlotVisual extends DrawerSlotVisual {
  const MobileSlotVisual({required super.slotId, required this.rowColumns, this.workingStatus});

  /// Her index bir satırı, değer o satırın sütun sayısını temsil eder.
  /// Örn: [3, 2, 4] → 3 satır, sütunlar sırasıyla 3, 2, 4
  final List<int> rowColumns;
  final CabinWorkingStatus? workingStatus;

  int get rowCount => rowColumns.length;
  int get totalCells => rowColumns.fold(0, (sum, c) => sum + c);

  /// Mobil kontrol kartının fiziksel port sayısı.
  static const int totalDrawerPorts = 4;

  /// Verilen [slot]'un fiziksel kontrol kartı portunu döner (1-tabanlı).
  ///
  /// Mobil kontrol kartı [totalDrawerPorts] portlu sabittir. Slot'lar
  /// [slots] listesindeki sıraya göre 1:1 eşleşir:
  ///   - slots[0] → port 1
  ///   - slots[1] → port 2
  ///   - ...
  ///
  /// 4'ten fazla slot olursa modulo ile sarılır (ileride genişleme için).
  ///
  /// [slot] [slots] listesinde bulunmuyorsa [StateError] fırlatır.
  static int portOf(List<MobileSlotVisual> slots, MobileSlotVisual slot) {
    final index = slots.indexWhere((s) => s.slotId == slot.slotId);
    if (index < 0) {
      throw StateError('MobileSlotVisual.portOf: slot listede yok (slotId=${slot.slotId})');
    }
    return (index % totalDrawerPorts) + 1;
  }
}
