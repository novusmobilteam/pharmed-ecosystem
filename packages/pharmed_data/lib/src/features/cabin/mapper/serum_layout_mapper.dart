// [SWREQ-DATA-CABIN-SERUM-001] [IEC 62304 §5.5]
// SerumShelfLayout ↔ SerumLayoutDTO dönüşümleri.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class SerumLayoutMapper {
  const SerumLayoutMapper();

  /// GET cevabını [toShelves]'dan ÖNCE doğrular; geçersizse kullanıcıya
  /// gösterilecek hatayı döner.
  ///
  /// Hiç kayıt yoksa (raf listesi boş) geçerlidir — ilk kayıt POST ile yapılır.
  /// Kayıt varsa 3 rafın tamamı 1..3 arası benzersiz `orderNo` ile ve id'li
  /// gelmelidir. Aksi halde [toShelves] eşleşmeyen rafları sessizce boş/id'siz
  /// doldurur: id'li ve id'siz raflar karışır (kayıt hiçbir zaman geçmez) ya
  /// da hiçbiri eşleşmezse PUT yerine POST'a düşülür (mükerrer raf kaydı).
  BusinessRuleException? validate(SerumLayoutDTO? dto) {
    final shelves = dto?.shelves ?? const <SerumShelfDTO>[];
    if (shelves.isEmpty) return null;

    const total = SerumShelfLayout.shelfCount;
    final orders = shelves.map((s) => s.orderNo).toList();
    final hasInvalidOrder = orders.toSet().length != orders.length || orders.any((o) => o < 1 || o > total);
    if (hasInvalidOrder) {
      return BusinessRuleException(
        message: contextlessL10n().cabinDesign_serum_invalidLayoutError(orders.join(', ')),
        ruleCode: 'SERUM_LAYOUT_INVALID_ORDER',
      );
    }

    final saved = shelves.where((s) => s.id != null).length;
    if (shelves.length != total || saved != total) {
      return BusinessRuleException(
        message: contextlessL10n().cabinDesign_serum_incompleteLayoutError(saved, total),
        ruleCode: 'SERUM_LAYOUT_INCOMPLETE',
      );
    }
    return null;
  }

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
        isTakeGiveEnabled: shelf.isTakeGiveButtonActive ?? false,
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
            // Al-Ver tuşları kilit kartında — kilitsiz rafta gönderilmez.
            isTakeGiveButtonActive: shelf.isTakeGiveVerified,
            trays: [
              for (final (i, tray) in shelf.trays.indexed)
                SerumTrayDTO(id: tray.id, stepNo: i + 1, toolSize: tray.size.id),
            ],
          ),
      ],
    );
  }
}
