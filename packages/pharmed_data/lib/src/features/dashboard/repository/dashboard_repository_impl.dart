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

class DashboardRepositoryImpl implements IDashboardRepository {
  DashboardRepositoryImpl({
    required DashboardRemoteDataSource dataSource,
    required CabinStockMapper cabinStockMapper,
    required PrescriptionItemMapper prescriptionItemMapper,
    required PrescriptionMapper prescriptionMapper,
    required RefundMapper refundMapper,
    required MenuTreeMapper menuMapper,
    Duration cacheTtl = const Duration(minutes: 5),
  }) : _dataSource = dataSource,
       _cabinStockMapper = cabinStockMapper,
       _prescriptionItemMapper = prescriptionItemMapper,
       _prescriptionMapper = prescriptionMapper,
       _refundMapper = refundMapper,
       _menuMapper = menuMapper,
       _ttl = cacheTtl;

  final DashboardRemoteDataSource _dataSource;
  final CabinStockMapper _cabinStockMapper;
  final PrescriptionItemMapper _prescriptionItemMapper;
  final PrescriptionMapper _prescriptionMapper;
  final RefundMapper _refundMapper;
  final MenuTreeMapper _menuMapper;
  final Duration _ttl;

  // ── In-Memory Cache ────────────────────────────────────────────

  CachedEntry<List<PrescriptionItem>>? _unreadQrCodes;
  CachedEntry<List<CabinStock>>? _expiringMaterials;
  CachedEntry<List<CabinStock>>? _criticalStocks;
  CachedEntry<List<Prescription>>? _unappliedPrescriptions;
  CachedEntry<List<Refund>>? _refunds;
  CachedEntry<List<CabinStock>>? _generalStocks;
  CachedEntry<List<PrescriptionItem>>? _upcomingTreatments;
  CachedEntry<List<MenuItem>>? _menuItems;

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

  // ── Repository metodları ───────────────────────────────────────

  @override
  Future<RepoResult<List<PrescriptionItem>>> getUnreadQrCodes({bool forceRefresh = false}) {
    return CachedEntry.performFetch(
      ttl: _ttl,
      currentCache: _unreadQrCodes,
      onSaveCache: (e) => _unreadQrCodes = e,
      forceRefresh: forceRefresh,
      fetcher: () async {
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
    return CachedEntry.performFetch(
      ttl: _ttl,
      currentCache: _expiringMaterials,
      onSaveCache: (e) => _expiringMaterials = e,
      forceRefresh: forceRefresh,
      fetcher: () async {
        final result = await _dataSource.getExpiringMaterials();
        return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<CabinStock>>> getCriticalStocks({bool isClient = false, bool forceRefresh = false}) {
    return CachedEntry.performFetch(
      ttl: _ttl,
      currentCache: _criticalStocks,
      onSaveCache: (e) => _criticalStocks = e,
      forceRefresh: forceRefresh,
      fetcher: () async {
        final result = await _dataSource.getCriticalStocks(isClient: isClient);
        return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<Prescription>>> getUnappliedPrescriptions({bool forceRefresh = false}) {
    return CachedEntry.performFetch(
      ttl: _ttl,
      currentCache: _unappliedPrescriptions,
      onSaveCache: (e) => _unappliedPrescriptions = e,
      forceRefresh: forceRefresh,
      fetcher: () async {
        final result = await _dataSource.getUnappliedPrescriptions();
        return result.when(ok: (dtos) => Result.ok(_prescriptionMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<Refund>>> getRefunds({bool forceRefresh = false}) {
    return CachedEntry.performFetch(
      ttl: _ttl,
      currentCache: _refunds,
      onSaveCache: (e) => _refunds = e,
      forceRefresh: forceRefresh,
      fetcher: () async {
        final result = await _dataSource.getRefunds();
        return result.when(ok: (dtos) => Result.ok(_refundMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<CabinStock>>> getGeneralStocks({bool forceRefresh = false}) {
    return CachedEntry.performFetch(
      ttl: _ttl,
      currentCache: _generalStocks,
      onSaveCache: (e) => _generalStocks = e,
      forceRefresh: forceRefresh,
      fetcher: () async {
        final result = await _dataSource.getGeneralStocks();
        return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
      },
    );
  }

  @override
  Future<RepoResult<List<PrescriptionItem>>> getUpcomingTreatments({bool forceRefresh = false}) {
    return CachedEntry.performFetch(
      ttl: _ttl,
      currentCache: _upcomingTreatments,
      onSaveCache: (e) => _upcomingTreatments = e,
      forceRefresh: forceRefresh,
      fetcher: () async {
        final result = await _dataSource.getUpcomingTreatments();
        return result.when(
          ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])),
          error: Result.error,
        );
      },
    );
  }

  @override
  Future<RepoResult<List<MenuItem>>> getMenuItems({bool forceRefresh = false, int? userId}) {
    return CachedEntry.performFetch(
      ttl: _ttl,
      currentCache: _menuItems,
      onSaveCache: (e) => _menuItems = e,
      forceRefresh: forceRefresh,
      fetcher: () async {
        final result = await _dataSource.getMenus(userId: userId);
        return result.when(ok: (dtos) => Result.ok(_menuMapper.toTreeList(dtos ?? [])), error: Result.error);
      },
    );
  }
}
