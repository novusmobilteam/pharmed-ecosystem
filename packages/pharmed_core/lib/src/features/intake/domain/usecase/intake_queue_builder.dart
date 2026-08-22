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
// Kısmi açma: her job'un requiredStepNo'su, o job'daki target'ların
// CheckIntake planında (IntakeDetail.stockId) referans verdiği stokların
// (CabinStock.cabinDrawerDetail.stepNo) EN DERİNİ olarak hesaplanır — hangi
// stoktan alınacağı zaten check aşamasında (ordered: servis, orderless/free:
// FIFO) belirlendiği için burada YENİDEN kümülatif stok hesabı yapılmaz.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

abstract final class IntakeQueueBuilder {
  static int? resolveStepNoForTarget(IntakeTarget target) => _resolveRequiredStepNo([target]);
  static int? _cabinId(MedicineAssignment? a) => a?.drawerUnit?.drawerSlot?.cabinId;

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
          requiredStepNo: _resolveRequiredStepNo(jobTargets),
          cabinId: _cabinId(jobTargets.first.assignment),
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

  /// Bir job'daki tüm hedeflerin check planı (IntakeDetail.stockId) üzerinden
  /// çekmecenin en az kaç göze kadar açılması gerektiğini bulur.
  ///
  ///   - Ordered: item.stock zaten CheckIntake'e resolvedStock olarak
  ///     verilmişti (bkz. CheckIntakeUseCase._resolveDetails) — detail.stockId
  ///     bu stoğa eşittir, cabinDrawerDetail doğrudan item.stock'tan okunur.
  ///   - Orderless/free: item.stock null'dur — detail.stockId, FIFO ile
  ///     assignment.stocks listesinden seçilmiş bir kayda işaret eder, o
  ///     listede aranır.
  ///
  /// Hiçbir detail stepNo'ya çözülemezse null döner — donanım katmanı bu
  /// durumda tam açılışa düşer (bkz. calculateAddressFromAssignment).
  static int? _resolveRequiredStepNo(List<IntakeTarget> jobTargets) {
    int? deepest;

    for (final target in jobTargets) {
      final assignment = target.assignment;
      if (assignment == null) continue;

      for (final detail in target.details) {
        final itemStock = target.item.stock;
        final stock = (itemStock != null && itemStock.id == detail.stockId)
            ? itemStock
            : assignment.stocks?.firstWhereOrNull((s) => s.id == detail.stockId);

        final stepNo = stock?.cabinDrawerDetail?.stepNo;
        if (stepNo == null) continue;
        if (deepest == null || stepNo > deepest) deepest = stepNo;
      }
    }

    return deepest;
  }
}
