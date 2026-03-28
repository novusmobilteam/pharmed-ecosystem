// lib/feature/cabin_stock/data/repository/cabin_stock_repository_impl.dart
//
// [SWREQ-CORE-004] [HAZ-007]
// Repository katmanı — veri kaynağı seçimi ve cache stratejisi burada.
//
// Karar ağacı:
//
//   mock flavor
//     └─► MockDataSource → doğrudan domain'e
//
//   dev / prod flavor
//     └─► RemoteDataSource dene
//           ├─ Başarılı → Hive'a yaz → domain'e ilet
//           └─ Başarısız
//               ├─ Cache var + fresh  → Result.stale (uyarıyla göster)
//               ├─ Cache var + stale  → Result.failure (çok eski)
//               └─ Cache yok          → Result.failure
//
// Sınıf: Class B

import '../../../../core/cache/cabin_stock_cache.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/exception/app_exceptions.dart';
import '../../../../core/flavor/app_flavor.dart';
import '../../../../core/logging/med_logger.dart';
import '../datasource/cabin_stock_datasource.dart';
import '../dto/cabin_stock_dto.dart';
import '../../domain/model/cabin_stock.dart';
import '../../domain/mapper/cabin_stock_mapper.dart';

// ─────────────────────────────────────────────────────────────────
// Repository sonuç tipi — domain katmanına iletilir
// ─────────────────────────────────────────────────────────────────

sealed class RepoResult<T> {
  const RepoResult();
}

final class RepoSuccess<T> extends RepoResult<T> {
  const RepoSuccess(this.data);
  final T data;
}

/// [HAZ-007] Servis çöktü ama geçerli cache var → göster + uyar
final class RepoStale<T> extends RepoResult<T> {
  const RepoStale(this.data, this.savedAt);
  final T data;
  final DateTime savedAt;
}

final class RepoFailure<T> extends RepoResult<T> {
  const RepoFailure(this.error);
  final Object error;
}

// ─────────────────────────────────────────────────────────────────
// CabinStockRepositoryImpl
// ─────────────────────────────────────────────────────────────────

class CabinStockRepositoryImpl {
  CabinStockRepositoryImpl({
    required this.dataSource,
    required this.listCache,
    required this.singleCache,
    required this.mapper,
  });

  final CabinStockDataSource dataSource;
  final CabinStockListCache listCache;
  final CabinStockSingleCache singleCache;
  final CabinStockMapper mapper;

  final int _maxAgeMinutes = FlavorConfig.instance.cacheMaxAgeMinutes;
  final bool _cacheEnabled = FlavorConfig.instance.cacheEnabled;

  // ── getStocks ────────────────────────────────────────────────

  Future<RepoResult<List<CabinStock>>> getStocks(int cabinId) async {
    final cacheKey = CabinStockCacheKeys.stocks(cabinId);

    final result = await dataSource.getStocks(cabinId);

    return result.fold(
      // ── Başarılı ──────────────────────────────────────────────
      (dtoList) async {
        final domain = mapper.toDomainList(dtoList);

        // Cache'e yaz (mock flavor'da HiveCache zaten yoksayar)
        if (_cacheEnabled) {
          await listCache.write(cacheKey, dtoList);
        }

        MedLogger.info(
          unit: 'SW-UNIT-RE',
          swreq: 'SWREQ-CORE-004',
          message: 'getStocks başarılı',
          context: {'cabinId': cabinId, 'count': domain.length},
        );

        return RepoSuccess(domain);
      },

      // ── Başarısız ─────────────────────────────────────────────
      (error) async {
        MedLogger.warn(
          unit: 'SW-UNIT-RE',
          swreq: 'SWREQ-CORE-004',
          message: 'getStocks başarısız, cache kontrol ediliyor',
          context: {'cabinId': cabinId, 'error': error.toString()},
        );

        return _resolveCacheFallback<List<CabinStock>>(
          cacheKey: cacheKey,
          cache: listCache,
          map: (dtoList) => mapper.toDomainList(dtoList),
          error: error,
        );
      },
    );
  }

  // ── getCurrentCabinStock ─────────────────────────────────────

  Future<RepoResult<List<CabinStock>>> getCurrentCabinStock() async {
    final cacheKey = CabinStockCacheKeys.currentCabin();
    final result = await dataSource.getCurrentCabinStock();

    return result.fold(
      (dtoList) async {
        final domain = mapper.toDomainList(dtoList);
        if (_cacheEnabled) await listCache.write(cacheKey, dtoList);
        return RepoSuccess(domain);
      },
      (error) async => _resolveCacheFallback<List<CabinStock>>(
        cacheKey: cacheKey,
        cache: listCache,
        map: (dtoList) => mapper.toDomainList(dtoList),
        error: error,
      ),
    );
  }

