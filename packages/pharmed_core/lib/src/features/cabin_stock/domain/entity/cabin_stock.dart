import 'package:pharmed_core/pharmed_core.dart';

class CabinStock {
  final int? id;
  final int? cabinId;
  final int? cabinDrawerId;
  final int? cabinDrawerDetailId;
  final int? materialId;
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
    this.materialId,
  });

  int? get remainingDay => miadDate != null ? miadDate!.difference(DateTime.now()).inDays : 0;

  String get remainingDayText => remainingDay?.toString() ?? '-';

  String get position =>
      '${cabinDrawerDetail?.drawerUnit?.drawerSlot?.address} / ${cabinDrawerDetail?.drawerUnit?.orderNo} ';

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

extension CabinStockMiadX on CabinStock {
  /// Forma başlangıç değeri olarak gösterilecek miad. Boş göz (miktar 0)
  /// veya backend'in boş göz işaret tarihi (2099-12-31) → null.
  DateTime? get effectiveMiad {
    final date = miadDate;
    if (date == null || (quantity ?? 0) <= 0) return null;
    if (date.year >= 2099) return null;
    return date;
  }
}
