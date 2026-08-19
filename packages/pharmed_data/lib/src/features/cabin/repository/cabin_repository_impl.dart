// packages/pharmed_data/lib/src/cabin/repository/cabin_repository_impl.dart
//
// [SWREQ-DATA-CABIN-002] [IEC 62304 §5.5]
// ICabinRepository implementasyonu.
// Cache stratejisi: API → başarılı ise cache'e yaz + Result.ok döndür.
//                   API → başarısız ise cache'e bak:
//                     Cache var  → RepoStale döndür
//                     Cache yok  → RepoFailure döndür
// Write operasyonları (create/update/delete) cache'i invalidate eder.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class CabinRepositoryImpl implements ICabinRepository {
  CabinRepositoryImpl({
    required CabinRemoteDataSource remoteDataSource,
    required ICabinLocalDataSource localDataSource,
    required CabinMapper cabinMapper,
    required DrawerSlotMapper drawerSlotMapper,
    required DrawerConfigMapper drawerConfigMapper,
    required DrawerUnitMapper drawerUnitMapper,
    required DrawerTypeMapper drawerTypeMapper,
    required MobileDrawerSlotMapper mobileDrawerSlotMapper,
  }) : _remote = remoteDataSource,
       _local = localDataSource,
       _cabinMapper = cabinMapper,
       _drawerSlotMapper = drawerSlotMapper,
       _drawerConfigMapper = drawerConfigMapper,
       _drawerUnitMapper = drawerUnitMapper,
       _drawerTypeMapper = drawerTypeMapper,
       _mobileDrawerSlotMapper = mobileDrawerSlotMapper;

  final CabinRemoteDataSource _remote;
  final ICabinLocalDataSource _local;
  final CabinMapper _cabinMapper;
  final DrawerSlotMapper _drawerSlotMapper;
  final DrawerConfigMapper _drawerConfigMapper;
  final DrawerUnitMapper _drawerUnitMapper;
  final DrawerTypeMapper _drawerTypeMapper;
  final MobileDrawerSlotMapper _mobileDrawerSlotMapper;

  @override
  Future<Result<List<Cabin>>> getCabins() async {
    final result = await _remote.getCabins();

    return result.when(
      ok: (dtos) async {
        await _local.saveCabins(dtos);
        return Result.ok(_cabinMapper.toEntityList(dtos));
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<Cabin?>> getCabin(int cabinId) async {
    final result = await _remote.getCabin(cabinId);

    return result.when(
      ok: (dto) async {
        if (dto != null) await _local.saveCabin(dto);
        return Result.ok(dto != null ? _cabinMapper.toEntity(dto) : null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<List<Cabin>>> getCabinsByStation(int stationId) async {
    // Belirli bir istasyona ait kabinler genel cache'den filtrelenir.
    // API başarısız olursa cache'deki tüm kabinler içinden filtre uygulanır.
    final result = await _remote.getCabinsByStation(stationId);

    return result.when(
      ok: (dtos) async {
        // Gelen kabinleri genel cache'e de yaz (merge)
        final existing = await _local.readCabins() ?? [];
        final ids = dtos.map((d) => d.id).toSet();
        final merged = [...existing.where((e) => !ids.contains(e.id)), ...dtos];
        await _local.saveCabins(merged);
        return Result.ok(_cabinMapper.toEntityList(dtos));
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<Cabin?>> createCabin(Cabin entity) async {
    final result = await _remote.createCabin(_cabinMapper.toDto(entity));
    return result.when(
      ok: (dto) async {
        // Yeni kabin eklendi — kabin cache'ini invalidate et
        await _local.clearCabins();
        final created = dto != null ? _cabinMapper.toEntity(dto) : null;
        return Result.ok(created);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateCabin(Cabin entity) async {
    final result = await _remote.updateCabin(_cabinMapper.toDto(entity));
    return result.when(
      ok: (dto) async {
        await _local.clearCabins();
        return Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> deleteCabin(Cabin entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: contextlessL10n().dataGuard_deleteCabinIdEmpty, field: 'id'));
    }
    final result = await _remote.deleteCabin(entity.id!);
    return result.when(
      ok: (_) async {
        await _local.clearCabins();
        if (entity.id != null) await _local.clearSlots(entity.id!);
        return const Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<List<DrawerSlot>>> getCabinSlots(int cabinId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _local.readSlots(cabinId);
      if (cached != null) return Result.ok(_drawerSlotMapper.toEntityList(cached));
    }

    final result = await _remote.getCabinSlots(cabinId);

    return result.when(
      ok: (dtos) async {
        await _local.saveSlots(cabinId, dtos);
        return Result.ok(_drawerSlotMapper.toEntityList(dtos));
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<List<MobileDrawerSlot>>> getMobileCabinSlots(int cabinId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _local.readMobileDrawers(cabinId);
      if (cached != null) return Result.ok(_mobileDrawerSlotMapper.toEntityList(cached));
    }

    final result = await _remote.getMobileCabinSlots(cabinId);

    return result.when(
      ok: (dtos) async {
        await _local.saveMobileDrawers(cabinId, dtos);
        return Result.ok(_mobileDrawerSlotMapper.toEntityList(dtos));
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<List<DrawerUnit>>> getDrawerUnits(int slotId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _local.readUnits(slotId);
      if (cached != null) return Result.ok(_drawerUnitMapper.toEntityList(cached));
    }

    final result = await _remote.getDrawerUnits(slotId);

    return result.when(
      ok: (dtos) async {
        await _local.saveUnits(slotId, dtos);
        return Result.ok(_drawerUnitMapper.toEntityList(dtos));
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createDrawerSlots(List<DrawerSlot> slots) async {
    final result = await _remote.createDrawerSlots(_drawerSlotMapper.toDtoList(slots));
    return result.when(
      ok: (_) async {
        final cabinIds = slots.map((s) => s.cabinId).whereType<int>().toSet();
        await Future.wait(cabinIds.map(_local.clearSlots));

        // Bu slot'ların unit cache'i de artık stale olabilir (yeni oluşturulan
        // slot'larda henüz unit yok ama tutarlılık için temizliyoruz).
        final slotIds = slots.map((s) => s.id).whereType<int>().toSet();
        await Future.wait(slotIds.map(_local.clearUnits));

        return const Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateDrawerSlots(List<DrawerSlot> slots) async {
    final result = await _remote.updateDrawerSlots(_drawerSlotMapper.toDtoList(slots));
    return result.when(
      ok: (_) async {
        final cabinIds = slots.map((s) => s.cabinId).whereType<int>().toSet();
        await Future.wait(cabinIds.map(_local.clearSlots));

        // Kritik: slot.id'ler UPDATE'te korunuyor (SaveCabinDesignUseCase
        // isUpdate:true ile var olan slot'ları düzenliyor), yani bu slot'ların
        // unit cache'i (hücre sayısı/tipi değişmiş olabilir) STALE kalır —
        // slot cache'i temizlemek units'e dokunmaz (ayrı box/key). Bu yüzden
        // burada ayrıca temizliyoruz.
        final slotIds = slots.map((s) => s.id).whereType<int>().toSet();
        await Future.wait(slotIds.map(_local.clearUnits));

        return const Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createMobileDrawerSlots(List<MobileDrawerRequestDTO> drawers) async {
    final result = await _remote.createMobileDrawerSlots(drawers);
    return result.when(
      ok: (_) async {
        final cabinIds = drawers.map((d) => d.cabinId).toSet();
        await Future.wait(cabinIds.map(_local.clearSlots));
        return const Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateMobileDrawerSlots(List<MobileDrawerRequestDTO> drawers) async {
    final result = await _remote.updateMobileDrawerSlots(drawers);
    return result.when(
      ok: (_) async {
        final cabinIds = drawers.map((d) => d.cabinId).toSet();
        await Future.wait(cabinIds.map(_local.clearSlots));
        return const Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<List<DrawerSlot>>> getSerumSlots() async {
    final result = await _remote.getSerumCabins();
    return result.when(ok: (dtos) => Result.ok(_drawerSlotMapper.toEntityList(dtos)), error: Result.error);
  }

  // ── Meta (DrawerConfig + DrawerType) ──────────────────────────
  // Bu veriler nadiren değişir — Hive cache tercih edilir.

  @override
  Future<Result<List<DrawerConfig>>> getDrawerConfigs({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _local.readDrawerConfigs();
      if (cached != null) {
        return Result.ok(_drawerConfigMapper.toEntityList(cached));
      }
    }

    final result = await _remote.getDrawerConfigs();
    return result.when(
      ok: (dtos) async {
        await _local.saveDrawerConfigs(dtos);
        return Result.ok(_drawerConfigMapper.toEntityList(dtos));
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<List<DrawerType>>> getDrawerTypes({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _local.readDrawerTypes();
      if (cached != null) {
        return Result.ok(_drawerTypeMapper.toEntityList(cached));
      }
    }

    final result = await _remote.getDrawerTypes();
    return result.when(
      ok: (dtos) async {
        await _local.saveDrawerTypes(dtos);
        return Result.ok(_drawerTypeMapper.toEntityList(dtos));
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateReturnDrawer(int id, bool status) {
    return _remote.updateReturnDrawer(id, status);
  }
}
