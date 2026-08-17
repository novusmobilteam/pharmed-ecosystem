// [SWREQ-CORE-CABINOP-010] [IEC 62304 §5.5]
//
// Bir kabin işleminde (dolum/sayım/boşaltma) TEK BİR HEDEFİ temsil eder:
// ya bir kübik çekmecenin tek gözü, ya da bir birim doz çekmecesinin tüm
// gözleri. Kullanıcının ekranda girdiği değerleri tutar, bu değerlerin
// backend'e gönderilmeye hazır (geçerli) olup olmadığına karar verir.
//
// Her hedefte iki miktar alanı olabilir: "primary" (fiziksel sayım — şu an
// çekmecede kaç adet var) ve opsiyonel "secondary" (dolumda konulacak
// miktar, boşaltmada çıkarılacak miktar). Sayımda secondary yok — kullanıcı
// sadece fiziksel sayımı girer, "girdi" doğrudan primary'den okunur. Bu
// tek fark `CabinOperationTargetConfig.hasSecondaryField` ile ifade edilir;
// dolum/sayım/boşaltma arasındaki TÜM davranış farkı burada toplanır.
//
// SKT (miad) iki şekilde girilebilir: birim doz çekmecenin her gözünde ayrı
// ayrı (per-cell), ya da tüm gözler için ortak tek bir tarih (singleMiad).
// Kullanıcı hangi modu seçtiyse (bkz. isPerCellMiadEnabled — UI katmanında),
// per-cell alan boş kaldığında singleMiad'a bakılır; bu davranış üç işlemde
// de aynıdır.
//
// Backend'den gelen ham miktar (ml cinsinden) her zaman
// `medicine.fromFillingBackendValue` ile gösterim değerine (adet) çevrilir;
// `currentQuantity` de her zaman `assignment.toDisplayQuantity` kullanır —
// üç işlemde de kullanıcı hep aynı birimi (adet) görür ve girer.
//
// Kullanım: `CabinOperationTarget.fromAssignment(assignment, refillTargetConfig)`
// gibi ilgili config ile üretilir; `withCubicCount`/`withStepFilling` vb.
// ile kullanıcı girdisi işlenir; `isValid`/`hasEntry` ile queue/job
// katmanına geçirilecek durum sorgulanır.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Bir birim doz çekmecesinin tek bir gözünün (step) girdisi.
class CabinOperationStepEntry {
  const CabinOperationStepEntry({this.countQuantity, this.secondaryQuantity, this.miadDate});

  /// Fiziksel sayım (bu gözde şu an kaç adet var).
  final double? countQuantity;

  /// Opsiyonel ikincil miktar — dolumda konulacak, boşaltmada çıkarılacak
  /// miktar. `config.hasSecondaryField == false` olan işlemlerde (sayım)
  /// bu alan hiç okunmaz.
  final double? secondaryQuantity;

  final DateTime? miadDate;

  CabinOperationStepEntry copyWith({
    double? countQuantity,
    double? secondaryQuantity,
    DateTime? miadDate,
    bool clearMiad = false,
  }) {
    return CabinOperationStepEntry(
      countQuantity: countQuantity ?? this.countQuantity,
      secondaryQuantity: secondaryQuantity ?? this.secondaryQuantity,
      miadDate: clearMiad ? null : (miadDate ?? this.miadDate),
    );
  }
}

class CabinOperationTarget implements CabinDrawerTarget {
  CabinOperationTarget._({
    required this.config,
    required this.assignment,
    required this.isKubik,
    required this.numberOfSteps,
    required this.cubicCount,
    required this.cubicSecondary,
    required this.cubicMiad,
    required this.steps,
    required this.singleMiad,
  });

  /// Bu hedefin hangi işlem (dolum/sayım/boşaltma) davranışını izleyeceği.
  final CabinOperationTargetConfig config;

  /// İlaç ataması — ilaç, mevcut stok, çekmece/göz geometrisi.
  final MedicineAssignment assignment;

  final bool isKubik;

  /// Birim doz çekmecesinin göz/kademe sayısı (kübikte 0).
  final int numberOfSteps;

  // Kübik girdileri
  final double cubicCount;
  final double cubicSecondary;
  final DateTime? cubicMiad;

  /// Birim doz girdileri (numberOfSteps uzunluğunda).
  final List<CabinOperationStepEntry> steps;

  /// Birim doz çekmecede tüm gözlere uygulanabilecek tek miad — per-cell
  /// miad boşsa buna bakılır.
  final DateTime? singleMiad;

