// [SWREQ-DATA-CABIN-SERUM-001] [IEC 62304 §5.5]
// SerumShelfLayout ↔ SerumLayoutDTO dönüşümleri.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class SerumLayoutMapper {
  const SerumLayoutMapper();

  /// Kayıtlı yerleşimi her zaman 3 rafa tamamlar. Eksik raf (hiç kayıt
  /// yoksa hepsi) boş ve kayıtsız (id=null) gelir. Avadanlıklar `stepNo`
  /// sırasıyla — sağdan sola — dizilir.
  List<SerumShelfLayout> toShelves(SerumLayoutDTO? dto) {
    final byOrder = {for (final s in dto?.shelves ?? const <SerumShelfDTO>[]) s.orderNo: s};

    return List.generate(SerumShelfLayout.shelfCount, (i) {
      final orderNo = i + 1;
      final shelf = byOrder[orderNo];
      if (shelf == null) return SerumShelfLayout(orderNo: orderNo);

      final trays = [...shelf.trays]..sort((a, b) => a.stepNo.compareTo(b.stepNo));
      return SerumShelfLayout(
        id: shelf.id,
        orderNo: orderNo,
        lockType: SerumShelfLockType.fromId(shelf.toolType),
        trays: [
          for (final t in trays)
            if (SerumTraySize.fromId(t.toolSize) case final size?) SerumTray(id: t.id, size: size),
        ],
      );
    }, growable: false);
  }

  /// İstek gövdesi. Kayıtsız raf/avadanlıkta id alanı JSON'a hiç yazılmaz
  /// (POST); kayıtlı olanlarda mevcut id gönderilir (PUT).
  SerumLayoutDTO toDto({required int slotId, required List<SerumShelfLayout> shelves}) {
    final sorted = [...shelves]..sort((a, b) => a.orderNo.compareTo(b.orderNo));
    return SerumLayoutDTO(
      cabinDesignId: slotId,
      shelves: [
        for (final shelf in sorted)
          SerumShelfDTO(
            id: shelf.id,
            compartmentNo: shelf.orderNo,
            orderNo: shelf.orderNo,
            toolType: shelf.lockType.id,
            trays: [
              for (final (i, tray) in shelf.trays.indexed)
                SerumTrayDTO(id: tray.id, stepNo: i + 1, toolSize: tray.size.id),
            ],
          ),
      ],
    );
  }
}
