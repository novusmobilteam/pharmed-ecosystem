import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class DrawerGroup {
  final DrawerSlot slot;
  final List<DrawerUnit> units;

  /// Yalnızca serum çekmecesinde: 3 rafın avadanlık yerleşimi (Raf 1 en üst).
  /// Karttan taranmaz, ayrı servisten okunur. null → okunmadı/okunamadı;
  /// raflar boş liste değil, her zaman 3 elemandır.
  final List<SerumShelfLayout>? serumShelves;

  DrawerGroup({required this.slot, required this.units, this.serumShelves});

  DrawerGroup copyWith({List<DrawerUnit>? units, List<SerumShelfLayout>? serumShelves}) =>
      DrawerGroup(slot: slot, units: units ?? this.units, serumShelves: serumShelves ?? this.serumShelves);

  String get address => slot.address ?? '';
  int get orderNumber => slot.orderNumber ?? 999;
  DrawerType? get drawerType => slot.drawerConfig?.drawerType;
  bool get isKubik => drawerType?.isKubik ?? false;

  /// Unit sayısı (eğer unit varsa) veya drawerType'daki compartmentCount
  int get compartmentCount => units.isNotEmpty ? units.length : (drawerType?.compartmentCount ?? 1);

  /// Tip no 250 ise Serumdur
  bool get isSerum => slot.drawerConfig?.deviceTypeNo == 250;

  /// Serum çekmecesindeki kayıtlı avadanlıkların (DrawerCell) id'leri.
  Set<int> get serumTrayIds => {
    for (final shelf in serumShelves ?? const <SerumShelfLayout>[])
      for (final tray in shelf.trays)
        if (tray.id != null) tray.id!,
  };

  String get name {
    if (isSerum) return contextlessL10n().enumCore_cabinTypeSerum;
    return isKubik ? contextlessL10n().cabin_kubikDrawerName : contextlessL10n().cabin_unitDoseDrawerName;
  }

  CabinType? get cabinType => slot.cabin?.type;

  /// Serum kabini mi?
  bool get isSerumCabinet => cabinType == CabinType.serum;

  /// Freezer (buzdolabı) mi?
  bool get isFreezer => cabinType == CabinType.freezer;

  /// Standard kabin (master/slave) mi?
  bool get isMaster => cabinType == CabinType.master;

  /// Bu fiziksel çekmece iade çekmecesi olarak tanımlı mı — true ise
  /// gözler artık bireysel hedef değildir, tek sanal kutu olarak render
  /// edilir (bkz. ReturnSlotVisual / _MasterReturnDrawerView).
  bool get isReturnDrawer => slot.isReturnDrawerHere ?? false;

  /// Görsel yükseklik hesapla
  double get visualHeight {
    if (isSerumCabinet) return 90.0; // Kısa ve geniş
    if (isFreezer) return 120.0; // Uzun, tek kapaklı
    return 70.0; // Standart çekmece
  }

  /// Görsel genişlik hesapla
  double get visualWidth {
    if (isSerumCabinet) return 200.0; // Geniş
    if (isFreezer) return 150.0; // Orta genişlik
    return 250.0; // Standart
  }

  /// Sadece drawerSlotId ile DrawerSlot.id eşleştirerek gruplama yapar
  static List<DrawerGroup> combineData({required List<DrawerSlot> slots, required List<DrawerUnit> units}) {
    // 2. Unit'leri drawerSlotId'ye göre grupla
    final unitsBySlotId = <int, List<DrawerUnit>>{};

    for (var unit in units) {
      if (unit.drawerSlotId == null) continue;

      unitsBySlotId.putIfAbsent(unit.drawerSlotId!, () => []).add(unit);
    }

    // 3. Her slot için DrawerGroup oluştur
    final result = <DrawerGroup>[];

    for (var slot in slots) {
      if (slot.id == null) continue;

      final slotUnits = unitsBySlotId[slot.id] ?? [];

      // Unit'leri sırala: compartmentNo'ya göre
      slotUnits.sort((a, b) => (a.compartmentNo ?? 0).compareTo(b.compartmentNo ?? 0));

      result.add(DrawerGroup(slot: slot, units: slotUnits));
    }

    // 4. Slot orderNumber'a göre sırala
    result.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    return result;
  }
}
