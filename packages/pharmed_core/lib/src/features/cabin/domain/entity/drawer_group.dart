import 'package:pharmed_core/pharmed_core.dart';

class DrawerGroup {
  final DrawerSlot slot;
  final List<DrawerUnit> units;

  DrawerGroup({required this.slot, required this.units});

  String get address => slot.address ?? '';
  int get orderNumber => slot.orderNumber ?? 999;
  DrawerType? get drawerType => slot.drawerConfig?.drawerType;
  bool get isKubik => drawerType?.isKubik ?? false;

  /// Unit sayısı (eğer unit varsa) veya drawerType'daki compartmentCount
  int get compartmentCount => units.isNotEmpty ? units.length : (drawerType?.compartmentCount ?? 1);

  /// Tip no 250 ise Serumdur
  bool get isSerum => slot.drawerConfig?.deviceTypeNo == 250;

  // TODO : Localization
  String get name {
    if (isReturnDrawer) return 'İade Çekmecesi';
    if (isSerum) return 'Serum Kabini';
    return isKubik
        ? 'Kübik Çekmece (${compartmentCount == 16 ? '4x4' : '5x4'})'
        : 'Birim Doz Çekmece (${drawerType?.compartmentCount} Göz - ${slot.drawerConfig?.numberOfSteps} Bölme )';
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

extension DrawerGroupListX on List<DrawerGroup> {
  /// selectedUnitId'ye sahip unit'i ve onun ait olduğu group'u bulur.
  /// Bulamazsa null döner.
  ({DrawerGroup group, DrawerUnit unit})? findByUnitId(int? selectedUnitId) {
    if (selectedUnitId == null) return null;

    for (final group in this) {
      for (final unit in group.units) {
        if (unit.id == selectedUnitId) {
          return (group: group, unit: unit);
        }
      }
    }
    return null;
  }
}
