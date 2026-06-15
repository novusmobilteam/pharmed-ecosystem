// [SWREQ-CLI-MINTAKE-012] [IEC 62304 §5.5]
// Toplu CheckIntake sonrası, seçilen alım hedeflerini fiziksel çekmece bazında
// gruplayıp sıralı kuyruk üretir.
//
// Master dolumdaki RefillQueueBuilder'ın alım karşılığıdır.
//
// Girdi: her IntakeTarget = bir WithdrawItem + onun CheckIntake planı.
// "Bir item → tek fiziksel çekmece" varsayımı gereği, her hedef tek bir
// DrawerSlot.id'ye düşer.
//
// Gruplama: DrawerSlot.id (fiziksel çekmece). Aynı çekmecedeki tüm hedefler —
// hangi ilaca ait olursa olsun — tek IntakeDrawerJob altında toplanır.
//
// Sıralama: fiziksel konuma göre üstten alta (DrawerSlot.orderNumber) — en az
// çekmece açılışı ve ergonomik akış.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class IntakeQueueBuilder {
  /// [targets] içindeki her hedef bir item'ın alım planıdır. Bunları fiziksel
  /// çekmece bazında gruplayıp sıralı kuyruk döndürür.
  ///
  /// assignment'ı veya fiziksel çekmece id'si çözülemeyen hedefler atlanır
  /// (kuyruğa giremez; çağıran taraf bunu boş kuyruk olarak ele almalı).
  static List<IntakeDrawerJob> build(List<IntakeTarget> targets) {
    // 1. Fiziksel çekmece bazında grupla.
    final Map<int, List<IntakeTarget>> grouped = {};
    for (final t in targets) {
      final physicalId = _physicalDrawerId(t.assignment);
      if (physicalId == null) continue;
      grouped.putIfAbsent(physicalId, () => []).add(t);
    }

    // 2. Her grubu job'a çevir.
    final jobs = <IntakeDrawerJob>[];
    grouped.forEach((physicalId, jobTargets) {
      // Çekmece içindeki hedefleri de göz konumuna göre sırala (kübik lid sırası).
      jobTargets.sort((a, b) => _compareByCellPosition(a.assignment, b.assignment));

      jobs.add(
        IntakeDrawerJob(
          cabinDrawerId: physicalId,
          representativeAssignment: jobTargets.first.assignment!,
          targets: jobTargets,
        ),
      );
    });

    // 3. Job'ları fiziksel çekmece konumuna göre sırala (üstten alta).
    jobs.sort((a, b) => _compareByDrawerPosition(a.representativeAssignment, b.representativeAssignment));

    return jobs;
  }

  // ── Private ──────────────────────────────────────────────────────────────

  /// Fiziksel çekmece id'si = DrawerSlot.id (drawerSlotId null gelebilir).
  static int? _physicalDrawerId(MedicineAssignment? a) => a?.drawerUnit?.drawerSlot?.id ?? a?.drawerUnit?.drawerSlotId;

  /// Çekmece konumu: DrawerSlot.orderNumber (kabin içi dikey sıra, üstten alta).
  static int _compareByDrawerPosition(MedicineAssignment a, MedicineAssignment b) {
    final orderA = a.drawerUnit?.drawerSlot?.orderNumber ?? _physicalDrawerId(a) ?? 0;
    final orderB = b.drawerUnit?.drawerSlot?.orderNumber ?? _physicalDrawerId(b) ?? 0;
    return orderA.compareTo(orderB);
  }

  /// Çekmece içi göz konumu — kübikte lid sırası (orderNo → compartmentNo).
  static int _compareByCellPosition(MedicineAssignment? a, MedicineAssignment? b) {
    final ua = a?.drawerUnit;
    final ub = b?.drawerUnit;
    final byOrder = (ua?.orderNo ?? 0).compareTo(ub?.orderNo ?? 0);
    if (byOrder != 0) return byOrder;
    return (ua?.compartmentNo ?? ua?.id ?? 0).compareTo(ub?.compartmentNo ?? ub?.id ?? 0);
  }
}
