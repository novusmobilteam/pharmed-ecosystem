// lib/feature/cabin_stock/domain/model/cabin_stock.dart
//
// [SWREQ-DO-MODEL-001]
// Domain modeli — null-safe, iş mantığı içerir.
// DTO'dan mapper üzerinden oluşturulur.
// UI ve use case'ler bu modeli kullanır, DTO'yu değil.

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────
// StockStatus — çekmece stok durumu
// [HAZ-003] DrawerCell renk sistemiyle birebir eşleşir
// ─────────────────────────────────────────────────────────────────

enum StockStatus {
  /// Yeterli stok
  full,

  /// Stok lowLevel'ın altında
  low,

  /// Stok criticalLevel'ın altında — yenileme gerekli
  critical,

  /// Çekmece boş veya ilaç atanmamış
  empty;

  static StockStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'full' => StockStatus.full,
      'low' => StockStatus.low,
      'critical' => StockStatus.critical,
      'empty' => StockStatus.empty,
      _ => StockStatus.empty,
    };
  }
}

// ─────────────────────────────────────────────────────────────────
// ExpiryStatus — SKT durumu
// [HAZ-008] SktRow renk sistemiyle birebir eşleşir
// ─────────────────────────────────────────────────────────────────

enum ExpiryStatus {
  /// SKT geçmiş — imha gerekli
  expired,

  /// SKT ≤7 gün kaldı
  critical,

  /// SKT 8-30 gün kaldı
  warning,

  /// SKT >30 gün veya tarih yok
  ok;

  static ExpiryStatus fromDate(DateTime? expiryDate) {
    if (expiryDate == null) return ExpiryStatus.ok;

    final now = DateTime.now();
    final daysLeft = expiryDate.difference(now).inDays;

    if (daysLeft < 0) return ExpiryStatus.expired;
    if (daysLeft <= 7) return ExpiryStatus.critical;
    if (daysLeft <= 30) return ExpiryStatus.warning;
    return ExpiryStatus.ok;
  }
}

// ─────────────────────────────────────────────────────────────────
// CabinStock — ana domain modeli
// ─────────────────────────────────────────────────────────────────

class CabinStock extends Equatable {
  const CabinStock({
    required this.id,
    required this.cabinId,
    required this.drawerId,
    required this.drawerCode,
    required this.drawerRow,
    required this.drawerColumn,
    required this.stockStatus,
    required this.expiryStatus,
    required this.isActive,
    this.medicineId,
    this.medicineName,
    this.medicineCode,
    this.unit,
    this.quantity,
    this.criticalLevel,
    this.lowLevel,
    this.lotNumber,
    this.expiryDate,
    this.lastUpdatedAt,
    this.lastUpdatedBy,
  });

  // ── Çekmece ──────────────────────────────────────────────────
  final int id;
  final int cabinId;
  final int drawerId;

  /// Örn: "A-01", "B-02"
  final String drawerCode;
  final int drawerRow;
  final int drawerColumn;

  // ── İlaç ─────────────────────────────────────────────────────
  final int? medicineId;
  final String? medicineName;
  final String? medicineCode;
  final String? unit;

  // ── Stok ─────────────────────────────────────────────────────
  final int? quantity;
  final int? criticalLevel;
  final int? lowLevel;
  final String? lotNumber;
  final DateTime? expiryDate;

  // ── Hesaplanan durumlar ───────────────────────────────────────
  final StockStatus stockStatus;
  final ExpiryStatus expiryStatus;
  final bool isActive;

  // ── Audit ─────────────────────────────────────────────────────
  final DateTime? lastUpdatedAt;
  final String? lastUpdatedBy;

  // ── Hesaplanan getter'lar ─────────────────────────────────────

  /// Çekmecede ilaç var mı?
  bool get hasMedicine => medicineId != null && medicineName != null;

  /// SKT'ye kaç gün kaldı (negatif → geçmiş)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// UI'da gösterilecek stok detay metni
  /// Örn: "12 kutu", "3 ampul", "6 torba"
  String get quantityLabel {
    if (quantity == null) return '—';
    if (unit == null) return '$quantity';
    return '$quantity $unit';
  }

  /// Çekmece görsel başlığı — tooltip için
  /// Örn: "A-01 · Amoksisilin 500mg"
  String get drawerTooltip {
    if (!hasMedicine) return '$drawerCode · Boş';
    return '$drawerCode · $medicineName';
  }

  /// SKT gösterim metni
  /// Örn: "SKT 29.03.26", "GEÇTİ"
  String get expiryLabel {
    if (expiryDate == null) return '—';
    if (expiryStatus == ExpiryStatus.expired) return 'GEÇTİ';
    final d = expiryDate!;
    return 'SKT ${d.day.toString().padLeft(2, '0')}'
        '.${d.month.toString().padLeft(2, '0')}'
        '.${d.year.toString().substring(2)}';
  }

  @override
  List<Object?> get props => [id, cabinId, drawerId, drawerCode, medicineId, quantity, stockStatus, expiryStatus];

  CabinStock copyWith({
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
    StockStatus? stockStatus,
    ExpiryStatus? expiryStatus,
    bool? isActive,
    DateTime? lastUpdatedAt,
    String? lastUpdatedBy,
  }) => CabinStock(
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
    expiryStatus: expiryStatus ?? this.expiryStatus,
    isActive: isActive ?? this.isActive,
    lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
  );
}
