// [SWREQ-CORE-CABINOP-020] [IEC 62304 §5.5]
//
// Tüm kabin işlem hedeflerinin (CabinOperationTarget / IntakeTarget /
// RefundTarget — ileride eklenecek herhangi biri) uyması gereken ortak
// sözleşme. CabinDrawerJob<T>'nin T'si bunu implemente etmek ZORUNDADIR.
//
// assignment nullable tanımlıdır çünkü IntakeTarget/RefundTarget'ta hedef
// önce var olur (bir kalem seçilir), assignment sonradan (check/resolve
// aşamasında) bağlanır — ara durumda null olabilir. CabinOperationTarget
// gibi assignment'ı hiçbir zaman null olmayan somut sınıflar, Dart'ın
// covariant return type kuralı gereği bu getter'ı non-nullable olarak
// override edebilir; hiçbir mevcut davranış bozulmaz.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class CabinDrawerTarget {
  /// Bu hedefin bağlı olduğu ilaç ataması — fiziksel çekmece/göz adresi.
  MedicineAssignment? get assignment;

  /// Backend'e gönderilmeye hazır mı (her işlem kendi kriterine göre karar verir).
  bool get isValid;

  /// Kaydetmeye değer en az bir girdi var mı. Girdi kavramı olmayan
  /// işlemlerde (örn. iade — miktar zaten Selection fazında belirlendi)
  /// her zaman true dönebilir.
  bool get hasEntry;
}

// [SWREQ-CORE-CABINOP-021] [IEC 62304 §5.5]
//
// TÜM kabin işlemlerinin (dolum/sayım/boşaltma/alım/iade — ve ileride
// eklenecek herhangi bir kabin işleminin) TEK ORTAK job sınıfı. Bir job,
// otomatik kuyruktaki tek adımı temsil eder: bir fiziksel çekmece açılışı
// ve o çekmecede işlenecek hedefler.
//
// Önceki CabinOperationDrawerJob / IntakeDrawerJob / RefundDrawerJob
// sınıflarının yerine geçer — üçü de yapısal olarak birebir aynıydı.
//
// Mod-özel alanlar (requiredStepNo, isReturnDrawer) HER işlemde mevcuttur
// ama yalnızca ilgili olan işlem tarafından doldurulur — bugün yalnızca
// alım kısmi açılış (requiredStepNo), yalnızca iade manuel-kutu modu
// (isReturnDrawer) kullanıyor olsa da, ileride başka bir işlem aynı
// ihtiyacı duyarsa yeni bir job sınıfı YAZILMADAN sadece ilgili alan
// doldurulur.
//
// isKubik, representativeAssignment üzerinden hesaplanır (targets.first
// ÜZERİNDEN DEĞİL) — aynı fiziksel çekmecedeki tüm hedefler zaten aynı
// drawerType'ı paylaşır, representativeAssignment her zaman dolu olduğu
// için targets boşken bile güvenilir sonuç verir.
//
// Sınıf: Class B

class CabinDrawerJob<T extends CabinDrawerTarget> {
  const CabinDrawerJob({
    required this.cabinDrawerId,
    required this.representativeAssignment,
    required this.targets,
    this.status = CabinOperationJobStatus.pending,
    this.requiredStepNo,
    this.isReturnDrawer = false,
  });

  /// Bu işin açtığı fiziksel çekmecenin id'si (DrawerSlot.id).
  final int cabinDrawerId;

  /// Çekmece açma operasyonu için temsilci assignment.
  final MedicineAssignment representativeAssignment;

  /// Bu çekmecede işlenecek hedefler.
  final List<T> targets;

  final CabinOperationJobStatus status;

  /// Bu çekmecenin fiziksel olarak en az kaç göze kadar açılması gerektiği
  /// (kısmi açılış). null → tam açılış / kavram bu işlemde geçerli değil.
  /// Şu an yalnızca alım kullanıyor; ileride başka bir işlem de kısmi
  /// açılış isterse buraya doldurur.
  final int? requiredStepNo;

  /// true ise: bu job bir "manuel iade kutusu" hedefidir — fiziksel lid
  /// komutu hiç gönderilmez, kullanıcı elle bırakır. Şu an yalnızca iade
  /// kullanıyor; diğer işlemlerde her zaman false.
  final bool isReturnDrawer;

  // ── Türetilen ──────────────────────────────────────────────────────────

  bool get isKubik => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
  bool get isSerum => representativeAssignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;

  /// true ise: çekmece TEK açılışta kalır, hedefler arası kapat/aç
  /// döngüsüne girilmez (kübik lid komutu isKubik'e göre ayrıca kontrol
  /// edilir — isReturnDrawer'da hiç gönderilmez).
  bool get staysOpenAcrossTargets => isKubik || isReturnDrawer;

  /// Bu çekmecedeki kaç farklı ilaç var (başlıkta göstermek için).
  int get distinctMedicineCount => targets.map((t) => t.assignment?.medicine?.id).whereType<int>().toSet().length;

  /// Kaydetmeye değer en az bir girdi var mı.
  bool get hasAnyEntry => targets.any((t) => t.hasEntry);

  /// Tüm hedefler geçerli mi.
  bool get canComplete => targets.every((t) => t.isValid);

  CabinDrawerJob<T> copyWith({
    List<T>? targets,
    CabinOperationJobStatus? status,
    int? requiredStepNo,
    bool? isReturnDrawer,
  }) {
    return CabinDrawerJob<T>(
      cabinDrawerId: cabinDrawerId,
      representativeAssignment: representativeAssignment,
      targets: targets ?? this.targets,
      status: status ?? this.status,
      requiredStepNo: requiredStepNo ?? this.requiredStepNo,
      isReturnDrawer: isReturnDrawer ?? this.isReturnDrawer,
    );
  }
}
