// [SWREQ-CORE-CABINOP-010] [IEC 62304 §5.5]
//
// Bir kabin işleminde (dolum/sayım/boşaltma/imha/alım) TEK BİR HEDEF: ya bir
// kübik çekmecenin tek gözü, ya da bir birim doz çekmecesinin gözleri.
// Kullanıcı girdilerini tutar ve kayda hazır olup olmadığına karar verir.
//
// Hangi alanların var olduğu [CabinOperationMode]'dan gelir. Tüm miktarlar
// ADET cinsindendir — stoktan okunurken de gönderilirken de çevrim yoktur.
//
// Stok okuma kuralları:
//   - Kübik: pozitif miktarlı kayıtlar arasında EN ERKEN SKT.
//   - Birim doz: her kayıt `corpartmentNo`'suna göre göze düşer; aynı göze
//     birden fazla kayıt gelirse miktarlar toplanır, en erken SKT alınır.
//   - Miktarı sıfır olan kayıtların ve boş göz işaret tarihinin (2099)
//     SKT'si yok sayılır.
//
// Sayım alanı [countType]'a göre başlar: normal → kayıttaki stok, kör/yok →
// boş. Kayıttaki stok ayrıca [CabinOperationStepEntry.recordedQuantity]'de
// tutulur — çıkarma üst sınırı kullanıcının sayımına değil ona bakar.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Backend'in boş göz için beklediği işaret tarihi — gerçek bir SKT değildir.
final DateTime kEmptyCellMiad = DateTime(2099, 12, 31);

bool _isMeaningfulMiad(DateTime? d) => d != null && d.year < kEmptyCellMiad.year;

DateTime? _earlier(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return b.isBefore(a) ? b : a;
}

/// Birim doz çekmecesinin tek bir gözünün girdisi.
class CabinOperationStepEntry {
  const CabinOperationStepEntry({this.countQuantity, this.secondaryQuantity, this.miadDate, this.recordedQuantity = 0});

  /// Kullanıcının sayımı. Kör sayımda / sayımsız ilaçta girilene kadar null.
  final double? countQuantity;

  /// İşleme özgü miktar — dolumda konulacak, boşaltma/imhada çıkarılacak,
  /// alımda alınacak (plandan, salt okunur).
  final double? secondaryQuantity;

  final DateTime? miadDate;

  /// Bu gözün kayıttaki stoğu (adet) — kullanıcı değiştiremez.
  final double recordedQuantity;

  CabinOperationStepEntry copyWith({
    double? countQuantity,
    double? secondaryQuantity,
    DateTime? miadDate,
    bool clearMiad = false,
  }) => CabinOperationStepEntry(
    countQuantity: countQuantity ?? this.countQuantity,
    secondaryQuantity: secondaryQuantity ?? this.secondaryQuantity,
    miadDate: clearMiad ? null : (miadDate ?? this.miadDate),
    recordedQuantity: recordedQuantity,
  );
}

class CabinOperationTarget implements DrawerJobTarget {
  CabinOperationTarget._({
    required this.mode,
    required this.assignment,
    required this.isKubik,
    required this.cubicCount,
    required this.cubicSecondary,
    required this.cubicMiad,
    required this.steps,
    required this.singleMiad,
    required this.countType,
    this.plannedQuantity,
    this.sourceId,
    this.openUntilStep,
    this.activeStepIndexes,
  });

  final CabinOperationMode mode;

  @override
  final MedicineAssignment assignment;

  final bool isKubik;

  /// Kübik sayım. Kör sayımda / sayımsız ilaçta girilene kadar null.
  final double? cubicCount;
  final double cubicSecondary;
  final DateTime? cubicMiad;

  /// Birim doz gözleri (kübikte boş).
  final List<CabinOperationStepEntry> steps;

  /// Tek SKT modunda tüm gözlere uygulanan tarih; göz tarihi boşsa buna bakılır.
  final DateTime? singleMiad;

  /// Sayım tipi: normal (stoktan doldurulur), kör (boş başlar, girilmesi
  /// zorunlu), yok (sayım alanı gösterilmez). Alım dışında normalCount.
  final CountType countType;

  /// Dolum listesinde planlanan miktar (adet). Diğer akışlarda null.
  final double? plannedQuantity;