  /// Mevcut stoktan bu hedefin başlangıç değerlerini yükler. Kübik çekmecede
  /// tek stok kaydından, birim dozda her gözün kendi stok kaydından
  /// (`corpartmentNo` eşlemesiyle) okur.
  factory CabinOperationTarget.fromAssignment(MedicineAssignment assignment, CabinOperationTargetConfig config) {
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final numberOfSteps = assignment.drawerUnit?.drawerSlot?.drawerConfig?.numberOfSteps ?? 0;
    final medicine = assignment.medicine;

    double convert(double raw) => medicine != null ? medicine.fromFillingBackendValue(raw) : raw;

    if (isKubik) {
      final kubik = CabinOperationStockResolver.resolveKubik(assignment: assignment, countConverter: convert);
      return CabinOperationTarget._(
        config: config,
        assignment: assignment,
        isKubik: true,
        numberOfSteps: 0,
        cubicCount: kubik.count,
        cubicSecondary: 0,
        cubicMiad: kubik.miadDate,
        steps: const [],
        singleMiad: kubik.miadDate,
      );
    }

    final (stockSteps, earliestMiad) = CabinOperationStockResolver.resolveSteps(
      assignment: assignment,
      numberOfSteps: numberOfSteps,
      countConverter: convert,
    );
    final entries = List.generate(numberOfSteps, (_) => const CabinOperationStepEntry());
    for (final s in stockSteps) {
      entries[s.index] = entries[s.index].copyWith(countQuantity: s.count, miadDate: s.miadDate);
    }

    return CabinOperationTarget._(
      config: config,
      assignment: assignment,
      isKubik: false,
      numberOfSteps: numberOfSteps,
      cubicCount: 0,
      cubicSecondary: 0,
      cubicMiad: null,
      steps: entries,
      singleMiad: earliestMiad,
    );
  }

  // ── Türetilen ──────────────────────────────────────────────────────────

  DrawerUnit? get unit => assignment.drawerUnit;
  int? get unitId => assignment.cabinDrawerId;

  /// Mevcut stok, gösterim birimi (adet) cinsinden.
  double get currentQuantity => assignment.toDisplayQuantity(assignment.totalQuantity);

  /// Bir "girdi"nin kaydetmeye değer olup olmadığını, config'e göre doğru
  /// alandan (secondary varsa secondary, yoksa primary) okur.
  double _entryValue({required double count, required double secondary}) =>
      config.hasSecondaryField ? secondary : count;

  /// Kaydetmeye değer en az bir girdi var mı.
  bool get hasEntry {
    if (isKubik) return _entryValue(count: cubicCount, secondary: cubicSecondary) > 0;
    return steps.any((s) => _entryValue(count: s.countQuantity ?? 0, secondary: s.secondaryQuantity ?? 0) > 0);
  }

  /// Bu hedef backend'e gönderilmeye hazır mı — girdi olan her yerde miad
  /// (per-cell ya da singleMiad fallback'i üzerinden) girilmiş olmalı.
  bool get isValid {
    if (isKubik) {
      return _entryValue(count: cubicCount, secondary: cubicSecondary) <= 0 || cubicMiad != null;
    }
    for (final s in steps) {
      final entered = _entryValue(count: s.countQuantity ?? 0, secondary: s.secondaryQuantity ?? 0) > 0;
      if (entered && s.miadDate == null && singleMiad == null) return false;
    }
    return true;
  }

  // ── copyWith ────────────────────────────────────────────────────────────

  CabinOperationTarget _copy({
    double? cubicCount,
    double? cubicSecondary,
    DateTime? cubicMiad,
    bool clearCubicMiad = false,
    List<CabinOperationStepEntry>? steps,
    DateTime? singleMiad,
    bool clearSingleMiad = false,
  }) {
    return CabinOperationTarget._(
      config: config,
      assignment: assignment,
      isKubik: isKubik,
      numberOfSteps: numberOfSteps,
      cubicCount: cubicCount ?? this.cubicCount,
      cubicSecondary: cubicSecondary ?? this.cubicSecondary,
      cubicMiad: clearCubicMiad ? null : (cubicMiad ?? this.cubicMiad),
      steps: steps ?? this.steps,
      singleMiad: clearSingleMiad ? null : (singleMiad ?? this.singleMiad),
    );
  }

  CabinOperationTarget withCubicCount(double v) => _copy(cubicCount: v);
  CabinOperationTarget withCubicSecondary(double v) => _copy(cubicSecondary: v);
  CabinOperationTarget withCubicMiad(DateTime? d) => _copy(cubicMiad: d, clearCubicMiad: d == null);
  CabinOperationTarget withSingleMiad(DateTime? d) => _copy(singleMiad: d, clearSingleMiad: d == null);

  CabinOperationTarget withStepCount(int index, double v) => _copyStep(index, (s) => s.copyWith(countQuantity: v));
  CabinOperationTarget withStepSecondary(int index, double v) =>
      _copyStep(index, (s) => s.copyWith(secondaryQuantity: v));
  CabinOperationTarget withStepMiad(int index, DateTime? d) =>
      _copyStep(index, (s) => s.copyWith(miadDate: d, clearMiad: d == null));

  CabinOperationTarget _copyStep(int index, CabinOperationStepEntry Function(CabinOperationStepEntry) update) {
    if (index < 0 || index >= steps.length) return this;
    final next = List<CabinOperationStepEntry>.from(steps);
    next[index] = update(next[index]);
    return _copy(steps: next);
  }
}
