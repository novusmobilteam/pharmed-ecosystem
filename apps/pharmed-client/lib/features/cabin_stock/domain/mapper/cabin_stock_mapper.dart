// lib/feature/cabin_stock/domain/mapper/cabin_stock_mapper.dart
//
// [SWREQ-DO-MAP-001] [HAZ-003]
// DTO → Domain dönüşümü.
// Her alan açıkça işlenir. Eksik/bozuk veri burada yakalanır.
// Sınıf: Class B

import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/exception/app_exceptions.dart';
import '../../data/dto/cabin_stock_dto.dart';
import '../model/cabin_stock.dart';

class CabinStockMapper {
  const CabinStockMapper();

  // ─────────────────────────────────────────────────────────────
  // toDomain — tek DTO → CabinStock
  // [HAZ-003] id veya drawerId null gelirse mapper exception fırlatır
  // ─────────────────────────────────────────────────────────────
  CabinStock toDomain(CabinStockDTO dto) {
    // Zorunlu alan kontrolü
    final id = dto.id;
    final cabinId = dto.cabinId;
    final drawerId = dto.drawerId;

    if (id == null || cabinId == null || drawerId == null) {
      MedLogger.error(
        unit: 'SW-UNIT-MAP',
        swreq: 'SWREQ-DO-MAP-001',
        message: 'CabinStockDTO zorunlu alan null',
        context: {'id': id, 'cabinId': cabinId, 'drawerId': drawerId},
      );
      throw MappingException(message: 'CabinStockDTO zorunlu alanlar null olamaz', dto: dto.toJson());
    }

    // ExpiryStatus — hesaplanır, servisten gelene güvenilmez
    final expiryStatus = ExpiryStatus.fromDate(dto.expiryDate);

    // StockStatus — servisten geleni kullan,
    // ama quantity/level ile çelişiyorsa hesaplanmış değeri tercih et
    final stockStatus = _resolveStockStatus(
      fromService: dto.stockStatus,
      quantity: dto.quantity,
      criticalLevel: dto.criticalLevel,
      lowLevel: dto.lowLevel,
    );

    return CabinStock(
      id: id,
      cabinId: cabinId,
      drawerId: drawerId,
      drawerCode: dto.drawerCode ?? '—',
      drawerRow: dto.drawerRow ?? 0,
      drawerColumn: dto.drawerColumn ?? 0,
      medicineId: dto.medicineId,
      medicineName: dto.medicineName,
      medicineCode: dto.medicineCode,
      unit: dto.unit,
      quantity: dto.quantity,
      criticalLevel: dto.criticalLevel,
      lowLevel: dto.lowLevel,
      lotNumber: dto.lotNumber,
      expiryDate: dto.expiryDate,
      stockStatus: stockStatus,
      expiryStatus: expiryStatus,
      isActive: dto.isActive ?? true,
      lastUpdatedAt: dto.lastUpdatedAt,
      lastUpdatedBy: dto.lastUpdatedBy,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // toDomainList — liste dönüşümü, hatalı elemanları filtreler
  // ─────────────────────────────────────────────────────────────
  List<CabinStock> toDomainList(List<CabinStockDTO> dtos) {
    final result = <CabinStock>[];

    for (final dto in dtos) {
      try {
        result.add(toDomain(dto));
      } on MappingException catch (e) {
        // [IEC 62304 §9.2] Tek hatalı eleman listeyi bozmaz, loglanır
        MedLogger.warn(
          unit: 'SW-UNIT-MAP',
          swreq: 'SWREQ-DO-MAP-001',
          message: 'Eleman atlandı: mapping hatası',
          context: {'error': e.message},
        );
      }
    }

    return result;
  }

  // ─────────────────────────────────────────────────────────────
  // _resolveStockStatus — servis değeri ile hesaplanan değeri uzlaştır
  // [HAZ-003] Servis yanlış status döndürebilir, quantity ile çapraz kontrol
  // ─────────────────────────────────────────────────────────────
  StockStatus _resolveStockStatus({
    required String? fromService,
    required int? quantity,
    required int? criticalLevel,
    required int? lowLevel,
  }) {
    // İlaç atanmamış / boş çekmece
    if (quantity == null || quantity == 0) return StockStatus.empty;

    // Quantity varsa kendi hesapla — servise körce güvenme
    if (criticalLevel != null && quantity <= criticalLevel) {
      return StockStatus.critical;
    }
    if (lowLevel != null && quantity <= lowLevel) {
      return StockStatus.low;
    }

    // Level bilgisi yoksa servisten gelen değeri kullan
    if (fromService != null) {
      return StockStatus.fromString(fromService);
    }

    return StockStatus.full;
  }
}
