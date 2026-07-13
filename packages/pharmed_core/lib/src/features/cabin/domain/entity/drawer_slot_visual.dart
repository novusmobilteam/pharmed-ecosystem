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

  final List<int> rowColumns;
  final CabinWorkingStatus? workingStatus;

  int get rowCount => rowColumns.length;
  int get totalCells => rowColumns.fold(0, (sum, c) => sum + c);

  /// Mobil kontrol kartının fiziksel çekmece sayısı.
  ///
  /// Yeni kart revizyonu: 4 → 5 çekmece.
  static const int totalDrawers = 5;

  /// Fiziksel çekmece numarası (1..5) → kontrol kartı port numarası.
  ///
  /// Yeni kart revizyonunda kablolama bir kaydı: çekmece N artık port N-1'e
  /// bağlı, çekmece 1 ise port 5'e sarıyor. Donanımda birebir ölçülerek
  /// doğrulandı (kapanış-bekleme akışıyla, 5 çekmece tek tek test edildi).
  ///
  /// [SWREQ-CLI-CABIN-OP-005] Kart rev.2 çekmece→port haritası.
  static const Map<int, int> _drawerToPort = {
    1: 5,
    2: 1,
    3: 2,
    4: 3,
    5: 4,
  };

  /// Verilen [slot]'un fiziksel kontrol kartı portunu döner (1-tabanlı).
  ///
  /// Slot'lar [slots] listesindeki sıraya göre fiziksel çekmece numarasına
  /// eşlenir (slots[0] → çekmece 1, slots[1] → çekmece 2, ...), ardından
  /// [_drawerToPort] ile kartın gerçek port numarasına çevrilir.
  ///
  /// [slot] listede yoksa veya çekmece numarası haritada yoksa [StateError].
  static int portOf(List<MobileSlotVisual> slots, MobileSlotVisual slot) {
    final index = slots.indexWhere((s) => s.slotId == slot.slotId);
    if (index < 0) {
      throw StateError('MobileSlotVisual.portOf: slot listede yok (slotId=${slot.slotId})');
    }

    final drawerNumber = index + 1; // 1-tabanlı fiziksel çekmece no

    final port = _drawerToPort[drawerNumber];
    if (port == null) {
      throw StateError(
        'MobileSlotVisual.portOf: geçersiz çekmece numarası '
        '(drawer=$drawerNumber, slotId=${slot.slotId}, toplam slot=${slots.length}). '
        'Bu kart en fazla $totalDrawers çekmece destekler.',
      );
    }
    return port;
  }
}