  /// Hedefin kaynak kaydı — dolum listesinde RefillListDetail.id, alımda
  /// reçete detay/kalem id'si. Notifier kaynak veriye bununla döner.
  final int? sourceId;

  /// Birim doz çekmecenin açılacağı en arka göz (1 tabanlı) — öndeki N göz
  /// açılır. Alımda FIFO güvenliği: planın ulaştığı gözden daha arkadaki
  /// (daha yeni) partilere erişilemez. Diğer işlemlerde null (tam açılır).
  final int? openUntilStep;

  /// İşleme dahil gözler (0 tabanlı). null → tüm gözler. Alımda yalnızca
  /// plandaki gözler — tablo, doğrulama ve kayıt bunlara bakar.
  final Set<int>? activeStepIndexes;

  @override
  int? get explicitTargetStep => openUntilStep;

  bool isStepActive(int index) => activeStepIndexes?.contains(index) ?? true;

  Iterable<int> get _activeIndexes sync* {
    for (var i = 0; i < steps.length; i++) {
      if (isStepActive(i)) yield i;
    }
  }

  bool get showsCount => mode.hasCountField && countType != CountType.noCount;

  factory CabinOperationTarget.fromAssignment(
    MedicineAssignment assignment,
    CabinOperationMode mode, {
    CountType countType = CountType.normalCount,
    double? plannedQuantity,
    int? sourceId,
  }) {
    assert(mode.usesEntryTarget, '$mode kabin işlem target\'ı kullanmaz');

    final drawerConfig = assignment.drawerUnit?.drawerSlot?.drawerConfig;
    final isKubik = drawerConfig?.drawerType?.isKubik ?? false;
    final stocks = assignment.stocks ?? const <CabinStock>[];

    // Kör sayımda ve sayımsız ilaçta kayıttaki miktar kullanıcıya önceden
    // gösterilmez — sayım alanı boş başlar.
    final prefillCount = countType == CountType.normalCount;

    if (isKubik) {
      DateTime? miad;
      for (final s in stocks) {
        if ((s.quantity ?? 0) > 0 && _isMeaningfulMiad(s.miadDate)) miad = _earlier(miad, s.miadDate);
      }
      return CabinOperationTarget._(
        mode: mode,
        assignment: assignment,
        isKubik: true,
        cubicCount: prefillCount ? assignment.totalQuantity : null,
        cubicSecondary: 0,
        cubicMiad: miad,
        steps: const [],
        singleMiad: miad,
        countType: countType,
        plannedQuantity: plannedQuantity,
        sourceId: sourceId,
      );
    }

    final stepCount = drawerConfig?.numberOfSteps ?? 0;
    final quantities = List<double>.filled(stepCount, 0);
    final miads = List<DateTime?>.filled(stepCount, null);

    for (final s in stocks) {
      final i = (s.corpartmentNo ?? 0) - 1;
      if (i < 0 || i >= stepCount) continue; // tutarsız/eski veri
      final qty = (s.quantity ?? 0).toDouble();
      quantities[i] += qty;
      if (qty > 0 && _isMeaningfulMiad(s.miadDate)) miads[i] = _earlier(miads[i], s.miadDate);
    }

    return CabinOperationTarget._(
      mode: mode,
      assignment: assignment,
      isKubik: false,
      cubicCount: null,
      cubicSecondary: 0,
      cubicMiad: null,
      steps: List.generate(
        stepCount,
        (i) => CabinOperationStepEntry(
          countQuantity: prefillCount ? quantities[i] : null,
          miadDate: miads[i],
          recordedQuantity: quantities[i],
        ),
      ),
      singleMiad: miads.fold<DateTime?>(null, _earlier),
      countType: countType,
      plannedQuantity: plannedQuantity,
      sourceId: sourceId,
    );
  }

  int get numberOfSteps => steps.length;

  /// Kayıttaki mevcut stok (adet).
  double get currentQuantity => assignment.totalQuantity;

  double _entryValue(double? count, double? secondary) => (mode.hasSecondaryField ? secondary : count) ?? 0;

  bool hasEntryAt(int index) => _entryValue(steps[index].countQuantity, steps[index].secondaryQuantity) > 0;

  bool get hasEntry {
    if (isKubik) return _entryValue(cubicCount, cubicSecondary) > 0;
    return _activeIndexes.any(hasEntryAt);
  }

