import 'package:pharmed_core/pharmed_core.dart';

/// MaterialType ↔ MaterialTypeDTO dönüşümleri.
class MaterialTypeMapper {
  const MaterialTypeMapper();

  MaterialType toEntity(MaterialTypeDTO dto) {
    return MaterialType(id: dto.id, name: dto.name, isActive: dto.isActive);
  }

  MaterialType? toEntityOrNull(MaterialTypeDTO? dto) => dto == null ? null : toEntity(dto);

  List<MaterialType> toEntityList(List<MaterialTypeDTO> dtos) => dtos.map(toEntity).toList();

  MaterialTypeDTO toDto(MaterialType entity) {
    return MaterialTypeDTO(id: entity.id, name: entity.name, isActive: entity.isActive);
  }

  MaterialTypeDTO? toDtoOrNull(MaterialType? entity) => entity == null ? null : toDto(entity);
}
