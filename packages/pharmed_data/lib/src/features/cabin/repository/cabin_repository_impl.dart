// pharmed_data/src/cabin/repository/cabin_repository_impl.dart
//
// [SWREQ-DATA-CABIN-002]
// ICabinRepository implementasyonu.
// DTO → entity dönüşümü mapper'lar üzerinden yapılır.
// DrawerConfig ve DrawerType için in-memory cache.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../datasource/cabin_remote_datasource.dart';
import '../mapper/cabin_mapper.dart';
import '../mapper/drawer_config_mapper.dart';
import '../mapper/drawer_slot_mapper.dart';
import '../mapper/drawer_type_mapper.dart';
import '../mapper/drawer_unit_mapper.dart';

class CabinRepositoryImpl implements ICabinRepository {
  CabinRepositoryImpl({
    required CabinRemoteDataSource dataSource,
    required CabinMapper cabinMapper,
    required DrawerSlotMapper drawerSlotMapper,
    required DrawerConfigMapper drawerConfigMapper,
    required DrawerUnitMapper drawerUnitMapper,
    required DrawerTypeMapper drawerTypeMapper,
  }) : _dataSource = dataSource,
       _cabinMapper = cabinMapper,
       _drawerSlotMapper = drawerSlotMapper,
       _drawerConfigMapper = drawerConfigMapper,
       _drawerUnitMapper = drawerUnitMapper,
       _drawerTypeMapper = drawerTypeMapper;

  final CabinRemoteDataSource _dataSource;
  final CabinMapper _cabinMapper;
  final DrawerSlotMapper _drawerSlotMapper;
  final DrawerConfigMapper _drawerConfigMapper;
  final DrawerUnitMapper _drawerUnitMapper;
  final DrawerTypeMapper _drawerTypeMapper;

  // ── In-Memory Cache ────────────────────────────────────────────

  List<DrawerConfig>? _cachedConfigs;
  List<DrawerType>? _cachedTypes;

  /// Cache'i temizler. Logout veya session sonlandırmada çağrılabilir.
  void clearCache() {
    _cachedConfigs = null;
    _cachedTypes = null;
  }

  // ── Kabin CRUD ─────────────────────────────────────────────────

  @override
  Future<Result<List<Cabin>>> getCabins() async {
    final result = await _dataSource.getCabins();
    return result.when(ok: (dtos) => Result.ok(_cabinMapper.toEntityList(dtos)), error: Result.error);
  }

  @override
  Future<Result<List<Cabin>>> getCabinsByStation(int stationId) async {
    final result = await _dataSource.getCabinsByStation(stationId);
    return result.when(ok: (dtos) => Result.ok(_cabinMapper.toEntityList(dtos)), error: Result.error);
  }

  @override
  Future<Result<Cabin?>> createCabin(Cabin entity) async {
    final result = await _dataSource.createCabin(_cabinMapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<Cabin?>> updateCabin(Cabin entity) async {
    final result = await _dataSource.updateCabin(_cabinMapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> deleteCabin(Cabin entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek kabinin id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteCabin(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: Result.error);
  }

  // ── Yuva (Slot) & Unit İşlemleri ──────────────────────────────

  @override
  Future<Result<List<DrawerSlot>>> getCabinSlots(int cabinId) async {
    final result = await _dataSource.getCabinSlots(cabinId);
    return result.when(ok: (dtos) => Result.ok(_drawerSlotMapper.toEntityList(dtos)), error: Result.error);
  }

  @override
  Future<Result<List<DrawerUnit>>> getDrawerUnits(int slotId) async {
    final result = await _dataSource.getDrawerUnits(slotId);
    return result.when(ok: (dtos) => Result.ok(_drawerUnitMapper.toEntityList(dtos)), error: Result.error);
  }

  @override
  Future<Result<void>> createDrawerSlots(List<DrawerSlot> slots) async {
    final result = await _dataSource.createDrawerSlots(_drawerSlotMapper.toDtoList(slots));
    return result.when(ok: (_) => const Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> updateDrawerSlots(List<DrawerSlot> slots) async {
    final result = await _dataSource.updateDrawerSlots(_drawerSlotMapper.toDtoList(slots));
    return result.when(ok: (_) => const Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<List<DrawerSlot>>> getSerumSlots() async {
    final result = await _dataSource.getSerumCabins();
    return result.when(ok: (dtos) => Result.ok(_drawerSlotMapper.toEntityList(dtos)), error: Result.error);
  }

  // ── Meta Veri (In-Memory Cache) ───────────────────────────────

  @override
  Future<Result<List<DrawerConfig>>> getDrawerConfigs({bool forceRefresh = false}) async {
    // Cache varsa ve force değilse → hemen döndür
    if (!forceRefresh && _cachedConfigs != null) {
      return Result.ok(_cachedConfigs!);
    }

    final result = await _dataSource.getDrawerConfigs();
    return result.when(
      ok: (dtos) {
        final entities = _drawerConfigMapper.toEntityList(dtos);
        _cachedConfigs = entities; // Cache'e yaz
        return Result.ok(entities);
      },
      error: (e) {
        // API başarısız ama eski cache varsa onu döndür
        if (_cachedConfigs != null) return Result.ok(_cachedConfigs!);
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<DrawerType>>> getDrawerTypes({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedTypes != null) {
      return Result.ok(_cachedTypes!);
    }

    final result = await _dataSource.getDrawerTypes();
    return result.when(
      ok: (dtos) {
        final entities = _drawerTypeMapper.toEntityList(dtos);
        _cachedTypes = entities;
        return Result.ok(entities);
      },
      error: (e) {
        if (_cachedTypes != null) return Result.ok(_cachedTypes!);
        return Result.error(e);
      },
    );
  }
}
