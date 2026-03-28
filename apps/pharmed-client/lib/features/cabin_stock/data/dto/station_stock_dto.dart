// lib/feature/cabin_stock/data/dto/station_stock_dto.dart
//
// [SWREQ-DS-MODEL-002]
// İstasyon stok özet modeli.

class StationStockDTO {
  const StationStockDTO({
    this.id,
    this.stationId,
    this.stationName,
    this.medicineId,
    this.medicineName,
    this.unit,
    this.totalQuantity,
    this.criticalLevel,
    this.stockStatus,
    this.lastUpdatedAt,
  });

  final int? id;
  final int? stationId;
  final String? stationName;
  final int? medicineId;
  final String? medicineName;
  final String? unit;
  final int? totalQuantity;
  final int? criticalLevel;
  final String? stockStatus;
  final DateTime? lastUpdatedAt;

  factory StationStockDTO.fromJson(Map<String, dynamic> json) {
    return StationStockDTO(
      id: json['id'] as int?,
      stationId: json['stationId'] as int?,
      stationName: json['stationName'] as String?,
      medicineId: json['medicineId'] as int?,
      medicineName: json['medicineName'] as String?,
      unit: json['unit'] as String?,
      totalQuantity: json['totalQuantity'] as int?,
      criticalLevel: json['criticalLevel'] as int?,
      stockStatus: json['stockStatus'] as String?,
      lastUpdatedAt: json['lastUpdatedAt'] != null ? DateTime.tryParse(json['lastUpdatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stationId': stationId,
    'stationName': stationName,
    'medicineId': medicineId,
    'medicineName': medicineName,
    'unit': unit,
    'totalQuantity': totalQuantity,
    'criticalLevel': criticalLevel,
    'stockStatus': stockStatus,
    'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
  };
}
