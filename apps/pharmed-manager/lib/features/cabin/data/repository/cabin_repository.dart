import '../../domain/entity/drawer_config.dart';
import '../../domain/entity/drawer_slot.dart';
import '../../domain/entity/drawer_unit.dart';

import '../../../../core/core.dart';
import '../../domain/entity/cabin.dart';
import '../../domain/entity/drawer_type.dart';
import '../../domain/repository/i_cabin_repository.dart';
import '../datasource/cabin_datasource.dart';

class CabinRepository implements ICabinRepository {
  final CabinDataSource _ds;

  CabinRepository(this._ds);

  @override
  Future<Result<List<Cabin>>> getCabins() async {
    final res = await _ds.getCabins();
    return res.when(
      ok: (data) {
        List<Cabin> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<Cabin>>> getCabinsByStation(int stationId) async {
    final res = await _ds.getCabinsByStation(stationId);
    return res.when(
      ok: (data) {
        List<Cabin> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteCabin(int id) async {
    final r = await _ds.deleteCabin(id);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<Cabin>> createCabin(Cabin entity) async {
    final dto = entity.toDTO();
    final r = await _ds.createCabin(dto);

    return r.when(
      ok: (created) {
        final data = (created ?? dto).toEntity();
        return Result.ok(data);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<Cabin>> updateCabin(Cabin entity) async {
    final dto = entity.toDTO();
    final r = await _ds.updateCabin(dto);

    return r.when(
      ok: (updated) {
        final data = (updated ?? dto).toEntity();
        return Result.ok(data);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<DrawerType>>> getDrawerTypes() async {
    final res = await _ds.getDrawerTypes();
    return res.when(
      ok: (data) {
        List<DrawerType> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<DrawerConfig>>> getDrawerConfigs() async {
    final res = await _ds.getDrawerConfigs();
    return res.when(
      ok: (data) {
        List<DrawerConfig> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createDrawerSlots(List<DrawerSlot> slots) async {
    final dtos = slots.map((s) => s.toDTO()).toList();
    final r = await _ds.createDrawerSlots(dtos);

    return r.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<DrawerSlot>>> getCabinSlots(int cabinId) async {
    final res = await _ds.getCabinSlots(cabinId);
    return res.when(
      ok: (data) {
        List<DrawerSlot> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<DrawerSlot>>> getSerumSlots() async {
    final res = await _ds.getSerumCabins();
    return res.when(
      ok: (data) {
        List<DrawerSlot> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateDrawerSlots(List<DrawerSlot> slots) async {
    final dtos = slots.map((s) => s.toDTO()).toList();
    final r = await _ds.createDrawerSlots(dtos);

    return r.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<DrawerUnit>>> getDrawerUnits(int slotId) async {
    final res = await _ds.getDrawerUnits(slotId);
    return res.when(
      ok: (data) {
        List<DrawerUnit> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }
}
