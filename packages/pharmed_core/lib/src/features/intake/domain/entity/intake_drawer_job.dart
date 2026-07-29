// [SWREQ-CLI-MINTAKE-011] [IEC 62304 §5.5]
// Alım kuyruğunun tek bir adımı = bir fiziksel çekmece açılışı.
//
// Master dolumdaki RefillDrawerJob'ın alım karşılığıdır. Aynı KRİTİK KURAL:
// kuyruk birimi GÖZ değil, FİZİKSEL ÇEKMECEDİR.
//   - Kübik çekmece bir kez açılır; içindeki tüm hedef gözler (lid-by-lid)
//     sırayla işlenir, sonra kapanır.
//   - Birim doz / standart çekmece: o çekmecedeki hedefler tek açılışta.
//
// "Bir item → tek fiziksel çekmece" varsayımı gereği, bir job içindeki her
// IntakeTarget farklı bir ilaç olabilir ama hepsi aynı fiziksel çekmecededir.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B
//
// NOT: RefillJobStatus (pending/active/completed/failed) enum'u
// refill_drawer_job.dart'tan yeniden kullanılır; ayrı enum tanımlanmaz.

import 'package:pharmed_core/pharmed_core.dart';

class IntakeDrawerJob {
  const IntakeDrawerJob({
    required this.cabinDrawerId,
    required this.representativeAssignment,
    required this.targets,
    this.status = CabinOperationJobStatus.pending,
    this.requiredStepNo,
  });

  /// Bu işin açtığı fiziksel çekmecenin id'si (DrawerSlot.id).
  final int cabinDrawerId;

  /// Çekmece açma operasyonu için temsilci assignment (ilk hedefin ataması).
  final MedicineAssignment representativeAssignment;

  /// Bu çekmecede alınacak hedefler (her biri ayrı ilaç olabilir).
  final List<IntakeTarget> targets;

  /// Kuyruktaki durumu.
  final CabinOperationJobStatus status;

  /// Bu çekmecenin fiziksel olarak en az kaç göze kadar açılması gerektiği —
  /// job'daki tüm target'ların details'lerinde referans verdiği stokların
  /// (CabinStock.cabinDrawerDetail.stepNo) en derini. null → hesaplanamadı
  /// (ör. kübik çekmece — kübikte bu kavram yok, lid-by-lid zaten kendi
  /// gözünü açıyor) ya da hiçbir detail stepNo taşımıyor; bu durumda
  /// donanım katmanı tam açılışa düşer.
  final int? requiredStepNo;

  // ── Türetilen ──────────────────────────────────────────────────────────

  bool get isKubik => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;

  bool get isSerum => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;

  /// Bu çekmecede kaç farklı ilaç var (başlıkta göstermek için).
  int get distinctMedicineCount => targets.map((t) => t.medicine?.id).whereType<int>().toSet().length;

  /// Tüm hedefler tamamlamaya hazır mı? (sayım gereken her hedefte sayım girilmiş mi)
  bool get canComplete => targets.every((t) => t.isValid);

  IntakeDrawerJob copyWith({List<IntakeTarget>? targets, CabinOperationJobStatus? status}) {
    return IntakeDrawerJob(
      cabinDrawerId: cabinDrawerId,
      representativeAssignment: representativeAssignment,
      targets: targets ?? this.targets,
      status: status ?? this.status,
      requiredStepNo: requiredStepNo,
    );
  }
}
