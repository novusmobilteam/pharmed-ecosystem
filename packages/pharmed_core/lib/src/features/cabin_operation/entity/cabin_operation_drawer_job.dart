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
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

enum CabinOperationJobStatus { pending, active, completed, failed }

class CabinOperationDrawerJob {
  const CabinOperationDrawerJob({
    required this.cabinDrawerId,
    required this.representativeAssignment,
    required this.targets,
    this.cabinId,
    this.status = CabinOperationJobStatus.pending,
  });

  /// Bu işin açtığı fiziksel çekmecenin id'si.
  final int cabinDrawerId;

  /// Çekmece açma operasyonu için temsilci assignment.
  final MedicineAssignment representativeAssignment;

  /// Bu çekmecede işlenecek gözler.
  final List<CabinOperationTarget> targets;

  final CabinOperationJobStatus status;

  final int? cabinId;

  bool get isKubik => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
  bool get isSerum => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;

  /// Bu çekmecedeki kaç farklı ilaç var (başlıkta göstermek için).
  int get distinctMedicineCount => targets.map((t) => t.assignment.medicine?.id).whereType<int>().toSet().length;

  /// Kaydetmeye değer en az bir girdi var mı.
  bool get hasAnyEntry => targets.any((t) => t.hasEntry);

  /// Tüm hedefler geçerli mi.
  bool get canComplete => targets.every((t) => t.isValid);

  CabinOperationDrawerJob copyWith({List<CabinOperationTarget>? targets, CabinOperationJobStatus? status}) {
    return CabinOperationDrawerJob(
      cabinDrawerId: cabinDrawerId,
      representativeAssignment: representativeAssignment,
      targets: targets ?? this.targets,
      status: status ?? this.status,
      cabinId: cabinId,
    );
  }
}
