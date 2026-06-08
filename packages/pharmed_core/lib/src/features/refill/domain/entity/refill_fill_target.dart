// [SWREQ-CLI-MREFILL-010] [IEC 62304 §5.5]
// Tek bir MedicineAssignment'a (bir kübik göz VEYA bir birim doz çekmecesi)
// yapılacak dolum hedefini temsil eder.
//
// Eski CabinInventoryNotifier mantığı birebir taşınmıştır:
//   - Kübik çekmece: tek sayım/dolum/miad değeri (cubic*).
//   - Birim doz çekmece: numberOfSteps kadar göz; her göz için ayrı
//     sayım/dolum/miad (steps listesi). isPerCellMiad=false ise tek miad.
//
// Backend'e gönderilecek cabinDrawerDetailId değerleri assignment.cabinDrawerDetail
// (DrawerCell) listesinden çözülür.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Birim doz çekmecesinde tek bir gözün (step) girdisi.
class RefillStepEntry {
  const RefillStepEntry({this.countQuantity = 0, this.fillingQuantity = 0, this.miadDate});

  final double countQuantity;
  final double fillingQuantity;
  final DateTime? miadDate;

  bool get hasFilling => fillingQuantity > 0;

  RefillStepEntry copyWith({
    double? countQuantity,
    double? fillingQuantity,
    DateTime? miadDate,
    bool clearMiad = false,
  }) {
    return RefillStepEntry(
      countQuantity: countQuantity ?? this.countQuantity,
      fillingQuantity: fillingQuantity ?? this.fillingQuantity,
      miadDate: clearMiad ? null : (miadDate ?? this.miadDate),
    );
  }
}

class RefillFillTarget {
  RefillFillTarget._({
    required this.assignment,
    required this.isKubik,
    required this.numberOfSteps,
    required this.cubicCount,
    required this.cubicFilling,
    required this.cubicMiad,
    required this.steps,
    required this.singleMiad,
  });

  /// Bu hedefin ilaç ataması — ilaç, birim modu, mevcut stok, DrawerCell listesi.
  final MedicineAssignment assignment;

  final bool isKubik;

  /// Birim doz çekmecesinin göz/kademe sayısı (kübikte 0).
  final int numberOfSteps;

  // Kübik girdileri
  final double cubicCount;
  final double cubicFilling;
  final DateTime? cubicMiad;

  // Birim doz girdileri (numberOfSteps uzunluğunda)
  final List<RefillStepEntry> steps;

  /// isPerCellMiad=false birim doz çekmecede tüm gözlere uygulanan tek miad.
  final DateTime? singleMiad;

  // ── Fabrika: assignment'tan başlangıç hedefi üretir ────────────────────────

  /// Mevcut stoktan başlangıç değerlerini yükler (eski _initFromStocks mantığı).
  factory RefillFillTarget.fromAssignment(MedicineAssignment assignment) {
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final numberOfSteps = assignment.drawerUnit?.drawerSlot?.drawerConfig?.numberOfSteps ?? 0;
    final medicine = assignment.medicine;
    final stocks = assignment.stocks ?? const <CabinStock>[];

    if (isKubik) {
      // Kübik: tek stok kaydından sayım + miad (refill: backend→adet).
      final hasStock = stocks.isNotEmpty;
      final rawQty = assignment.totalQuantity.toDouble();
      final cubicCount = medicine != null ? medicine.fromFillingBackendValue(rawQty) : rawQty;
      final cubicMiad = rawQty > 0 ? (hasStock ? stocks.first.miadDate : null) : null;

      return RefillFillTarget._(
        assignment: assignment,
        isKubik: true,
        numberOfSteps: 0,
        cubicCount: cubicCount,
        cubicFilling: 0,
        cubicMiad: cubicMiad,
        steps: const [],
        singleMiad: cubicMiad,
      );
    }

    // Birim doz: her göz için stoktan sayım + miad yükle (corpartmentNo eşleme).
    final entries = List.generate(numberOfSteps, (_) => const RefillStepEntry());
    DateTime? earliestMiad;

    for (final stock in stocks) {
      final index = (stock.corpartmentNo ?? 0) - 1;
      if (index < 0 || index >= numberOfSteps) continue;

      final rawQty = (stock.quantity ?? 0).toDouble();
      final count = medicine != null ? medicine.fromFillingBackendValue(rawQty) : rawQty;
      final miad = (stock.quantity ?? 0) > 0 ? stock.miadDate : null;

      entries[index] = entries[index].copyWith(countQuantity: count, miadDate: miad);

      if (miad != null && (stock.quantity ?? 0) != 0) {
        if (earliestMiad == null || miad.isBefore(earliestMiad)) earliestMiad = miad;
      }
    }

    return RefillFillTarget._(
      assignment: assignment,
      isKubik: false,
      numberOfSteps: numberOfSteps,
      cubicCount: 0,
      cubicFilling: 0,
      cubicMiad: null,
      steps: entries,
      singleMiad: earliestMiad,
    );
  }

