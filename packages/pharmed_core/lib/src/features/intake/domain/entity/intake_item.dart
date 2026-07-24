import 'package:pharmed_core/pharmed_core.dart';

/// Alım işlemi sırasında kullanıcıya ilaçları göstermek için kullanılan model
class IntakeItem {
  final int id;

  /// Kullanıcının alım yaparken değiştirebildiği miktar.
  /// Başlangıçta prescriptionDose ile aynı değerde fakat kullanıcı isterse
  /// bu miktarı değiştirebiliyor.
  final double? dosePiece;

  /// Reçetede yazılan miktar. Reçetesiz alımda null olacak.
  final double? prescriptionDose;

  /// İlacın kabindeki yeri.
  final MedicineAssignment? assignment;

  /// İlaç bilgileri
  final Medicine? medicine;

  /// Reçete bilgileri
  final PrescriptionItem? prescriptionItem;

  /// İlacın son hareketi (reçete kalemine ait).
  ///
  /// Servisten gelen `lastMovement` (detailStatus → [PrescriptionMovementType])
  /// buraya taşınır; kartta ilacın son durumunu göstermek için kullanılır.
  /// `prescriptionItem.lastMovement` İLE KARIŞTIRMA: servis o iç içe alanı
  /// göndermez; hareket bu seviyede tutulur.
  final PrescriptionItemMovement? lastMovement;

  /// Alım Tipi
  final IntakeType type;

  /// İlacın alım işlemi sırasında şahit olabilecek kişilerin listesi.
  final List<User> witnesses;

  /// Alım işlemi sırasında ilaç için şahit olarak tanımlanan kişi.
  final User? witness;

  /// Şahit gereken istasyonların listesi
  final List<Station> stations;

  final bool firstDoseEmergency;
  final bool askDoctor;
  final bool inCaseOfNecessity;

  IntakeItem({
    required this.id,
    this.dosePiece,
    this.prescriptionDose,
    this.assignment,
    required this.type,
    this.medicine,
    this.prescriptionItem,
    this.lastMovement,
    this.witnesses = const [],
    this.witness,
    this.stations = const [],
    this.firstDoseEmergency = false,
    this.askDoctor = false,
    this.inCaseOfNecessity = false,
  });

  /// İlacın son hareket tipi (kart durum chip'i için).
  PrescriptionMovementType? get movementType => lastMovement?.type;

  IntakeItem copyWith({
    double? dosePiece,
    List<User>? witnesses,
    User? witness,
    List<Station>? stations,
    MedicineAssignment? assignment,
    PrescriptionItemMovement? lastMovement,
    PrescriptionItem? prescriptionItem,
  }) {
    return IntakeItem(
      id: id,
      type: type,
      assignment: assignment ?? this.assignment,
      medicine: medicine,
      prescriptionItem: prescriptionItem ?? this.prescriptionItem,
      lastMovement: lastMovement ?? this.lastMovement,
      dosePiece: dosePiece ?? this.dosePiece,
      prescriptionDose: prescriptionDose,
      witnesses: witnesses ?? this.witnesses,
      witness: witness ?? this.witness,
      stations: stations ?? this.stations,
    );
  }
}

extension WithdrawItemExtensions on IntakeItem {
  // Klinik miktar gösterimi (Örn: "1000 ml" veya "10 Adet")
  // Sayıyı stringe çevirirken eğer .0 ise tam sayı, değilse olduğu gibi gösterir
  String _formatNumber(double value) {
    // Eğer sayı tam sayıya eşitse (örn: 76.0 == 76) küsuratsız yazdır
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }

  String get totalAmountLabel {
    final medicine = this.medicine;
    final drug = medicine is Drug ? medicine : null;

    // Toplam fiziksel adet (kutu/göz sayısı)
    final double physicalQty = (assignment?.stocks ?? []).fold(
      0.0,
      (sum, item) => sum + (item.quantity ?? 0).toDouble(),
    );

    if (drug != null && drug.isMeasureUnit == true) {
      // Ölçü birimi kullanılıyorsa: Fiziksel Adet * Baz Doz
      final double totalDose = dosePiece ?? physicalQty;
      final String unit = drug.doseUnit?.name ?? "birim";

      return "${_formatNumber(totalDose)} $unit";
    } else {
      // Ölçü birimi yoksa direkt adet göster (76.0 -> 76 Adet)
      return "${_formatNumber(dosePiece ?? physicalQty)} Adet";
    }
  }

  /// İlaç için kabinde alınabilir stok var mı?
  /// Atama yoksa veya tüm stok gözleri boşsa stok yok kabul edilir.
  bool get hasNoStock {
    final stocks = assignment?.stocks ?? const [];
    if (stocks.isEmpty) return true;
    final total = stocks.fold<double>(0, (sum, s) => sum + (s.quantity ?? 0).toDouble());
    return total <= 0;
  }

  // Sadece sayısal değer lazım olursa (Hesaplamalar için)
  double get totalAmount {
    final medicine = this.medicine;
    final drug = medicine is Drug ? medicine : null;
    final double physicalQty = (assignment?.stocks ?? []).fold(0, (sum, item) => sum + (item.quantity ?? 0));

    if (drug != null && drug.isMeasureUnit == true) {
      return physicalQty;
    }

    return physicalQty.toDouble();
  }

  /// Bu kalem için şahit gerekir mi?
  ///
  /// Yalnızca Drug + isWitnessedPurchase ilaçlarda gündeme gelir. İstasyon
  /// kısıtı varsa (stations boş değilse) sadece o istasyonlarda şahit istenir;
  /// stations boşsa şahitli ilaçta her istasyonda şahit gerekir.
  bool needsWitness({Station? currentStation}) {
    final med = medicine;
    if (med is! Drug) return false;
    if (!(med.isWitnessedPurchase)) return false;

    // İstasyon kısıtı yoksa her zaman şahit gerekir.
    if (stations.isEmpty) return true;

    // İstasyon kısıtı varsa: kullanıcının istasyonu listede mi?
    if (currentStation == null) return true;
    return stations.any((s) => s.id == currentStation.id);
  }
}