  /// Kayda hazır mı:
  ///   1. SKT isteyen işlemlerde girdi olan her yerde geçerli ve GEÇMEMİŞ SKT
  ///      (backend'in kontrolüyle aynı kural).
  ///   2. Kör sayımda aktif her yerde sayım girilmiş olmalı.
  ///   3. Stoktan çıkaran işlemlerde KAYITTAKİ miktardan fazlası çıkarılamaz.
  bool get isValid {
    if (mode.requiresMiad) {
      if (isKubik) {
        if (_entryValue(cubicCount, cubicSecondary) > 0 && (cubicMiad == null || cubicMiad.isExpiredMiad)) {
          return false;
        }
      } else {
        for (final i in _activeIndexes) {
          if (!hasEntryAt(i)) continue;
          final miad = steps[i].miadDate ?? singleMiad;
          if (miad == null || miad.isExpiredMiad) return false;
        }
      }
    }

    if (showsCount && countType == CountType.blindCount) {
      final missing = isKubik ? cubicCount == null : _activeIndexes.any((i) => steps[i].countQuantity == null);
      if (missing) return false;
    }

    if (mode.removesFromStock) {
      final exceeds = isKubik
          ? cubicSecondary > currentQuantity
          : _activeIndexes.any((i) => (steps[i].secondaryQuantity ?? 0) > steps[i].recordedQuantity);
      if (exceeds) return false;
    }

    return true;
  }

  // ── Değişiklikler ────────────────────────────────────────────────────

  CabinOperationTarget _copy({
    double? cubicCount,
    double? cubicSecondary,
    DateTime? cubicMiad,
    bool clearCubicMiad = false,
    List<CabinOperationStepEntry>? steps,
    DateTime? singleMiad,
    bool clearSingleMiad = false,
    int? openUntilStep,
    Set<int>? activeStepIndexes,
  }) => CabinOperationTarget._(
    mode: mode,
    assignment: assignment,
    isKubik: isKubik,
    cubicCount: cubicCount ?? this.cubicCount,
    cubicSecondary: cubicSecondary ?? this.cubicSecondary,
    cubicMiad: clearCubicMiad ? null : (cubicMiad ?? this.cubicMiad),
    steps: steps ?? this.steps,
    singleMiad: clearSingleMiad ? null : (singleMiad ?? this.singleMiad),
    countType: countType,
    plannedQuantity: plannedQuantity,
    sourceId: sourceId,
    openUntilStep: openUntilStep ?? this.openUntilStep,
    activeStepIndexes: activeStepIndexes ?? this.activeStepIndexes,
  );

  CabinOperationTarget withCubicCount(double v) => _copy(cubicCount: v);
  CabinOperationTarget withCubicSecondary(double v) => _copy(cubicSecondary: v);
  CabinOperationTarget withCubicMiad(DateTime? d) => _copy(cubicMiad: d, clearCubicMiad: d == null);

  /// Tek SKT modu: ortak tarihi tüm gözlere (boş olanlar dahil) yazar.
  CabinOperationTarget withSharedMiad(DateTime? d) => _copy(
    singleMiad: d,
    clearSingleMiad: d == null,
    steps: [for (final s in steps) s.copyWith(miadDate: d, clearMiad: d == null)],
  );

  CabinOperationTarget withStepCount(int i, double v) => _copyStep(i, (s) => s.copyWith(countQuantity: v));
  CabinOperationTarget withStepSecondary(int i, double v) => _copyStep(i, (s) => s.copyWith(secondaryQuantity: v));
  CabinOperationTarget withStepMiad(int i, DateTime? d) =>
      _copyStep(i, (s) => s.copyWith(miadDate: d, clearMiad: d == null));

  /// Alım planı: yalnızca [activeSteps] gözleri işleme dahil, çekmece
  /// [openUntilStep]'e kadar açılır.
  CabinOperationTarget withIntakePlan({required Set<int> activeSteps, required int openUntilStep}) =>
      _copy(activeStepIndexes: activeSteps, openUntilStep: openUntilStep);

  CabinOperationTarget _copyStep(int i, CabinOperationStepEntry Function(CabinOperationStepEntry) update) {
    if (i < 0 || i >= steps.length) return this;
    final next = List<CabinOperationStepEntry>.from(steps);
    next[i] = update(next[i]);
    return _copy(steps: next);
  }
}