  // ── Türetilen ──────────────────────────────────────────────────────────

  DrawerUnit? get unit => assignment.drawerUnit;
  int? get unitId => assignment.cabinDrawerId;

  /// Mevcut stok (adet, gösterim için).
  double get currentQuantity => assignment.toDisplayQuantity(assignment.totalQuantity);

  /// Kaydetmeye değer en az bir dolum var mı?
  bool get hasFilling => isKubik ? cubicFilling > 0 : steps.any((s) => s.hasFilling);

  /// Bu hedef geçerli mi? (dolum varsa miad zorunlu — refill kuralı)
  bool get isValid {
    if (isKubik) return cubicFilling <= 0 || cubicMiad != null;
    // Birim doz: dolum girilen her gözde miad olmalı (per-cell veya single).
    for (final s in steps) {
      if (s.hasFilling && s.miadDate == null && singleMiad == null) return false;
    }
    return true;
  }

  // ── copyWith ────────────────────────────────────────────────────────────

  RefillFillTarget _copy({
    double? cubicCount,
    double? cubicFilling,
    DateTime? cubicMiad,
    bool clearCubicMiad = false,
    List<RefillStepEntry>? steps,
    DateTime? singleMiad,
    bool clearSingleMiad = false,
  }) {
    return RefillFillTarget._(
      assignment: assignment,
      isKubik: isKubik,
      numberOfSteps: numberOfSteps,
      cubicCount: cubicCount ?? this.cubicCount,
      cubicFilling: cubicFilling ?? this.cubicFilling,
      cubicMiad: clearCubicMiad ? null : (cubicMiad ?? this.cubicMiad),
      steps: steps ?? this.steps,
      singleMiad: clearSingleMiad ? null : (singleMiad ?? this.singleMiad),
    );
  }

  RefillFillTarget withCubicCount(double v) => _copy(cubicCount: v);
  RefillFillTarget withCubicFilling(double v) => _copy(cubicFilling: v);
  RefillFillTarget withCubicMiad(DateTime? d) => _copy(cubicMiad: d, clearCubicMiad: d == null);
  RefillFillTarget withSingleMiad(DateTime? d) => _copy(singleMiad: d, clearSingleMiad: d == null);

  RefillFillTarget withStepCount(int index, double v) => _copyStep(index, (s) => s.copyWith(countQuantity: v));
  RefillFillTarget withStepFilling(int index, double v) => _copyStep(index, (s) => s.copyWith(fillingQuantity: v));
  RefillFillTarget withStepMiad(int index, DateTime? d) =>
      _copyStep(index, (s) => s.copyWith(miadDate: d, clearMiad: d == null));

  RefillFillTarget _copyStep(int index, RefillStepEntry Function(RefillStepEntry) update) {
    if (index < 0 || index >= steps.length) return this;
    final next = List<RefillStepEntry>.from(steps);
    next[index] = update(next[index]);
    return _copy(steps: next);
  }
}
