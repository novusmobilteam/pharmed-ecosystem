// pharmed_data/lib/src/dashboard/repository/dashboard_repository_impl.dart
//
// [SWREQ-DATA-DASH-006] [IEC 62304 §5.5]
// IDashboardRepository implementasyonu.
// In-memory cache + TTL (5 dk) stratejisi.
// Hive kullanılmaz — uygulama yeniden başlatılınca cache sıfırlanır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// In-memory cache kaydı — veri + kaydedilme zamanı
class _CacheEntry<T> {
  _CacheEntry(this.data) : savedAt = DateTime.now();
  final T data;
  final DateTime savedAt;

  bool isExpired(Duration ttl) => DateTime.now().difference(savedAt) > ttl;
}

class DashboardRepositoryImpl implements IDashboardRepository {
  DashboardRepositoryImpl({
    required DashboardRemoteDataSource dataSource,
    required CabinStockMapper cabinStockMapper,
    required PrescriptionItemMapper prescriptionItemMapper,
    required PrescriptionMapper prescriptionMapper,
    required RefundMapper refundMapper,
    Duration cacheTtl = const Duration(minutes: 5),
  }) : _dataSource = dataSource,
       _cabinStockMapper = cabinStockMapper,
       _prescriptionItemMapper = prescriptionItemMapper,
       _prescriptionMapper = prescriptionMapper,
       _refundMapper = refundMapper,
       _ttl = cacheTtl;

  final DashboardRemoteDataSource _dataSource;
  final CabinStockMapper _cabinStockMapper;
  final PrescriptionItemMapper _prescriptionItemMapper;
  final PrescriptionMapper _prescriptionMapper;
  final RefundMapper _refundMapper;
  final Duration _ttl;

  // ── In-Memory Cache ────────────────────────────────────────────

  _CacheEntry<List<PrescriptionItem>>? _unreadQrCodes;
  _CacheEntry<List<CabinStock>>? _expiringMaterials;
  _CacheEntry<List<CabinStock>>? _criticalStocks;
  _CacheEntry<List<Prescription>>? _unappliedPrescriptions;
  _CacheEntry<List<Refund>>? _refunds;
  _CacheEntry<List<CabinStock>>? _generalStocks;
  _CacheEntry<List<PrescriptionItem>>? _upcomingTreatments;

  @override
  void clearCache() {
    _unreadQrCodes = null;
    _expiringMaterials = null;
    _criticalStocks = null;
    _unappliedPrescriptions = null;
    _refunds = null;
    _generalStocks = null;
    _upcomingTreatments = null;
  }

  // ── Yardımcı: cache kontrol + fetch ───────────────────────────

  Future<RepoResult<T>> _fetchWithCache<T>({
    required _CacheEntry<T>? cache,
    required void Function(_CacheEntry<T>) setCache,
    required Future<Result<T>> Function() fetch,
    bool forceRefresh = false,
  }) async {
    // Cache geçerliyse döndür
    if (!forceRefresh && cache != null && !cache.isExpired(_ttl)) {
      return RepoSuccess(cache.data);
    }

    final result = await fetch();

    return result.when(
      ok: (data) {
        setCache(_CacheEntry(data));
        return RepoSuccess(data);
      },
      error: (error) {
        // API başarısız ama eski cache var → RepoStale
        if (cache != null) {
          return RepoStale(cache.data, cache.savedAt);
        }
        return RepoFailure(error);
      },
    );
  }

  // ── Repository metodları ───────────────────────────────────────

  @override
  Future<RepoResult<List<PrescriptionItem>>> getUnreadQrCodes({bool forceRefresh = false}) {
    return _fetchWithCache(
      cache: _unreadQrCodes,
      setCache: (e) => _unreadQrCodes = e,
      forceRefresh: forceRefresh,
      fetch: () async {
        final result = await _dataSource.getUnreadQrCodes();
        return result.when(
          ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])),
          error: Result.error,
        );
      },
    );
  }

  @override
  Future<RepoResult<List<CabinStock>>> getExpiringMaterials({bool forceRefresh = false}) {
    return _fetchWithCache(
      cache: _expiringMaterials,
      setCache: (e) => _expiringMaterials = e,
      forceRefresh: forceRefresh,
      fetch: () async {
        final result = await _dataSource.getExpiringMaterials();
        return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<CabinStock>>> getCriticalStocks({bool isClient = false, bool forceRefresh = false}) {
    return _fetchWithCache(
      cache: _criticalStocks,
      setCache: (e) => _criticalStocks = e,
      forceRefresh: forceRefresh,
      fetch: () async {
        final result = await _dataSource.getCriticalStocks(isClient: isClient);
        return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<Prescription>>> getUnappliedPrescriptions({bool forceRefresh = false}) {
    return _fetchWithCache(
      cache: _unappliedPrescriptions,
      setCache: (e) => _unappliedPrescriptions = e,
      forceRefresh: forceRefresh,
      fetch: () async {
        final result = await _dataSource.getUnappliedPrescriptions();
        return result.when(ok: (dtos) => Result.ok(_prescriptionMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<Refund>>> getRefunds({bool forceRefresh = false}) {
    return _fetchWithCache(
      cache: _refunds,
      setCache: (e) => _refunds = e,
      forceRefresh: forceRefresh,
      fetch: () async {
        final result = await _dataSource.getRefunds();
        return result.when(ok: (dtos) => Result.ok(_refundMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<CabinStock>>> getGeneralStocks({bool forceRefresh = false}) {
    return _fetchWithCache(
      cache: _generalStocks,
      setCache: (e) => _generalStocks = e,
      forceRefresh: forceRefresh,
      fetch: () async {
        final result = await _dataSource.getGeneralStocks();
        return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<PrescriptionItem>>> getUpcomingTreatments({bool forceRefresh = false}) {
    return _fetchWithCache(
      cache: _upcomingTreatments,
      setCache: (e) => _upcomingTreatments = e,
      forceRefresh: forceRefresh,
      fetch: () async {
        final result = await _dataSource.getUpcomingTreatments();
        return result.when(
          ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])),
          error: Result.error,
        );
      },
    );
  }
}
