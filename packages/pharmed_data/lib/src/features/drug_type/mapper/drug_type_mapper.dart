import 'package:pharmed_core/pharmed_core.dart';

/// DrugType ↔ DrugTypeDTO dönüşümleri.
class DrugTypeMapper {
  const DrugTypeMapper();

  DrugType toEntity(DrugTypeDTO dto) {
    return DrugType(id: dto.id, name: dto.name, isActive: dto.isActive);
  }

  DrugType? toEntityOrNull(DrugTypeDTO? dto) => dto == null ? null : toEntity(dto);

  List<DrugType> toEntityList(List<DrugTypeDTO> dtos) => dtos.map(toEntity).toList();

  DrugTypeDTO toDto(DrugType entity) {
    return DrugTypeDTO(id: entity.id, name: entity.name, isActive: entity.isActive);
  }

  DrugTypeDTO? toDtoOrNull(DrugType? entity) => entity == null ? null : toDto(entity);
}
