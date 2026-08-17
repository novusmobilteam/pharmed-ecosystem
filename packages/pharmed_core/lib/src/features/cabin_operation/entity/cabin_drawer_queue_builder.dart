// [SWREQ-CORE-CABINOP-022] [IEC 62304 §5.5]
//
// TÜM kabin işlemlerinin (dolum/sayım/boşaltma/alım/iade) TEK ORTAK kuyruk
// gruplama mantığı. Önceki CabinOperationQueueBuilder / IntakeQueueBuilder /
// RefundQueueBuilder'ın yerine geçer — üçü de _physicalDrawerId /
// _compareByDrawerPosition / _compareByCellPosition mantığını birebir aynı
// şekilde tekrar ediyordu.
//
// Gruplama birimi GÖZ değil, FİZİKSEL ÇEKMECEDİR (DrawerSlot.id) — aynı
// çekmecedeki tüm hedefler, hangi ilaca ait olursa olsun, tek job altında
// toplanır. Job'lar fiziksel konuma göre üstten alta sıralanır.
//
// [skipped]: fiziksel çekmece kimliği (drawerSlot.id / drawerSlotId) hiç
// çözülemeyen hedefler — eksik/bozuk ilişkisel veri anlamına gelir.
// SESSİZCE atılmaz, çağırana bildirilir.
//
// [requiredStepNoOf]/[isReturnDrawerOf]: mod-özel alanları doldurmak için
// opsiyonel hook'lar — her ikisi de bir job'un TÜM hedef listesini alır
// (tek bir hedefi değil, çünkü requiredStepNo hesabı grup bazlıdır: bir
// job'daki en derin göze göre belirlenir). Kullanmayan işlemler bu
// parametreleri hiç geçmez, sonuç sırasıyla null/false olur.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class CabinDrawerQueueBuilder {
  static ({List<CabinDrawerJob<T>> jobs, List<T> skipped}) build<T extends CabinDrawerTarget>({
    required List<T> items,
    int? Function(List<T> jobItems)? requiredStepNoOf,
    bool Function(List<T> jobItems)? isReturnDrawerOf,
  }) {
    final grouped = <int, List<T>>{};
    final skipped = <T>[];

    for (final item in items) {
      final id = physicalDrawerId(item.assignment);
      if (id == null) {
        skipped.add(item);
        continue;
      }
      grouped.putIfAbsent(id, () => []).add(item);
    }

    final entries = grouped.entries.map((e) {
      final sorted = List<T>.from(e.value)..sort((a, b) => _compareByCellPosition(a.assignment, b.assignment));
      final representative = sorted.first.assignment;
      return (id: e.key, items: sorted, representative: representative!);
    }).toList()..sort((a, b) => _compareByDrawerPosition(a.representative, b.representative));

    final jobs = entries.map((e) {
      return CabinDrawerJob<T>(
        cabinDrawerId: e.id,
        representativeAssignment: e.representative,
        targets: e.items,
        requiredStepNo: requiredStepNoOf?.call(e.items),
        isReturnDrawer: isReturnDrawerOf?.call(e.items) ?? false,
      );
    }).toList();

    return (jobs: jobs, skipped: skipped);
  }

  // ── Private — gruplama/sıralama çekirdeği ────────────────────────────

  /// Fiziksel çekmece id'si = DrawerSlot.id (drawerSlotId null gelebilir).
  static int? physicalDrawerId(MedicineAssignment? a) => a?.drawerUnit?.drawerSlot?.id ?? a?.drawerUnit?.drawerSlotId;

  static int _compareByDrawerPosition(MedicineAssignment a, MedicineAssignment b) {
    final orderA = a.drawerUnit?.drawerSlot?.orderNumber ?? physicalDrawerId(a) ?? 0;
    final orderB = b.drawerUnit?.drawerSlot?.orderNumber ?? physicalDrawerId(b) ?? 0;
    return orderA.compareTo(orderB);
  }

  static int _compareByCellPosition(MedicineAssignment? a, MedicineAssignment? b) {
    final ua = a?.drawerUnit;
    final ub = b?.drawerUnit;
    final byOrder = (ua?.orderNo ?? 0).compareTo(ub?.orderNo ?? 0);
    if (byOrder != 0) return byOrder;
    return (ua?.compartmentNo ?? ua?.id ?? 0).compareTo(ub?.compartmentNo ?? ub?.id ?? 0);
  }
}
