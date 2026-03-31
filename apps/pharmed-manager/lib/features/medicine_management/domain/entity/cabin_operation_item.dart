import '../../../../core/core.dart';

import '../../../prescription/domain/entity/prescription_item.dart';

/// Kabin işlemlerinde (alım, iade, fire/imha) ortak kullanılan model.
///
/// Her işlem tipi bu modele dönüştürülür ve UI katmanı yalnızca
/// bu modeli tanır.
class CabinOperationItem {
  final int id;

  /// İşlem tipi: alım, iade veya fire/imha
  final CabinOperationType operationType;

  // ---------------------------------------------------------------------------
  // Temel ilaç bilgisi — tüm işlem tiplerinde dolu
  // ---------------------------------------------------------------------------

  final Medicine? medicine;

  /// Kullanıcının işlem sırasında değiştirebildiği miktar.
  final double? dosePiece;

  /// İlacın kabindeki yeri. İadede de dolu gelir (hangi çekmeceden alındığı).
  final CabinAssignment? assignment;

  // ---------------------------------------------------------------------------
  // Geçmiş işlem bilgisi — iade ve fire/imha'da dolu, alımda null
  // ---------------------------------------------------------------------------

  /// İlacın daha önce alındığı tarih.
  final DateTime? applicationDate;

  /// İlacı daha önce alan kişi.
  final User? applicationUser;

  // ---------------------------------------------------------------------------
  // Reçete bilgisi — sadece ordered alımda dolu
  // ---------------------------------------------------------------------------

  final PrescriptionItem? prescriptionItem;

  // ---------------------------------------------------------------------------
  // Alıma özgü alanlar
  // ---------------------------------------------------------------------------

  /// Reçetede yazılan orijinal doz. Kullanıcı dosePiece'i değiştirse bile
  /// bu değer sabit kalır. Reçetesiz alımda null.
  final double? prescriptionDose;

  /// Alım alt tipi: orderli, ordersiz veya serbest.
  /// Yalnızca [CabinOperationType.withdraw]'da anlamlı.
  final WithdrawType? withdrawType;

  // ---------------------------------------------------------------------------
  // Şahit bilgisi — alım (isWitnessedPurchase) ve fire/imha'da (isWitnessedDisposal) kullanılır
  // İade'de witnesses boş liste, witness null gelir.
  // ---------------------------------------------------------------------------

  /// Şahit olabilecek kişilerin listesi (servisten gelir).
  final List<User> witnesses;

  /// Şahit olabilecek istasyonların listesi.
  final List<Station> stations;

  /// Kullanıcının seçtiği / giriş yaptığı şahit.
  final User? witness;

  /// Reçete kalemi durumu — tüm işlem tiplerinde gösterilir.
  /// Mapper'dan doldurulur, null ise badge gösterilmez.
  final PrescriptionStatus? status;

  const CabinOperationItem({
    required this.id,
    required this.operationType,
    this.medicine,
    this.dosePiece,
    this.assignment,
    this.applicationDate,
    this.applicationUser,
    this.prescriptionItem,
    this.prescriptionDose,
    this.withdrawType,
    this.witnesses = const [],
    this.stations = const [],
    this.witness,
    this.status,
  });

  // ---------------------------------------------------------------------------
  // Yardımcı getter'lar
  // ---------------------------------------------------------------------------

  /// Bu işlem için şahit gerekip gerekmediğini döner.
  ///
  /// [currentStation]: Kullanıcının bulunduğu istasyon.
  /// - İlaç [Drug] değilse (örn. MedicalConsumable) her zaman false döner.
  /// - İlaç Drug ise [isWitnessedPurchase] / [isWitnessedDisposal] kontrol edilir.
  /// - Şahit gereken istasyon listesi ([stations]) doluysa, kullanıcının
  ///   bulunduğu istasyon listede yoksa şahit gerekmez.
  /// - [stations] boşsa tüm istasyonlarda şahit gerekir.
  bool needsWitness({Station? currentStation}) {
    // Drug değilse şahit gerekmez
    final drug = medicine is Drug ? medicine as Drug : null;
    if (drug == null) return false;

    // Operasyon tipine göre şahitlik flag'ini kontrol et
    final bool witnessFlag = switch (operationType) {
      CabinOperationType.withdraw => drug.isWitnessedPurchase,
      CabinOperationType.disposal => drug.isWastageWitnessedPurchase,
      CabinOperationType.refund => false,
    };

    if (!witnessFlag) return false;

    // İstasyon listesi boşsa tüm istasyonlarda şahit gerekir
    if (stations.isEmpty) return true;

    // Liste doluysa sadece eşleşen istasyonda şahit gerekir
    if (currentStation == null) return false;
    return stations.any((s) => s.id == currentStation.id);
  }

  /// Seçili şahidin onaylanıp onaylanmadığını döner.
  bool isWitnessApproved({Station? currentStation}) => needsWitness(currentStation: currentStation) && witness != null;

  /// Reçete uyarılarının herhangi birinin aktif olup olmadığını döner.
  bool get hasWarnings =>
      (prescriptionItem?.firstDoseEmergency ?? false) ||
      (prescriptionItem?.askDoctor ?? false) ||
      (prescriptionItem?.inCaseOfNecessity ?? false);

  CabinOperationItem copyWith({
    double? dosePiece,
    List<User>? witnesses,
    User? witness,
    List<Station>? stations,
    PrescriptionStatus? status,
    CabinAssignment? assignment,
  }) {
    return CabinOperationItem(
      id: id,
      operationType: operationType,
      medicine: medicine,
      dosePiece: dosePiece ?? this.dosePiece,
      assignment: assignment ?? this.assignment,
      applicationDate: applicationDate,
      applicationUser: applicationUser,
      prescriptionItem: prescriptionItem,
      prescriptionDose: prescriptionDose,
      withdrawType: withdrawType,
      witnesses: witnesses ?? this.witnesses,
      stations: stations ?? this.stations,
      witness: witness ?? this.witness,
      status: status ?? this.status,
    );
  }
}

enum CabinOperationType {
  withdraw,
  refund,
  disposal;

  String get label => switch (this) {
    CabinOperationType.withdraw => 'Alım',
    CabinOperationType.refund => 'İade',
    CabinOperationType.disposal => 'Fire/İmha',
  };
}

// ---------------------------------------------------------------------------
// Miktar gösterimi için extension
// ---------------------------------------------------------------------------

extension CabinOperationItemDisplay on CabinOperationItem {
  /// Doz gösterimi: ölçü birimli ilaçlarda "50 ml", diğerlerinde "2 Adet"
  String get doseLabel => medicine?.formatAmount(dosePiece ?? 0) ?? '${dosePiece ?? 0} Adet';

  /// Kabindeki toplam fiziksel stok miktarı.
  double get physicalStock => (assignment?.stocks ?? []).fold(0.0, (sum, s) => sum + (s.quantity ?? 0).toDouble());

  /// Stok yoksa true.
  bool get hasNoStock => (assignment?.totalQuantity ?? 0.0) <= 0;
}
