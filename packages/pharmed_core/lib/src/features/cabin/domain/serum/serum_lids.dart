// [SWREQ-CORE-CABIN-SERUM-002] [IEC 62304 §5.5]
// Bağımsız serum kabini kapakları (#199).
//
// A dışındaki adreste yalnızca satır 26'da serum kartı (`.250`) varsa kabin
// bağımsız serum kabinidir (#195). Kapak sayısı karttan okunamaz; kullanıcı
// seçer (1–4). Her kapak ayrı bir DrawerSlot olarak kaydedilir:
//   adres = satır 26, orderNumber = kapak no = port (#193).
// Her kapağın içi master'daki serum gözü gibi 3 raflı serum yerleşimidir.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class SerumLids {
  /// Bu slot bağımsız serum kabininin bir kapağı mı (satır 26'daki serum)?
  static bool isLid(DrawerSlot slot) =>
      (slot.drawerConfig?.isSerum ?? false) && int.tryParse(slot.address ?? '') == DeviceConstants.serumSlaveRow;

  /// Kapak numarası (1–4); kapak değilse null.
  static int? lidNo(DrawerSlot slot) => isLid(slot) ? slot.orderNumber : null;

  /// Gruplardaki kapak sayısı.
  static int countIn(List<DrawerGroup> groups) => groups.where((g) => isLid(g.slot)).length;

  /// Boştaki kapak numaraları (küçükten büyüğe). Ortadaki bir kapak
  /// silindiyse (#203) kalan kapakların numarası = portu değişmez; yeni kapak
  /// boşalan en küçük numarayı alır.
  static List<int> freeLidNumbers(Iterable<DrawerSlot> lids) {
    final used = lids.map((s) => s.orderNumber).whereType<int>().toSet();
    return [
      for (var lid = 1; lid <= DeviceConstants.maxSerumLids; lid++)
        if (!used.contains(lid)) lid,
    ];
  }

  /// Taramadan gelen tek serum çekmecesini [lidCount] kapağa çoğaltır.
  /// Her kapak aynı tanımı (DrawerConfig) ve göz şablonunu taşır.
  static List<DrawerGroup> expand(DrawerGroup serum, int lidCount) {
    final count = lidCount.clamp(1, DeviceConstants.maxSerumLids);
    return [
      for (var lid = 1; lid <= count; lid++)
        DrawerGroup(slot: serum.slot.copyWith(orderNumber: lid), units: serum.units),
    ];
  }
}
