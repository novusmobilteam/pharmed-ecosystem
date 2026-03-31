// lib/feature/cabin_stock/data/cache/cabin_stock_cache.dart
//
// [SWREQ-CORE-002]
// CabinStock feature'ına özel HiveCache instance'ları.
// Her endpoint için ayrı cache key kullanılır.

import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/cache/hive_cache.dart';

abstract final class CabinStockCacheKeys {
  static String stocks(int cabinId) => 'cabin_stocks_$cabinId';
  static String currentCabin() => 'current_cabin_stock';
  static String expiringStocks() => 'expiring_stocks';
  static String expiredStocks() => 'expired_stocks';
  static String stationStocks(int id) => 'station_stocks_$id';
  static String medicineInfo(int id) => 'medicine_info_$id';
}

// ─────────────────────────────────────────────────────────────────
// CabinStockListCache — List<CabinStockDTO> için cache
// ─────────────────────────────────────────────────────────────────

class CabinStockListCache extends HiveCache<List<CabinStockDTO>> {
  CabinStockListCache()
    : super(
        boxName: 'cabin_stock_list',
        serialize: (list) => list.map((e) => e.toJson()).toList(),
        deserialize: (raw) =>
            (raw as List).map((e) => CabinStockDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      );
}

// ─────────────────────────────────────────────────────────────────
// CabinStockSingleCache — CabinStockDTO? için cache
// ─────────────────────────────────────────────────────────────────

class CabinStockSingleCache extends HiveCache<CabinStockDTO?> {
  CabinStockSingleCache()
    : super(
        boxName: 'cabin_stock_single',
        serialize: (dto) => dto?.toJson(),
        deserialize: (raw) => raw == null ? null : CabinStockDTO.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
}
