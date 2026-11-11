// [SWREQ-CORE-CABIN-SERUM-001] [IEC 62304 §5.5]
// Serum kabini raf yerleşimi (kullanıcı tanımlı, karttan taranmaz).
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

/// Serum kabinindeki tek bir rafın yerleşimi.
///
/// HİYERARŞİ (API ile birebir):
///   Serum kabini   → DrawerSlot  (`cabinDesignId`)
///   Raf (1-3)      → DrawerUnit  (`cabinDrawrs[]`, kilit = `toolType`)
///   Avadanlık      → DrawerCell  (`cabinDrawrDetails[]`, boyut = `toolSize`)
///
/// SIRA KURALI: [trays] SAĞDAN SOLA fiziksel sıradadır — ilk avadanlık en
/// sağdadır, `stepNo = index + 1`. Port numarası client'ta tutulmaz; backend üretir.
class SerumShelfLayout {
  const SerumShelfLayout({
    this.id,
    required this.orderNo,
    this.lockType = SerumShelfLockType.unlocked,
    this.trays = const [],
    this.isTakeGiveEnabled = false,
  });

  /// Sabit raf sayısı — serum kabininde her zaman 3 raf vardır.
  static const int shelfCount = 3;

  /// Bir rafın toplam alan kapasitesi.
  static const int totalArea = 8;

  /// Boş (kayıtsız, kilitsiz, avadanlıksız) 3 raf. Raf 1 en üst raftır.
  static List<SerumShelfLayout> emptyShelves() =>
      List.generate(shelfCount, (i) => SerumShelfLayout(orderNo: i + 1), growable: false);

  /// Kayıtlı raflarda DrawerUnit.id; henüz kaydedilmemişse null.
  final int? id;

  /// 1..3 — Raf 1 en üst raf.
  final int orderNo;
  final SerumShelfLockType lockType;
  final List<SerumTray> trays;

  /// "Al-Ver butonu aktif mi?" — kilit kartındaki Al-Ver tuşlarıyla miktar
  /// doğrulaması (alım/iade). Tuşlar kilit kartında olduğundan YALNIZCA
  /// kilitli rafta anlamlıdır — bkz. [isTakeGiveVerified].
  final bool isTakeGiveEnabled;

  /// Al-Ver doğrulaması bu rafta gerçekten uygulanır mı (kilitli + açık).
  bool get isTakeGiveVerified => isLocked && isTakeGiveEnabled;

  bool get isLocked => lockType.isLocked;

  /// Raf avadanlıksız "Açık Raf" mı (tek `openShelf` kaydı). Açık rafta
  /// avadanlık eklenmez, kilit ve Al-Ver kullanılmaz; birden çok ilaç atanabilir.
  bool get isOpenShelf => trays.any((t) => t.size.isOpenShelf);
  bool get isPersisted => id != null;
  int get usedArea => trays.fold(0, (sum, t) => sum + t.size.areaSize);
  int get remainingArea => totalArea - usedArea;
  bool canAdd(SerumTraySize size) => !isOpenShelf && !size.isOpenShelf && remainingArea >= size.areaSize;

  /// Rafı Açık Raf'a çevirir: avadanlıklar kalkar, tüm rafı kaplayan tek
  /// kayıt eklenir; kilit ve Al-Ver kapanır. Zaten açık rafsa aynen döner.
  SerumShelfLayout toOpenShelf() => isOpenShelf
      ? this
      : copyWith(
          lockType: SerumShelfLockType.unlocked,
          isTakeGiveEnabled: false,
          trays: const [SerumTray(size: SerumTraySize.openShelf)],
        );

  /// Açık Raf'ı avadanlıklı (boş) rafa çevirir. Zaten avadanlıklıysa aynen döner.
  SerumShelfLayout toTrayShelf() => isOpenShelf ? copyWith(trays: const []) : this;

  SerumShelfLayout copyWith({SerumShelfLockType? lockType, List<SerumTray>? trays, bool? isTakeGiveEnabled}) =>
      SerumShelfLayout(
        id: id,
        orderNo: orderNo,
        lockType: lockType ?? this.lockType,
        trays: trays ?? this.trays,
        isTakeGiveEnabled: isTakeGiveEnabled ?? this.isTakeGiveEnabled,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SerumShelfLayout &&
          other.id == id &&
          other.orderNo == orderNo &&
          other.lockType == lockType &&
          other.isTakeGiveEnabled == isTakeGiveEnabled &&
          const ListEquality<SerumTray>().equals(other.trays, trays);

  @override
  int get hashCode => Object.hash(id, orderNo, lockType, isTakeGiveEnabled, Object.hashAll(trays));

  @override
  String toString() => 'SerumShelfLayout(id: $id, order: $orderNo, lock: ${lockType.name}, takeGive: $isTakeGiveEnabled, trays: $trays)';
}

/// Raftaki tek avadanlık. Sırası, içinde bulunduğu listedeki konumudur.
class SerumTray {
  const SerumTray({this.id, required this.size});

  /// Kayıtlı avadanlıkta DrawerCell.id; yeni eklenmişse null.
  final int? id;
  final SerumTraySize size;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SerumTray && other.id == id && other.size == size;

  @override
  int get hashCode => Object.hash(id, size);

  @override
  String toString() => 'SerumTray(id: $id, ${size.name})';
}
