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

  /// Alınacak miktar — ADET cinsinden. Ordered alımda reçete dozundan
  /// türetilir (ölçü birimli ilaçta ml ÷ adet başına miktar), kullanıcı
  /// sınırlar içinde değiştirebilir. Stokla karşılaştırılır ve backend'e gider.
  final double? dosePiece;

  /// Reçetede yazılan miktar — REÇETE birimi (ölçü birimli ilaçta ml).
  /// Yalnızca gösterim ve doz sınırı hesabı için; adetle doğrudan
  /// karşılaştırılmaz. Reçetesiz alımda null.
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

extension IntakeItemExtensions on IntakeItem {
  /// Gözdeki toplam stok (adet).
  double get totalAmount => assignment?.totalQuantity ?? 0;

  String get totalAmountLabel => assignment?.quantityLabel(dosePiece ?? totalAmount) ?? '-';

  /// Stok yok ya da istenen miktarı (adet) karşılamıyor.
  bool get hasNoStock {
    final stocks = assignment?.stocks ?? const [];
    if (stocks.isEmpty) return true;

    // Ordered alımda istenen miktar bilinir — stok ondan azsa da yetersiz.
    // Orderless/free'de dosePiece null gelir — yalnızca stok sıfır mı bakılır.
    final requested = dosePiece ?? 0;
    return requested > 0 ? totalAmount < requested : totalAmount <= 0;
  }
}
