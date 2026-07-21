import 'package:pharmed_core/pharmed_core.dart';

class CabinStock {
  final int? id;
  final int? cabinId;
  final int? cabinDrawerId;
  final int? cabinDrawerDetailId;
  final int? corpartmentNo;
  final int? shelfNo;
  final num? quantity;
  final DateTime? miadDate;
  final Medicine? medicine;
  final MedicineAssignment? assignment;
  final DrawerCell? cabinDrawerDetail;

  double get stockRatio => (quantity ?? 0.0) / (assignment?.criticalQuantity ?? 1.0);

  /// Son kullanma tarihine kaç gün kaldığını döndüren getter
  int get daysUntilExpiration {
    final now = DateTime.now();
    // Zaman farkını gün cinsinden hesapla
    return miadDate?.difference(now).inDays ?? 0;
  }

  CabinStock({
    this.id,
    this.cabinId,
    this.cabinDrawerId,
    this.cabinDrawerDetailId,
    this.corpartmentNo,
    this.shelfNo,
    this.quantity,
    this.miadDate,
    this.medicine,
    this.assignment,
    this.cabinDrawerDetail,
  });

  int? get remainingDay => miadDate != null ? miadDate!.difference(DateTime.now()).inDays : 0;

  String get remainingDayText => remainingDay?.toString() ?? '-';

  // String get position =>
  //     '${cabinDrawerDetail?.cabinDrawer?.drawerSlot?.address} / ${cabinDrawerDetail?.cabinDrawer?.orderNo} ';

  CabinStock copyWith({
    int? id,
    int? cabinId,
    int? cabinDrawerId,
    int? corpartmentNo,
    double? quantity,
    DateTime? miadDate,
    Medicine? medicine,
    MedicineAssignment? assignment,
    DrawerCell? cabinDrawerDetail,
  }) {
    return CabinStock(
      id: id ?? this.id,
      cabinId: cabinId ?? this.cabinId,
      quantity: quantity,
      cabinDrawerId: cabinDrawerId ?? this.cabinDrawerId,
      corpartmentNo: corpartmentNo ?? this.corpartmentNo,
      miadDate: miadDate ?? this.miadDate,
      medicine: medicine ?? this.medicine,
      assignment: assignment ?? this.assignment,
      cabinDrawerDetail: cabinDrawerDetail ?? this.cabinDrawerDetail,
    );
  }

  factory CabinStock.empty({required int cabinId, required int unitId}) {
    return CabinStock(cabinId: cabinId, cabinDrawerId: unitId, medicine: null, quantity: null, assignment: null);
  }
}

extension CabinAssignmentExtension on CabinStock {
  // Klinik miktar gösterimi (Örn: "1000 ml" veya "10 Adet")
  // Sayıyı stringe çevirirken eğer .0 ise tam sayı, değilse olduğu gibi gösterir
  String _formatNumber(double value) {
    // Eğer sayı tam sayıya eşitse (örn: 76.0 == 76) küsuratsız yazdır
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }

  String get totalQuantityLabel {
    final medicine = this.medicine;
    final drug = medicine is Drug ? medicine : null;

    if (drug != null && drug.isMeasureUnit == true) {
      // Ölçü birimi kullanılıyorsa: Fiziksel Adet * Baz Doz
      final double totalDose = quantity?.toDouble() ?? 0.0;
      final String unit = drug.doseUnit?.name ?? "birim";

      return "${_formatNumber(totalDose)} $unit";
    } else {
      // Ölçü birimi yoksa direkt adet göster (76.0 -> 76 Adet)
      return "${_formatNumber(quantity?.toDouble() ?? 0)} Adet";
    }
  }
}
