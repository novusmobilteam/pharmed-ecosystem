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
    required CabinMapper cabinMapper,
    required PrescriptionItemMapper prescriptionItemMapper,
    required RefundMapper refundMapper,
    required MenuTreeMapper menuMapper,
    required PrescriptionItemMovementMapper itemMovementMapper,
    Duration cacheTtl = const Duration(minutes: 5),
  }) : _dataSource = dataSource,
       _cabinStockMapper = cabinStockMapper,
       _cabinMapper = cabinMapper,
       _prescriptionItemMapper = prescriptionItemMapper,
       _refundMapper = refundMapper,
       _menuMapper = menuMapper,
       _itemMovementMapper = itemMovementMapper;

  final DashboardRemoteDataSource _dataSource;
  final CabinStockMapper _cabinStockMapper;
  final CabinMapper _cabinMapper;
  final PrescriptionItemMapper _prescriptionItemMapper;
  final RefundMapper _refundMapper;
  final MenuTreeMapper _menuMapper;
  final PrescriptionItemMovementMapper _itemMovementMapper;

  @override
  Future<Result<List<PrescriptionItem>>> getUnreadQrCodes({bool forceRefresh = false}) async {
    final result = await _dataSource.getUnreadQrCodes();
    return result.when(ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<CabinStock>>> getExpiringMaterials({bool forceRefresh = false}) async {
    final result = await _dataSource.getExpiringMaterials();
    return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<CabinStock>>> getCriticalStocks({bool isClient = false, bool forceRefresh = false}) async {
    final result = await _dataSource.getCriticalStocks(isClient: isClient);
    return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItem>>> getUnappliedPrescriptions({bool forceRefresh = false}) async {
    final result = await _dataSource.getUnappliedPrescriptions();
    return result.when(ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<Refund>>> getRefunds({bool forceRefresh = false}) async {
    final result = await _dataSource.getRefunds();
    return result.when(ok: (dtos) => Result.ok(_refundMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<CabinStock>>> getGeneralStocks({bool forceRefresh = false}) async {
    final result = await _dataSource.getGeneralStocks();
    return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItem>>> getUpcomingTreatments({bool forceRefresh = false, required String mac}) async {
    final result = await _dataSource.getUpcomingTreatments(mac: mac);
    return result.when(ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<MenuItem>>> getMenuItems({bool forceRefresh = true, int? userId}) async {
    final result = await _dataSource.getMenus(userId: userId);
    return result.when(ok: (dtos) => Result.ok(_menuMapper.toTreeList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItem>>> getMissingStocks({bool forceRefresh = false, required String mac}) async {
    final result = await _dataSource.getMissingStocks(mac: mac);
    return result.when(ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<Cabin>>> getCabins() async {
    final result = await _dataSource.getCabins();
    return result.when(ok: (dtos) => Result.ok(_cabinMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItemMovement>?>> getDrugActivities({required String mac}) async {
    final result = await _dataSource.getDrugActivities(mac: mac);
    return result.when(ok: (dtos) => Result.ok(_itemMovementMapper.toEntityList(dtos ?? [])), error: Result.error);
  }
}
