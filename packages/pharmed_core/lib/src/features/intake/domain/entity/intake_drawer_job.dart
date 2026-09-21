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

class IntakeDrawerJob implements DrawerJob<IntakeTarget> {
  const IntakeDrawerJob({
    required this.cabinDrawerId,
    required this.representativeAssignment,
    required this.targets,
    this.status = CabinOperationJobStatus.pending,
    this.cabinId,
  });

  final int cabinDrawerId;

  @override
  final MedicineAssignment representativeAssignment;

  @override
  final List<IntakeTarget> targets;

  @override
  final CabinOperationJobStatus status;

  final int? cabinId;

  @override
  bool get isKubik => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;

  /// Kübik: bir kez açılır, lid'ler yazılımsal geçer (fiziksel kapanma yok).
  /// Birim doz: her fiziksel port kendi aç/kapa döngüsünü yaşar.
  @override
  bool get staysOpenAcrossTargets => isKubik;

  bool get isSerum => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;

  int get distinctMedicineCount => targets.map((t) => t.medicine?.id).whereType<int>().toSet().length;

  bool get canComplete => targets.every((t) => t.isValid);

  @override
  IntakeDrawerJob copyWithStatus(CabinOperationJobStatus status) => copyWith(status: status);

  IntakeDrawerJob copyWith({List<IntakeTarget>? targets, CabinOperationJobStatus? status}) {
    return IntakeDrawerJob(
      cabinDrawerId: cabinDrawerId,
      representativeAssignment: representativeAssignment,
      targets: targets ?? this.targets,
      status: status ?? this.status,
      cabinId: cabinId,
    );
  }

  @override
  IntakeDrawerJob copyWithTargets(List<IntakeTarget> targets) => copyWith(targets: targets);
}
