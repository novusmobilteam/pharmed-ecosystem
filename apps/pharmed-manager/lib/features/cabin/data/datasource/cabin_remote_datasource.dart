import '../../../../../core/core.dart';
import '../model/cabin_dto.dart';
import '../model/drawer_config_dto.dart';
import '../model/drawer_slot_dto.dart';
import '../model/drawer_type_dto.dart';
import '../model/drawer_unit_dto.dart';
import 'cabin_datasource.dart';

class CabinRemoteDataSource extends BaseRemoteDataSource implements CabinDataSource {
  final String _basePath = '/Cabin';

  CabinRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<CabinDTO>>> getCabins() async {
    final res = await fetchRequest<List<CabinDTO>>(
      path: '$_basePath/currentStation',
      parser: listParser(CabinDTO.fromJson),
      successLog: 'Cabins fetched successfully',
      emptyLog: 'No cabins found',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? []),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<CabinDTO>>> getCabinsByStation(int stationId) async {
    final res = await fetchRequest<List<CabinDTO>>(
      path: '$_basePath/station/$stationId',
      parser: listParser(CabinDTO.fromJson),
      successLog: 'Station cabins fetched successfully',
      emptyLog: 'No cabins found for this station',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? []),
      error: Result.error,
    );
  }

  @override
  Future<Result<CabinDTO?>> createCabin(CabinDTO dto) {
    return createRequest<CabinDTO>(
      path: _basePath,
      body: dto.toJson(),
      parser: singleParser(CabinDTO.fromJson),
      successLog: 'Cabin created successfully',
    );
  }

  @override
  Future<Result<CabinDTO?>> updateCabin(CabinDTO dto) {
    return updateRequest<CabinDTO?>(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: singleParser(CabinDTO.fromJson),
      successLog: 'Cabin updated successfully',
    );
  }

  @override
  Future<Result<void>> deleteCabin(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Cabin deleted successfully',
    );
  }

  @override
  Future<Result<List<DrawerConfigDTO>>> getDrawerConfigs() async {
    final res = await fetchRequest<List<DrawerConfigDTO>>(
      path: '/DrawrDetail',
      parser: listParser(DrawerConfigDTO.fromJson),
      successLog: 'Drawer configs fetched',
      emptyLog: 'No drawer config',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const <DrawerConfigDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<DrawerTypeDTO>>> getDrawerTypes() async {
    final res = await fetchRequest<List<DrawerTypeDTO>>(
      path: '/Drawr',
      parser: listParser(DrawerTypeDTO.fromJson),
      successLog: 'Drawer types fetched',
      emptyLog: 'No drawer type',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const <DrawerTypeDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createDrawerSlots(List<DrawerSlotDTO> dtos) async {
    return createBulkRequest(
      path: '/CabinDesign/bulk',
      body: dtos.map((d) => d.toJson()).toList(),
      parser: null,
    );
  }

  @override
  Future<Result<List<DrawerSlotDTO>>> getCabinSlots(int cabinId) async {
    final res = await fetchRequest<List<DrawerSlotDTO>>(
      path: '/CabinDesign/cabin/$cabinId',
      parser: listParser(DrawerSlotDTO.fromJson),
      successLog: 'Cabin Layout fetched',
      emptyLog: 'No Layout data',
    );

    return res.when(
      ok: (list) => Result.ok(list ?? const <DrawerSlotDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateDrawerSlots(List<DrawerSlotDTO> dtos) {
    return updateBulkRequest(
      path: '$_basePath/bulk',
      body: dtos.map((d) => d.toJson()).toList(),
      parser: null,
    );
  }

  @override
  Future<Result<List<DrawerSlotDTO>>> getSerumCabins() async {
    final res = await fetchRequest<List<DrawerSlotDTO>>(
      path: '/CabinDrawr/serum',
      parser: listParser(DrawerSlotDTO.fromJson),
      successLog: 'Serum Cabins fetched',
      emptyLog: 'No Serum Cabins',
    );

    return res.when(
      ok: (list) => Result.ok(list ?? const <DrawerSlotDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<DrawerUnitDTO>>> getDrawerUnits(int slotId) async {
    final res = await fetchRequest<List<DrawerUnitDTO>>(
      path: '/CabinDesign/cabinDrawr/$slotId',
      parser: listParser(DrawerUnitDTO.fromJson),
    );

    return res.when(
      ok: (list) => Result.ok(list ?? const <DrawerUnitDTO>[]),
      error: Result.error,
    );
  }
}
