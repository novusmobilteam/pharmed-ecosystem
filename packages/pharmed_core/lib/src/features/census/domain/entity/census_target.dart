// [SWREQ-CLI-MCENSUS-004] [IEC 62304 §5.5]
// Tek bir MedicineAssignment'a (bir kübik göz VEYA bir birim doz çekmecesi)
// yapılacak SAYIM hedefini temsil eder. RefillFillTarget'ın census karşılığı
// — farkla: fillingQuantity ve singleMiad YOK. Sayımda kullanıcı sadece
// "gerçekte kaç adet var + SKT ne" girer, dolum miktarı diye bir şey yok,
// ve SKT her zaman per-cell'dir (sayım fiziksel durumu kaydeder, tek bir
// SKT'ye indirgemenin bir anlamı yok).
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CensusStepEntry {
  const CensusStepEntry({this.countQuantity, this.miadDate});

  final double? countQuantity;
  final DateTime? miadDate;

  bool get hasEntry => (countQuantity ?? 0) > 0;

  CensusStepEntry copyWith({double? countQuantity, DateTime? miadDate, bool clearMiad = false}) {
    return CensusStepEntry(
      countQuantity: countQuantity ?? this.countQuantity,
      miadDate: clearMiad ? null : (miadDate ?? this.miadDate),
    );
  }
}

class CensusTarget {
  CensusTarget._({
    required this.assignment,
    required this.isKubik,
    required this.numberOfSteps,
    required this.cubicCount,
    required this.cubicMiad,
    required this.steps,
  });

  final MedicineAssignment assignment;
  final bool isKubik;

  /// Birim doz çekmecesinin göz/kademe sayısı (kübikte 0).
  final int numberOfSteps;

  final double cubicCount;
  final DateTime? cubicMiad;

  /// Birim doz girdileri (numberOfSteps uzunluğunda).
  final List<CensusStepEntry> steps;

  /// Mevcut stoktan başlangıç değerlerini yükler — RefillFillTarget.
  /// fromAssignment ile AYNI desen (stok→başlangıç eşlemesi), sadece
  /// fillingQuantity/singleMiad hiç yok.
  factory CensusTarget.fromAssignment(MedicineAssignment assignment) {
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final numberOfSteps = assignment.drawerUnit?.drawerSlot?.drawerConfig?.numberOfSteps ?? 0;
    final medicine = assignment.medicine;
    final stocks = assignment.stocks ?? const <CabinStock>[];

    if (isKubik) {
      final hasStock = stocks.isNotEmpty;
      final rawQty = assignment.totalQuantity.toDouble();
      final cubicCount = medicine != null ? medicine.fromFillingBackendValue(rawQty) : rawQty;
      final cubicMiad = rawQty > 0 ? (hasStock ? stocks.first.miadDate : null) : null;

      return CensusTarget._(
        assignment: assignment,
        isKubik: true,
        numberOfSteps: 0,
        cubicCount: cubicCount,
        cubicMiad: cubicMiad,
        steps: const [],
      );
    }

    final entries = List.generate(numberOfSteps, (_) => const CensusStepEntry());
    for (final stock in stocks) {
      final index = (stock.corpartmentNo ?? 0) - 1;
      if (index < 0 || index >= numberOfSteps) continue;

      final rawQty = (stock.quantity ?? 0).toDouble();
      final count = medicine != null ? medicine.fromFillingBackendValue(rawQty) : rawQty;
      final miad = (stock.quantity ?? 0) > 0 ? stock.miadDate : null;

      entries[index] = entries[index].copyWith(countQuantity: count, miadDate: miad);
    }

    return CensusTarget._(
      assignment: assignment,
      isKubik: false,
      numberOfSteps: numberOfSteps,
      cubicCount: 0,
      cubicMiad: null,
      steps: entries,
    );
  }

  DrawerUnit? get unit => assignment.drawerUnit;

  double get currentQuantity => assignment.toDisplayQuantity(assignment.totalQuantity);

  /// Kaydetmeye değer en az bir sayım girildi mi?
  bool get hasEntry => isKubik ? cubicCount > 0 : steps.any((s) => s.hasEntry);

  /// Sayım geçerli mi — girilen her yerde (kübik ya da göz) miad da
  /// girilmiş olmalı. Refill'deki singleMiad fallback'i burada YOK.
  bool get isValid {
    if (isKubik) return cubicCount <= 0 || cubicMiad != null;
    for (final s in steps) {
      if (s.hasEntry && s.miadDate == null) return false;
    }
    return true;
  }

  CensusTarget _copy({
    double? cubicCount,
    DateTime? cubicMiad,
    bool clearCubicMiad = false,
    List<CensusStepEntry>? steps,
  }) {
    return CensusTarget._(
      assignment: assignment,
      isKubik: isKubik,
      numberOfSteps: numberOfSteps,
      cubicCount: cubicCount ?? this.cubicCount,
      cubicMiad: clearCubicMiad ? null : (cubicMiad ?? this.cubicMiad),
      steps: steps ?? this.steps,
    );
  }

  CensusTarget withCubicCount(double v) => _copy(cubicCount: v);
  CensusTarget withCubicMiad(DateTime? d) => _copy(cubicMiad: d, clearCubicMiad: d == null);

  CensusTarget withStepCount(int index, double v) => _copyStep(index, (s) => s.copyWith(countQuantity: v));
  CensusTarget withStepMiad(int index, DateTime? d) =>
      _copyStep(index, (s) => s.copyWith(miadDate: d, clearMiad: d == null));

  CensusTarget _copyStep(int index, CensusStepEntry Function(CensusStepEntry) update) {
    if (index < 0 || index >= steps.length) return this;
    final next = List<CensusStepEntry>.from(steps);
    next[index] = update(next[index]);
    return _copy(steps: next);
  }
}
