// lib/feature/cabin_stock/data/dto/cabin_stock_dto.dart
//
// [SWREQ-DS-MODEL-001]
// Servis yanıtından birebir eşlenen ham veri modeli.
// İş mantığı içermez. Domain modele mapper üzerinden dönüşür.
// Nullable alanlar servisten null gelebileceği için nullable tutulur.

class CabinStockDTO {
  const CabinStockDTO({
    this.id,
    this.cabinId,
    this.drawerId,
    this.drawerCode,
    this.drawerRow,
    this.drawerColumn,
    this.medicineId,
    this.medicineName,
    this.medicineCode,
    this.unit,
    this.quantity,
    this.criticalLevel,
    this.lowLevel,
    this.lotNumber,
    this.expiryDate,
    this.stockStatus,
    this.isActive,
    this.lastUpdatedAt,
    this.lastUpdatedBy,
  });

  // ── Çekmece bilgileri ─────────────────────────────────────────
  final int? id;
  final int? cabinId;
  final int? drawerId;

  /// Örn: "A-01", "B-02", "C-03"
  final String? drawerCode;
  final int? drawerRow;
  final int? drawerColumn;

  // ── İlaç bilgileri ────────────────────────────────────────────
  final int? medicineId;

  /// Örn: "Amoksisilin 500mg", "İnsülin Glarjin 100 IU"
  final String? medicineName;

  /// Barkod / ilaç kodu
  final String? medicineCode;

  /// Örn: "mg", "IU", "ml", "torba", "ampul", "flakon", "kapsül", "kutu"
  final String? unit;

  // ── Stok bilgileri ────────────────────────────────────────────
  final int? quantity;

  /// Bu değerin altı → StockStatus.critical
  final int? criticalLevel;

  /// Bu değerin altı → StockStatus.low
  final int? lowLevel;

  // ── SKT bilgileri ─────────────────────────────────────────────
  final String? lotNumber;
  final DateTime? expiryDate;

  // ── Durum ─────────────────────────────────────────────────────
  /// Servis bu alanı string olarak döner: "full", "low", "critical", "empty"
  final String? stockStatus;
  final bool? isActive;

  // ── Audit ─────────────────────────────────────────────────────
  final DateTime? lastUpdatedAt;
  final String? lastUpdatedBy;

  factory CabinStockDTO.fromJson(Map<String, dynamic> json) {
    return CabinStockDTO(
      id: json['id'] as int?,
      cabinId: json['cabinId'] as int?,
      drawerId: json['drawerId'] as int?,
      drawerCode: json['drawerCode'] as String?,
      drawerRow: json['drawerRow'] as int?,
      drawerColumn: json['drawerColumn'] as int?,
      medicineId: json['medicineId'] as int?,
      medicineName: json['medicineName'] as String?,
      medicineCode: json['medicineCode'] as String?,
      unit: json['unit'] as String?,
      quantity: json['quantity'] as int?,
      criticalLevel: json['criticalLevel'] as int?,
      lowLevel: json['lowLevel'] as int?,
      lotNumber: json['lotNumber'] as String?,
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'] as String) : null,
      stockStatus: json['stockStatus'] as String?,
      isActive: json['isActive'] as bool?,
      lastUpdatedAt: json['lastUpdatedAt'] != null ? DateTime.tryParse(json['lastUpdatedAt'] as String) : null,
      lastUpdatedBy: json['lastUpdatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cabinId': cabinId,
    'drawerId': drawerId,
    'drawerCode': drawerCode,
    'drawerRow': drawerRow,
    'drawerColumn': drawerColumn,
    'medicineId': medicineId,
    'medicineName': medicineName,
    'medicineCode': medicineCode,
    'unit': unit,
    'quantity': quantity,
    'criticalLevel': criticalLevel,
    'lowLevel': lowLevel,
    'lotNumber': lotNumber,
    'expiryDate': expiryDate?.toIso8601String(),
    'stockStatus': stockStatus,
    'isActive': isActive,
    'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    'lastUpdatedBy': lastUpdatedBy,
  };

  CabinStockDTO copyWith({
    int? id,
    int? cabinId,
    int? drawerId,
    String? drawerCode,
    int? drawerRow,
    int? drawerColumn,
    int? medicineId,
    String? medicineName,
    String? medicineCode,
    String? unit,
    int? quantity,
    int? criticalLevel,
    int? lowLevel,
    String? lotNumber,
    DateTime? expiryDate,
    String? stockStatus,
    bool? isActive,
    DateTime? lastUpdatedAt,
    String? lastUpdatedBy,
  }) => CabinStockDTO(
    id: id ?? this.id,
    cabinId: cabinId ?? this.cabinId,
    drawerId: drawerId ?? this.drawerId,
    drawerCode: drawerCode ?? this.drawerCode,
    drawerRow: drawerRow ?? this.drawerRow,
    drawerColumn: drawerColumn ?? this.drawerColumn,
    medicineId: medicineId ?? this.medicineId,
    medicineName: medicineName ?? this.medicineName,
    medicineCode: medicineCode ?? this.medicineCode,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    criticalLevel: criticalLevel ?? this.criticalLevel,
    lowLevel: lowLevel ?? this.lowLevel,
    lotNumber: lotNumber ?? this.lotNumber,
    expiryDate: expiryDate ?? this.expiryDate,
    stockStatus: stockStatus ?? this.stockStatus,
    isActive: isActive ?? this.isActive,
    lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
  );
}
