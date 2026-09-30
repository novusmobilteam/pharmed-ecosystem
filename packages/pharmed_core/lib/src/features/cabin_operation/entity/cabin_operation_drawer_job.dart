// [SWREQ-CORE-CABINOP-003] [IEC 62304 §5.5]
//
// Bir kabin işleminin otomatik kuyruğundaki tek adımı temsil eder: bir
// fiziksel çekmece açılışı ve o çekmecede işlenecek hedefler (kübikte çok
// göz, birim dozda tek/çok göz). Hangi işlem (dolum/sayım/boşaltma) olduğunu
// bilmez — targets listesindeki her CabinOperationTarget kendi config'ini
// zaten taşıyor.
//
// isKubik, representativeAssignment üzerinden hesaplanır (targets.first
// ÜZERİNDEN DEĞİL) — aynı fiziksel çekmecedeki tüm hedefler zaten aynı
// drawerType'ı paylaşır, representativeAssignment her zaman dolu olduğu için
// targets boşken bile güvenilir sonuç verir.
//
// İade kutusu job'ı ([isReturnDrawer]): iade çekmecesi tanımlı kübik
// çekmecenin son sütunu (bkz. resolveDrawerGroupLayout) kapaksız tek bir
// bölmedir — çekmece tamamen açılır, kapak komutu gönderilmez. Aynı fiziksel
// çekmecenin normal gözleri ayrı, kübik bir job'dadır.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

enum CabinOperationJobStatus { pending, active, completed, failed }

class CabinOperationDrawerJob implements DrawerJob<CabinOperationTarget> {
  const CabinOperationDrawerJob({
    required this.cabinDrawerId,
    required this.representativeAssignment,
    required this.targets,
    this.cabinId,
    this.status = CabinOperationJobStatus.pending,
    this.isReturnDrawer = false,
  });

  final int cabinDrawerId;
  @override
  final MedicineAssignment representativeAssignment;
  @override
  final List<CabinOperationTarget> targets;
  @override
  final CabinOperationJobStatus status;
  final int? cabinId;

  /// Yalnızca iade: kalemlerin iade kutusuna bırakıldığı job.
  final bool isReturnDrawer;

  @override
  bool get isKubik =>
      !isReturnDrawer && (representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false);

  /// Kübik dışında hiçbir job "aynı açık çekmecede kalma" ihtiyacı duymuyor —
  /// birim doz (ve iade çekmecesi) her zaman target başına aç/kapa.
  @override
  bool get staysOpenAcrossTargets => isKubik;

  CabinOperationDrawerJob copyWith({List<CabinOperationTarget>? targets, CabinOperationJobStatus? status}) {
    return CabinOperationDrawerJob(
      cabinDrawerId: cabinDrawerId,
      representativeAssignment: representativeAssignment,
      targets: targets ?? this.targets,
      status: status ?? this.status,
      cabinId: cabinId,
      isReturnDrawer: isReturnDrawer,
    );
  }

  @override
  CabinOperationDrawerJob copyWithStatus(CabinOperationJobStatus status) => copyWith(status: status);

  @override
  DrawerJob<CabinOperationTarget> copyWithTargets(List<CabinOperationTarget> targets) => copyWith(targets: targets);
}
