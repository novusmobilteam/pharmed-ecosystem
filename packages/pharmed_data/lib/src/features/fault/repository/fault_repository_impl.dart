// [SWREQ-DATA-DRUGTYPE-002]
// IFaultRepository implementasyonu.
// DTO → entity dönüşümü FaultMapper üzerinden yapılır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class FaultRepositoryImpl implements IFaultRepository {
  FaultRepositoryImpl({
    required FaultRemoteDataSource dataSource,
    required MasterFaultMapper masterFaultMapper,
    required MobileFaultMapper mobileFaultMapper,
  }) : _dataSource = dataSource,
       _masterFaultMapper = masterFaultMapper,
       _mobileFaultMapper = mobileFaultMapper;

  final FaultRemoteDataSource _dataSource;
  final MasterFaultMapper _masterFaultMapper;
  final MobileFaultMapper _mobileFaultMapper;

  // In-memory cache — sadece uygulama ömrü boyunca yaşar, Hive'a yazılmaz.
  // Arıza kaydı mutasyonları nadir olduğu için, herhangi bir create/clear
  // işleminden sonra TÜM cache'i temizlemek (cabin-bazlı hedefli invalidation
  // yerine) yeterince ucuz ve basit.
  final Map<int, List<MasterFault>> _masterCache = {};
  final Map<int, List<MobileFault>> _mobileCache = {};

  @override
  Future<Result<List<MasterFault>>> getMasterCabinFaultRecords(int cabinId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _masterCache[cabinId];
      if (cached != null) return Result.ok(cached);
    }

    final res = await _dataSource.getMasterCabinFaultRecords(cabinId);
    return res.when(
      ok: (dtos) {
        final entities = _masterFaultMapper.toEntityList(dtos ?? []);
        _masterCache[cabinId] = entities;
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<MobileFault>>> getMobileCabinFaultRecords(int cabinId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _mobileCache[cabinId];
      if (cached != null) return Result.ok(cached);
    }

    final res = await _dataSource.getMobileCabinFaultRecords(cabinId);
    return res.when(
      ok: (dtos) {
        final entities = _mobileFaultMapper.toEntityList(dtos ?? []);
        _mobileCache[cabinId] = entities;
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createMasterCabinFaultRecord(MasterFault fault, int cellId) async {
    final result = await _dataSource.createMasterCabinFaultRecord(_masterFaultMapper.toDto(fault), cellId);
    return result.when(ok: (_) => _invalidateMaster(), error: Result.error);
  }

  @override
  Future<Result<void>> createMobilCabinFaultRecord(MobileFault fault, int slotId) async {
    final result = await _dataSource.createMobilCabinFaultRecord(_mobileFaultMapper.toDto(fault), slotId);
    return result.when(ok: (_) => _invalidateMobile(), error: Result.error);
  }

  @override
  Future<Result<void>> clearMasterCabinFaultRecord(MasterFault fault, int cellId) async {
    final result = await _dataSource.clearMasterCabinFaultRecord(_masterFaultMapper.toDto(fault), cellId);
    return result.when(ok: (_) => _invalidateMaster(), error: Result.error);
  }

  @override
  Future<Result<void>> clearMobilCabinFaultRecord(MobileFault fault, int slotId) async {
    final result = await _dataSource.clearMobilCabinFaultRecord(_mobileFaultMapper.toDto(fault), slotId);
    return result.when(ok: (_) => _invalidateMobile(), error: Result.error);
  }

  @override
  Future<Result<void>> createMasterCabinMaintenanceRecord(MasterFault fault, int cellId) async {
    final result = await _dataSource.createMasterCabinMaintenanceRecord(_masterFaultMapper.toDto(fault), cellId);
    return result.when(ok: (_) => _invalidateMaster(), error: Result.error);
  }

  @override
  Future<Result<void>> createMobilCabinMaintenanceRecord(MobileFault fault, int slotId) async {
    final result = await _dataSource.createMobilCabinMaintenanceRecord(_mobileFaultMapper.toDto(fault), slotId);
    return result.when(ok: (_) => _invalidateMobile(), error: Result.error);
  }

  @override
  Future<Result<void>> clearMasterCabinMaintenanceRecord(MasterFault fault, int cellId) async {
    final result = await _dataSource.clearMasterCabinMaintenanceRecord(_masterFaultMapper.toDto(fault), cellId);
    return result.when(ok: (_) => _invalidateMaster(), error: Result.error);
  }

  @override
  Future<Result<void>> clearMobilCabinMaintenanceRecord(MobileFault fault, int cellId) async {
    final result = await _dataSource.clearMobilCabinMaintenanceRecord(_mobileFaultMapper.toDto(fault), cellId);
    return result.when(ok: (_) => _invalidateMobile(), error: Result.error);
  }

  Result<void> _invalidateMaster() {
    _masterCache.clear();
    return const Result.ok(null);
  }

  Result<void> _invalidateMobile() {
    _mobileCache.clear();
    return const Result.ok(null);
  }
}
