// pharmed_data/src/cabin/mapper/drawer_type_mapper.dart

import 'package:pharmed_core/pharmed_core.dart';

/// DrawerType ↔ DrawerTypeDTO dönüşümleri.
class DrawerTypeMapper {
  const DrawerTypeMapper();

  DrawerType toEntity(DrawerTypeDTO dto) {
    return DrawerType(
      id: dto.id,
      name: dto.name,
      compartmentCount: dto.compartmentCount,
      isMultipleMaterialInput: dto.isMultipleMaterialInput ?? false,
      isKubik: dto.isKubik ?? false,
      isActive: dto.isActive ?? true,
    );
  }

  DrawerType? toEntityOrNull(DrawerTypeDTO? dto) => dto == null ? null : toEntity(dto);

  List<DrawerType> toEntityList(List<DrawerTypeDTO> dtos) => dtos.map(toEntity).toList();

  DrawerTypeDTO toDto(DrawerType entity) {
    return DrawerTypeDTO(
      id: entity.id,
      name: entity.name,
      compartmentCount: entity.compartmentCount,
      isMultipleMaterialInput: entity.isMultipleMaterialInput,
      isKubik: entity.isKubik,
      isActive: entity.isActive,
    );
  }
}
