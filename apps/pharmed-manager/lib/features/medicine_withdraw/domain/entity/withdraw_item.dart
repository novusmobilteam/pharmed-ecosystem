import '../../../../core/core.dart';
import '../../../cabin_assignment/domain/entity/cabin_assignment.dart';
import '../../../medicine/domain/entity/medicine.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import '../../../station/domain/entity/station.dart';

/// Alım işlemi sırasında kullanıcıya ilaçları göstermek için kullanılan model
class WithdrawItem {
  final int id;

  /// Kullanıcının alım yaparken değiştirebildiği miktar.
  /// Başlangıçta prescriptionDose ile aynı değerde fakat kullanıcı isterse
  /// bu miktarı değiştirebiliyor.
  final double? dosePiece;

  /// Reçetede yazılan miktar. Reçetesiz alımda null olacak.
  final double? prescriptionDose;

  /// İlacın kabindeki yeri.
  final CabinAssignment? assignment;

  /// İlaç bilgileri
  final Medicine? medicine;

  /// Reçete bilgileri
  final PrescriptionItem? prescriptionItem;

  /// Alım Tipi
  final WithdrawType type;

  /// İlacın alım işlemi sırasında şahit olabilecek kişilerin listesi.
  final List<User> witnesses;

  /// Alım işlemi sırasında ilaç için şahit olarak tanımlanan kişi.
  final User? witness;

  /// Şahit gereken istasyonların listesi
  final List<Station> stations;

  WithdrawItem({
    required this.id,
    this.dosePiece,
    this.prescriptionDose,
    this.assignment,
    required this.type,
    this.medicine,
    this.prescriptionItem,
    this.witnesses = const [],
    this.witness,
    this.stations = const [],
  });

  WithdrawItem copyWith({
    double? dosePiece,
    List<User>? witnesses,
    User? witness,
    List<Station>? stations,
    CabinAssignment? assignment,
  }) {
    return WithdrawItem(
      id: id,
      type: type,
      assignment: assignment ?? this.assignment,
      medicine: medicine,
      prescriptionItem: prescriptionItem,
      dosePiece: dosePiece ?? this.dosePiece,
      prescriptionDose: prescriptionDose,
      witnesses: witnesses ?? this.witnesses,
      witness: witness ?? this.witness,
      stations: stations ?? this.stations,
    );
  }
}

extension CabinAssignmentExtension on WithdrawItem {
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
}
