import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/features/user/mapper/user_mapper.dart';

/// Warehouse ↔ WarehouseDTO dönüşümleri.
class WarehouseMapper {
  const WarehouseMapper();

  Warehouse toEntity(WarehouseDTO dto) {
    return Warehouse(
      id: dto.id,
      name: dto.name,
      isActive: dto.isActive,
      type: warehouseTypeFromId(dto.warehouseKindId),
      user: UserMapper().toEntityOrNull(dto.user),
    );
  }

  Warehouse? toEntityOrNull(WarehouseDTO? dto) => dto == null ? null : toEntity(dto);

  List<Warehouse> toEntityList(List<WarehouseDTO> dtos) => dtos.map(toEntity).toList();

  WarehouseDTO toDto(Warehouse entity) {
    return WarehouseDTO(
      id: entity.id,
      name: entity.name,
      isActive: entity.isActive,
      user: UserMapper().toDtoOrNull(entity.user),
      warehouseKindId: entity.type?.id,
    );
  }

  WarehouseDTO? toDtoOrNull(Warehouse? entity) => entity == null ? null : toDto(entity);
}
