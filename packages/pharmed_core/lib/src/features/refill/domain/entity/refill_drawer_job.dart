// [SWREQ-CLI-MREFILL-011] [IEC 62304 §5.5]
// Otomatik dolum kuyruğunun tek bir adımı = bir fiziksel çekmece açılışı.
//
// KRİTİK KURAL: Kuyruk birimi GÖZ değil, FİZİKSEL ÇEKMECEDİR.
//   - Kübik çekmece bir kez açılır, kapağı açılır, içindeki TÜM hedefler
//     (aynı ilacın birden çok gözü + farklı ilaçların gözleri) tek seferde
//     doldurulur, sonra kapanır.
//   - Birim doz / standart çekmece: o çekmecedeki hedefler tek açılışta.
//
// Bu sayede "en az çekmece açılışı" garanti edilir.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

enum RefillJobStatus { pending, active, completed, failed }

class RefillDrawerJob {
  const RefillDrawerJob({
    required this.cabinDrawerId,
    required this.representativeAssignment,
    required this.targets,
    this.status = RefillJobStatus.pending,
  });

  /// Bu işin açtığı fiziksel çekmecenin id'si (DrawerUnit.id değil,
  /// fiziksel çekmece = DrawerGroup/cabinDrawerId düzeyi).
  final int cabinDrawerId;

  /// Çekmece açma operasyonu için temsilci assignment.
  /// Aynı fiziksel çekmecedeki tüm hedefler aynı adres/çekmece tipini paylaşır,
  /// bu yüzden ilk hedefin assignment'ı orchestrator.open() için yeterlidir.
  final MedicineAssignment representativeAssignment;

  /// Bu çekmecede doldurulacak gözler (kübikte çok göz, birim dozda tek/çok).
  final List<RefillFillTarget> targets;

  /// Kuyruktaki durumu.
  final RefillJobStatus status;

  // ── Türetilen ──────────────────────────────────────────────────────────

  bool get isKubik => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;

  bool get isSerum => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;

  /// Bu çekmecedeki kaç farklı ilaç var (başlıkta göstermek için).
  int get distinctMedicineCount => targets.map((t) => t.assignment.medicine?.id).whereType<int>().toSet().length;

  /// Kaydetmeye değer en az bir dolum var mı?
  bool get hasAnyFilling => targets.any((t) => t.hasFilling);

  /// Tüm hedefler geçerli mi? (dolum girilmişse miad var mı)
  bool get canComplete => targets.every((t) => t.isValid);

  RefillDrawerJob copyWith({List<RefillFillTarget>? targets, RefillJobStatus? status}) {
    return RefillDrawerJob(
      cabinDrawerId: cabinDrawerId,
      representativeAssignment: representativeAssignment,
      targets: targets ?? this.targets,
      status: status ?? this.status,
    );
  }
}
