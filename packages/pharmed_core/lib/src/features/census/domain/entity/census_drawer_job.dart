// [SWREQ-CLI-MCENSUS-005] [IEC 62304 §5.5]
// Fiziksel çekmece bazlı sayım job'ı — RefillDrawerJob'ın census karşılığı.
// cabinDrawerId ve representativeAssignment artık SAKLANAN alanlar (RefillDrawerJob
// gibi), targets.first'ten türetilmiyor.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

enum CensusJobStatus { pending, active, completed, failed }

class CensusDrawerJob {
  const CensusDrawerJob({
    required this.cabinDrawerId,
    required this.representativeAssignment,
    required this.targets,
    this.status = CensusJobStatus.pending,
  });

  /// Fiziksel çekmece id'si (DrawerSlot.id) — RefillDrawerJob ile aynı alan.
  final int cabinDrawerId;

  /// Çekmece açma/donanım çağrılarında kullanılan temsilci atama (grupta
  /// ilk assignment — RefillQueueBuilder ile aynı seçim: assignments.first).
  final MedicineAssignment representativeAssignment;

  /// Kübik: birden çok target (her lid/göz ayrı). Birim doz: tek target.
  final List<CensusTarget> targets;
  final CensusJobStatus status;

  bool get isKubik => targets.isNotEmpty && targets.first.isKubik;

  /// Tüm hedefler geçerli mi? (sayım girilmişse miad var mı)
  bool get canComplete => targets.every((t) => t.isValid);

  bool get hasAnyEntry => targets.any((t) => t.hasEntry);

  CensusDrawerJob copyWith({List<CensusTarget>? targets, CensusJobStatus? status}) {
    return CensusDrawerJob(
      cabinDrawerId: cabinDrawerId,
      representativeAssignment: representativeAssignment,
      targets: targets ?? this.targets,
      status: status ?? this.status,
    );
  }
}
