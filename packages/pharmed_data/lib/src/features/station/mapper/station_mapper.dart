import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/features/service/mapper/service_mapper.dart';
import 'package:pharmed_data/src/features/warehouse/mapper/warehouse_mapper.dart';

/// Station ↔ StationDTO dönüşümleri.
class StationMapper {
  const StationMapper();

  Station toEntity(StationDTO dto) {
    return Station(
      id: dto.id,
      name: dto.name,
      drugStatus: orderStatusFromBool(dto.stationDrug),
      medicalConsumableStatus: orderStatusFromBool(dto.stationMedicalConsumables),
      service: ServiceMapper().toEntityOrNull(dto.service),
      materialWarehouse: WarehouseMapper().toEntityOrNull(dto.materialWarehouse),
      medicalConsumableWarehouse: WarehouseMapper().toEntityOrNull(dto.medicalConsumableWarehouse),
      macAddress: dto.macAddress,
      services: ServiceMapper().toEntityList(dto.stationProvidedServices),
      type: StationType.fromId(dto.workingMethod),
    );
  }

  Station? toEntityOrNull(StationDTO? dto) => dto == null ? null : toEntity(dto);

  List<Station> toEntityList(List<StationDTO> dtos) => dtos.map(toEntity).toList();

  StationDTO toDto(Station entity) {
    return StationDTO(
      id: entity.id,
      name: entity.name,
      stationDrug: entity.drugStatus.isActive,
      stationMedicalConsumables: entity.medicalConsumableStatus.isActive,
      service: ServiceMapper().toDtoOrNull(entity.service),
      materialWarehouse: WarehouseMapper().toDtoOrNull(entity.materialWarehouse),
      medicalConsumableWarehouse: WarehouseMapper().toDtoOrNull(entity.medicalConsumableWarehouse),
      macAddress: entity.macAddress,
      stationProvidedServices: ServiceMapper().toDtoList(entity.services),
      workingMethod: entity.type?.id,
    );
  }

  StationDTO? toDtoOrNull(Station? entity) => entity == null ? null : toDto(entity);

  List<StationDTO> toDtoList(List<Station> entities) => entities.map(toDto).toList();
}