  // ── getMedicineInfo ──────────────────────────────────────────

  Future<RepoResult<CabinStock>> getMedicineInfo(int medicineId) async {
    final cacheKey = CabinStockCacheKeys.medicineInfo(medicineId);
    final result = await dataSource.getMedicineInfo(medicineId);

    return result.fold(
      (dto) async {
        final domain = mapper.toDomain(dto);
        if (_cacheEnabled) await singleCache.write(cacheKey, dto);
        return RepoSuccess(domain);
      },
      (error) async {
        // NotFoundException → cache'e bakma, direkt ilet
        if (error is NotFoundException) return RepoFailure(error);

        return _resolveCacheFallback<CabinStock>(
          cacheKey: cacheKey,
          cache: singleCache,
          map: (dto) => mapper.toDomain(dto as CabinStockDTO),
          error: error,
        );
      },
    );
  }

  // ── getExpiringStocks ────────────────────────────────────────

  Future<RepoResult<List<CabinStock>>> getExpiringStocks() async {
    final cacheKey = CabinStockCacheKeys.expiringStocks();
    final result = await dataSource.getExpiringStocks();

    return result.fold(
      (dtoList) async {
        final domain = mapper.toDomainList(dtoList);
        if (_cacheEnabled) await listCache.write(cacheKey, dtoList);
        return RepoSuccess(domain);
      },
      (error) async => _resolveCacheFallback<List<CabinStock>>(
        cacheKey: cacheKey,
        cache: listCache,
        map: (dtoList) => mapper.toDomainList(dtoList),
        error: error,
      ),
    );
  }

  // ── Yazma işlemleri (count, fill, unload) ────────────────────
  // Yazma işlemlerinde cache fallback yok — hata direkt iletilir

  Future<RepoResult<void>> count(List<dynamic> data) async {
    final result = await dataSource.count(data);
    return result.fold((_) {
      // Başarılı yazma sonrası ilgili cache'leri geçersiz kıl
      listCache.invalidate(CabinStockCacheKeys.currentCabin());
      return const RepoSuccess(null);
    }, (error) => RepoFailure(error));
  }

  Future<RepoResult<void>> fill(List<dynamic> data) async {
    final result = await dataSource.fill(data);
    return result.fold((_) {
      listCache.invalidate(CabinStockCacheKeys.currentCabin());
      return const RepoSuccess(null);
    }, (error) => RepoFailure(error));
  }

  Future<RepoResult<void>> unload(List<Map<String, dynamic>> data) async {
    final result = await dataSource.unload(data);
    return result.fold((_) {
      listCache.invalidate(CabinStockCacheKeys.currentCabin());
      return const RepoSuccess(null);
    }, (error) => RepoFailure(error));
  }

  // ── Cache fallback yardımcı metodu ───────────────────────────

  Future<RepoResult<T>> _resolveCacheFallback<T>({
    required String cacheKey,
    required HiveCache cache,
    required T Function(dynamic) map,
    required Object error,
  }) async {
    if (!_cacheEnabled) return RepoFailure(error);

    final cached = await cache.read(cacheKey);

    if (cached == null) {
      MedLogger.warn(
        unit: 'SW-UNIT-RE',
        swreq: 'SWREQ-CORE-004',
        message: 'Cache bulunamadı',
        context: {'key': cacheKey},
      );
      return RepoFailure(error);
    }

    if (cached.isStale(_maxAgeMinutes)) {
      // [HAZ-007] Cache çok eski → gösterme, hata döndür
      MedLogger.warn(
        unit: 'SW-UNIT-RE',
        swreq: 'SWREQ-CORE-004',
        message: 'Cache çok eski, kullanılamaz',
        context: {'key': cacheKey, 'savedAt': cached.savedAt.toIso8601String(), 'maxAgeMinutes': _maxAgeMinutes},
      );
      return RepoFailure(error);
    }

    // [HAZ-007] Cache geçerli ama eski → RepoStale ile döndür
    MedLogger.info(
      unit: 'SW-UNIT-RE',
      swreq: 'SWREQ-CORE-004',
      message: 'Cache stale veri kullanılıyor',
      context: {'key': cacheKey, 'savedAt': cached.savedAt.toIso8601String()},
    );

    return RepoStale(map(cached.data), cached.savedAt);
  }
}
