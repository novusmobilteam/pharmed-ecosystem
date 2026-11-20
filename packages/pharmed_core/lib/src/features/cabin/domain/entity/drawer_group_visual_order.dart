// pharmed_core/src/cabin/entity/drawer_group_visual_order.dart
//
// [SWREQ-CORE-CABIN-VISUAL-001] [IEC 62304 §5.5]
// Kübik göz listesini (DrawerUnit) fiziksel donanım adresinden (compartmentNo
// = port, orderNo = lidIndex) EKRANDA GÖRÜNEN grid sırasına çevirir.
//
// Fiziksel/görsel eşleme (donanım testiyle doğrulandı — port sabit tutulup
// lidIndex artırıldığında AYNI SÜTUNDA farklı SATIRLAR açıldığı gözlemlendi,
// bkz. hardware-services skill):
//   - compartmentNo (port, 1-4)   → SÜTUN, sol→sağ artan (port1=en sol)
//   - orderNo (lidIndex, 1-N)     → SATIR, TERS yönde (en yüksek orderNo=en üst satır)
//
// [kubikVisualOrderIndexes] HAM listedeki index'leri (0-tabanlı) görsel
// sıraya göre döner — hem DrawerUnit listesini hem de onunla PARALEL
// herhangi bir listeyi (örn. MedCellState) aynı permütasyonla yeniden
// sıralamak için kullanılır (bkz. kubikUnitsInVisualOrder,
// CabinOverviewPanel._executionLocationDetail).
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Kübikte bir sıra kartındaki göz sayısı (sahada 4; #275).
const int kubikLidsPerCard = 4;

/// Yalnızca göz sayısı bilinen kübiğin sütun (sıra kartı) sayısı:
/// 16 → 4, 20 → 5. En az 4.
int kubikColumnCountFor(int compartmentCount) {
  final cards = (compartmentCount / kubikLidsPerCard).ceil();
  return cards < 4 ? 4 : cards;
}

/// Kübik görsel gridin sütun sayısı (#275): sütun = sıra kartı =
/// compartmentNo, bu yüzden kayıtlı gözlerde en büyük compartmentNo'dur
/// (16 göz → 4, 20 göz → 5). orderNo'su olmayan (henüz kaydedilmemiş tarama)
/// gözlerde [kubikColumnCountFor] göz sayısından hesaplar.
int kubikColumnCount(List<DrawerUnit> units) {
  if (units.isEmpty) return 4;
  if (units.any((u) => u.orderNo == null || u.compartmentNo == null)) return kubikColumnCountFor(units.length);
  var max = 0;
  for (final u in units) {
    if (u.compartmentNo! > max) max = u.compartmentNo!;
  }
  return max < 1 ? 4 : max;
}

/// Grup için kübik sütun sayısı: iade kutulu kübik fiziksel olarak 4
/// sütunludur (son sütun tek kutu); diğerlerinde [kubikColumnCount].
int kubikGroupColumnCount(DrawerGroup group) => group.isReturnDrawer ? 4 : kubikColumnCount(group.units);

/// [units] ham (API) sırasındaki kübik göz listesi.
/// [columnCount] görsel gridin sütun sayısı — verilmezse [kubikColumnCount]
/// (16 göz → 4, 20 göz → 5; #275). İade kutulu kübikte çağıran 4 / 3 verir
/// (bkz. MasterCabinDrawerPanel._hybridGrid / _KubikGrid).
///
/// Dönen liste: `units[sonuc[0]]` görselde ilk (sol-üst) hücre, ...
/// Beklenmedik bir adres (grid dışı port/lidIndex) varsa o eleman SESSİZCE
/// atlanır — grid'i bozmak yerine eksik bırakmak tercih edildi.
List<int> kubikVisualOrderIndexes(List<DrawerUnit> units, {int? columnCount}) {
  if (units.isEmpty) return const [];
  final columns = columnCount ?? kubikColumnCount(units);

  final maxOrderNo = units.fold<int>(0, (max, u) => (u.orderNo ?? 1) > max ? (u.orderNo ?? 1) : max);
  final rowCount = maxOrderNo == 0 ? 1 : maxOrderNo;

  final grid = List<int?>.filled(rowCount * columns, null);

  for (int i = 0; i < units.length; i++) {
    final unit = units[i];
    final port = unit.compartmentNo ?? 1; // sütun kaynağı
    final lidIndex = unit.orderNo ?? 1; // satır kaynağı (ters)

    final visualCol = port - 1;
    final visualRow = rowCount - lidIndex;

    if (visualRow < 0 || visualRow >= rowCount || visualCol < 0 || visualCol >= columns) {
      continue;
    }

    grid[visualRow * columns + visualCol] = i; // HAM index'i sakla
  }

  return grid.whereType<int>().toList();
}

/// [kubikVisualOrderIndexes]'i doğrudan DrawerUnit listesine uygular.
List<DrawerUnit> kubikUnitsInVisualOrder(List<DrawerUnit> units, {int? columnCount}) {
  final indexes = kubikVisualOrderIndexes(units, columnCount: columnCount);
  return indexes.map((i) => units[i]).toList();
}

/// [kubikVisualOrderIndexes]'i, units ile PARALEL herhangi bir listeye
/// (örn. MedCellState) uygular. [parallel].length == [units].length olmalı.
List<T> reorderParallelToVisual<T>(List<DrawerUnit> units, List<T> parallel, {int? columnCount}) {
  assert(parallel.length == units.length, 'reorderParallelToVisual: liste uzunlukları eşleşmiyor');
  final indexes = kubikVisualOrderIndexes(units, columnCount: columnCount);
  return indexes.map((i) => parallel[i]).toList();
}

class DrawerGroupLayout {
  const DrawerGroupLayout({required this.normalUnits, required this.returnUnitIds, required this.isReturnDrawer});

  final List<DrawerUnit> normalUnits;
  final Set<int> returnUnitIds;
  final bool isReturnDrawer;
}

/// [hardwareColumnCount] — kübik grid'in FİZİKSEL/donanımsal sütun sayısı.
/// UI'da kaç sütun gösterileceğiyle (Wrap/GridView düzeni) KARIŞTIRILMAMALI —
/// bu değer sadece kubikUnitsInVisualOrder'ın doğru reshape yapabilmesi ve
/// iade çekmecesinin gerçek son sütununu doğru ayırabilmesi için gerekli.
/// Codebase'in geri kalanında (bkz. _DrawerView, GetCabinVisualizerDataUseCase)
/// bu değer sabit 4.
DrawerGroupLayout resolveDrawerGroupLayout(DrawerGroup group, {int? hardwareColumnCount}) {
  final isKubik = group.isKubik;
  final columns = hardwareColumnCount ?? kubikGroupColumnCount(group);
  final visualUnits = isKubik ? kubikUnitsInVisualOrder(group.units, columnCount: columns) : group.units;

  final isReturnDrawer = isKubik && group.isReturnDrawer;
  if (!isReturnDrawer) {
    return DrawerGroupLayout(normalUnits: visualUnits, returnUnitIds: const {}, isReturnDrawer: false);
  }

  final normal = <DrawerUnit>[];
  final returned = <DrawerUnit>[];
  for (var i = 0; i < visualUnits.length; i++) {
    final isLastColumn = (i % columns) == columns - 1;
    (isLastColumn ? returned : normal).add(visualUnits.elementAt(i));
  }

  return DrawerGroupLayout(
    normalUnits: normal,
    returnUnitIds: returned.map((u) => u.id).whereType<int>().toSet(),
    isReturnDrawer: true,
  );
}
