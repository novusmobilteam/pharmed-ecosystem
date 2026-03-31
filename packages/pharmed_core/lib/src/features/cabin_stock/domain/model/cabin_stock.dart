import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class CabinStock implements TableData {
  final int? id;
  final int? cabinId;
  final int? cabinDrawerId;
  final int? cabinDrawerDetailId;
  final int? corpartmentNo;
  final int? shelfNo;
  final num? quantity;
  final DateTime? miadDate;
  final Medicine? medicine;
  final CabinAssignment? assignment;
  final DrawerCell? cabinDrawerDetail;

  double get stockRatio => (quantity ?? 0.0) / (assignment?.criticalQuantity ?? 1.0);

  /// Son kullanma tarihine kaç gün kaldığını döndüren getter
  int get daysUntilExpiration {
    final now = DateTime.now();
    // Zaman farkını gün cinsinden hesapla
    return miadDate?.difference(now).inDays ?? 0;
  }

  /// UI'da direkt göstermek için anlamlı bir metin döndüren getter
  String get expirationStatusText {
    final days = daysUntilExpiration;

    if (days < 0) {
      return "${days.abs()} gün önce bitti"; // Tarihi geçmiş
    } else if (days == 0) {
      return "Bugün son gün!";
    } else if (days <= 7) {
      return "$days gün kaldı (Kritik)";
    } else {
      return "$days gün kaldı";
    }
  }

  Color get statusColor {
    final days = daysUntilExpiration;
    if (days < 0) return Colors.red;
    if (days <= 7) return Colors.orange;
    return Colors.green;
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
    CabinAssignment? assignment,
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

  CabinStockDTO toDTO() {
    return CabinStockDTO(
      id: id,
      cabinId: cabinId,
      cabinDrawerId: cabinDrawerId,
      corpartmentNo: corpartmentNo,
      shelfNo: shelfNo,
      quantity: quantity,
      miadDate: miadDate,
      medicine: MedicineMapper().toDtoOrNull(medicine),
      cabinDrawerQuantity: assignment?.toDTO(),
      cabinDrawerDetail: DrawerCellMapper().toDtoOrNull(cabinDrawerDetail),
    );
  }

  @override
  List get content => [
    medicine?.barcode,
    medicine?.name,
    assignment?.cabin?.name,
    '$shelfNo/$corpartmentNo',
    ' ${assignment?.minQuantity} ${medicine?.operationUnit}',
    ' ${assignment?.maxQuantity} ${medicine?.operationUnit}',
    ' ${assignment?.criticalQuantity} ${medicine?.operationUnit}',
    '${quantity?.formatFractional} ${medicine?.operationUnit}',
    miadDate?.formattedDate,
    remainingDay,
  ];

  @override
  List<String?> get titles => [
    'Barkod',
    'Malzeme',
    'Kabin',
    'Konum',
    'Minimum',
    'Maksimum',
    'Kritik',
    'Miktar',
    'S.K.T',
    'Kalan Gün',
  ];

  @override
  List<dynamic> get rawContent => [
    medicine?.barcode,
    medicine?.name,
    assignment?.cabin?.name,
    assignment?.drawerUnit?.compartmentNo,
    assignment?.drawerUnit?.orderNo,
    assignment?.minQuantity,
    assignment?.maxQuantity,
    quantity,
    miadDate?.formattedDate,
    remainingDayText,
  ];

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
