// [SWREQ-CLI-INTAKE-ITEM-001] [IEC 62304 §5.5]
//
// Alım işlemi sırasında kullanıcıya gösterilen bir kalem. Üç alım tipini
// (ordered/orderless/free) tek tipte birleştirir — GetIntakeItemsUseCase
// bunu üretir.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class IntakeItem {
  IntakeItem({
    required this.id,
    this.dosePiece,
    this.prescriptionDose,
    this.assignment,
    required this.type,
    this.medicine,
    this.prescriptionItem,
    this.lastMovement,
    this.witnessContext = const WitnessContext(),
    this.equivalentWitnessContext = const WitnessContext(),
    this.firstDoseEmergency = false,
    this.askDoctor = false,
    this.inCaseOfNecessity = false,
    this.stock,
    this.selectedEquivalent,
    this.redirectedStation,
    this.redirectedOrder,
    this.time,
  });

  final int id;

  /// Kullanıcının alım yaparken değiştirebildiği miktar.
  /// Başlangıçta prescriptionDose ile aynı değerde fakat kullanıcı isterse
  /// bu miktarı değiştirebiliyor.
  final double? dosePiece;

  /// Reçetede yazılan miktar. Reçetesiz alımda null olacak.
  final double? prescriptionDose;

  /// İlacın kabindeki yeri.
  final MedicineAssignment? assignment;

  final Medicine? medicine;

  final PrescriptionItem? prescriptionItem;

  /// İlacın son hareketi (reçete kalemine ait).
  ///
  /// Servisten gelen `lastMovement` (detailStatus → [PrescriptionMovementType])
  /// buraya taşınır; kartta ilacın son durumunu göstermek için kullanılır.
  final PrescriptionItemMovement? lastMovement;

  final CabinStock? stock;

  /// Alım Tipi
  final IntakeType type;

  /// Şahit listesi/seçimi — isWitnessedPurchase ilaçlarda anlamlı.
  final WitnessContext witnessContext;

  /// Muadil seçildiğinde muadilin şahit gereksinimi (witnesses/stations) —
  /// ayrı tutulur ki orijinal medicine'in witnessContext'i kaybolmasın
  /// (kullanıcı muadil seçimini geri alırsa orijinale dönebilelim).
  final WitnessContext equivalentWitnessContext;

  final bool firstDoseEmergency;
  final bool askDoctor;
  final bool inCaseOfNecessity;

  /// Kullanıcının bu kalem için seçtiği muadil ilaç (stok yoksa ve muadil
  /// seçildiyse dolu). Doluysa alım, normal check/complete yerine
  /// equivalent check/complete servislerinden yapılır.
  final EquivalentMedicine? selectedEquivalent;

  final OtherStationMedicine? redirectedStation;

  final RedirectedIntakeOrder? redirectedOrder;

  final DateTime? time;

  bool get isEquivalentIntake => selectedEquivalent != null;

  bool get isRedirected => lastMovement?.type == PrescriptionMovementType.redirected;
  bool get isRedirectedIntake => redirectedOrder != null;

  /// Şahit kararları için kullanılacak GERÇEK context — muadil seçiliyse
  /// muadilin, değilse orijinal ilacın context'i.
  WitnessContext get activeWitnessContext => isEquivalentIntake ? equivalentWitnessContext : witnessContext;

  Medicine? get _witnessSubjectMedicine => selectedEquivalent?.medicine ?? medicine;

  /// İlacın son hareket tipi (kart durum chip'i için).
  PrescriptionMovementType? get movementType => lastMovement?.type;

  /// Bu kalem için şahit gerekir mi? — WitnessContext'e devrediliyor,
  /// yalnızca "hangi drug flag'i" (isWitnessedPurchase) sorusuna cevap verir.
  bool get _requiresWitnessFlag =>
      _witnessSubjectMedicine is Drug && (_witnessSubjectMedicine as Drug).isWitnessedPurchase;

  bool needsWitness({Station? currentStation}) =>
      activeWitnessContext.needsWitness(requiresWitness: _requiresWitnessFlag, currentStation: currentStation);

  bool isWitnessApproved({Station? currentStation}) =>
      activeWitnessContext.isApproved(requiresWitness: _requiresWitnessFlag, currentStation: currentStation);

  IntakeItem copyWith({
    double? dosePiece,
    WitnessContext? witnessContext,
    WitnessContext? equivalentWitnessContext,
    MedicineAssignment? assignment,
    PrescriptionItemMovement? lastMovement,
    PrescriptionItem? prescriptionItem,
    CabinStock? stock,
    EquivalentMedicine? selectedEquivalent,
    bool clearSelectedEquivalent = false,
    OtherStationMedicine? redirectedStation,
    DateTime? time,
    Medicine? medicine,
  }) {
    return IntakeItem(
      id: id,
      type: type,
      assignment: assignment ?? this.assignment,
      medicine: medicine ?? this.medicine,
      prescriptionItem: prescriptionItem ?? this.prescriptionItem,
      lastMovement: lastMovement ?? this.lastMovement,
      dosePiece: dosePiece ?? this.dosePiece,
      prescriptionDose: prescriptionDose,
      witnessContext: witnessContext ?? this.witnessContext,
      equivalentWitnessContext: clearSelectedEquivalent
          ? const WitnessContext()
          : (equivalentWitnessContext ?? this.equivalentWitnessContext),
      stock: stock ?? this.stock,
      firstDoseEmergency: firstDoseEmergency,
      askDoctor: askDoctor,
      inCaseOfNecessity: inCaseOfNecessity,
      selectedEquivalent: clearSelectedEquivalent ? null : (selectedEquivalent ?? this.selectedEquivalent),
      redirectedStation: redirectedStation ?? this.redirectedStation,
      redirectedOrder: redirectedOrder,
      time: time ?? this.time,
    );
  }
}

extension WithdrawItemExtensions on IntakeItem {
  String _formatNumber(double value) {
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }

  String get totalAmountLabel {
    final medicine = this.medicine;
    final drug = medicine is Drug ? medicine : null;

    final double physicalQty = (assignment?.stocks ?? []).fold(
      0.0,
      (sum, item) => sum + (item.quantity ?? 0).toDouble(),
    );

    if (drug != null && drug.isMeasureUnit == true) {
      final double totalDose = dosePiece ?? physicalQty;
      final String unit = drug.doseUnit?.name ?? "birim";
      return "${_formatNumber(totalDose)} $unit";
    } else {
      return "${_formatNumber(dosePiece ?? physicalQty)} Adet";
    }
  }

  bool get hasNoStock {
    final stocks = assignment?.stocks ?? const [];
    if (stocks.isEmpty) return true;
    final total = stocks.fold<double>(0, (sum, s) => sum + (s.quantity ?? 0).toDouble());
    return total <= 0;
  }

  double get totalAmount {
    final medicine = this.medicine;
    final drug = medicine is Drug ? medicine : null;
    final double physicalQty = (assignment?.stocks ?? []).fold(0, (sum, item) => sum + (item.quantity ?? 0));

    if (drug != null && drug.isMeasureUnit == true) {
      return physicalQty;
    }
    return physicalQty.toDouble();
  }
}
