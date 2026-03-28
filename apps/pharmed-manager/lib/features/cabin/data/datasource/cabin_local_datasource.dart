import '../model/drawer_slot_dto.dart';
import '../model/drawer_unit_dto.dart';

import '../../../../../core/core.dart';
import '../model/cabin_dto.dart';
import '../model/drawer_config_dto.dart';
import '../model/drawer_type_dto.dart';
import 'cabin_datasource.dart';

class CabinLocalDataSource extends BaseLocalDataSource<CabinDTO, int> implements CabinDataSource {
  CabinLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => CabinDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );

  @override
  Future<Result<List<CabinDTO>>> getCabins() async {
    return Result.ok([]);
  }

  @override
  Future<Result<List<CabinDTO>>> getCabinsByStation(int stationId) async {
    return Result.ok([]);
  }

  @override
  Future<Result<CabinDTO?>> createCabin(CabinDTO dto) => createRequest(dto);

  @override
  Future<Result<CabinDTO?>> updateCabin(CabinDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteCabin(int id) => deleteRequest(id);

  @override
  Future<Result<List<DrawerConfigDTO>>> getDrawerConfigs() async {
    return Result.ok([]);
  }

  @override
  Future<Result<List<DrawerTypeDTO>>> getDrawerTypes() async {
    return Result.ok([]);
  }

  @override
  Future<Result<void>> createDrawerSlots(List<DrawerSlotDTO> dtos) async {
    return Result.ok(null);
  }

  @override
  Future<Result<List<DrawerSlotDTO>>> getCabinSlots(int cabinId) async {
    return Result.ok([]);
  }

  @override
  Future<Result<List<DrawerSlotDTO>>> getSerumCabins() async {
    return Result.ok([]);
  }

  @override
  Future<Result<void>> updateDrawerSlots(List<DrawerSlotDTO> dtos) async {
    return Result.ok(null);
  }

  @override
  Future<Result<List<DrawerUnitDTO>>> getDrawerUnits(int slotId) async {
    return Result.ok([]);
  }
}
